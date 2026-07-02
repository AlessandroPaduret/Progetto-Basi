#include "dbcs.h"
#include "table_render.h" // Presuppone l'esistenza della libreria di rendering delle tabelle

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* -----------------------------------------------------------------------
 * Helpers di utilità interna per input
 * ----------------------------------------------------------------------- */

static void clear_stdin_line(void)
{
    int c;
    while ((c = getchar()) != '\n' && c != EOF)
        /* scarta */;
}

static int read_int_in_range(const char *prompt, int min, int max)
{
    int value;
    for (;;) {
        printf("%s", prompt);
        if (scanf("%d", &value) != 1) {
            printf("Input non valido. Inserisci un numero.\n");
            clear_stdin_line();
            continue;
        }
        clear_stdin_line();
        if (value < min || value > max) {
            printf("Scegli un valore tra %d e %d.\n", min, max);
            continue;
        }
        return value;
    }
}

/** Stampa un PGresult come tabella ASCII usando table_render. */
static void print_result_table(PGresult *res)
{
    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (cols == 0) {
        printf("(nessuna colonna)\n");
        return;
    }
    if (rows == 0) {
        printf("(nessun risultato trovato)\n");
        return;
    }

    TableLayout *layout = table_layout_from_pgresult(res);
    if (!layout) {
        fprintf(stderr, "Errore di memoria nel calcolo del layout tabella.\n");
        return;
    }

    if (layout->cols_to_print < cols)
        printf("(tabella larga: mostro %d colonne su %d)\n\n",
               layout->cols_to_print, cols);

    /* Header */
    for (int j = 0; j < layout->cols_to_print; j++) {
        table_print_cell(PQfname(res, j), layout->col_widths[j]);
        if (j < layout->cols_to_print - 1)
            printf(" | ");
    }
    printf("\n");

    /* Separatore */
    table_print_separator(layout->col_widths, layout->cols_to_print);

    /* Righe */
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < layout->cols_to_print; j++) {
            const char *v = PQgetisnull(res, i, j)
                            ? "NULL"
                            : PQgetvalue(res, i, j);
            table_print_cell(v, layout->col_widths[j]);
            if (j < layout->cols_to_print - 1)
                printf(" | ");
        }
        printf("\n");
    }

    table_layout_free(layout);
}

/* -----------------------------------------------------------------------
 * Ciclo di vita della connessione
 * ----------------------------------------------------------------------- */

int dbcs_connect(DBCS *self, const char *connstr)
{
    self->last_error = 0;
    self->error_msg[0] = '\0';
    self->conn = PQconnectdb(connstr);

    if (PQstatus(self->conn) == CONNECTION_BAD) {
        snprintf(self->error_msg, sizeof(self->error_msg),
                 "Connessione fallita: %s", PQerrorMessage(self->conn));
        PQfinish(self->conn);
        self->conn = NULL;
        self->last_error = 1;
        return 1;
    }
    return 0;
}

void dbcs_disconnect(DBCS *self)
{
    if (self->conn) {
        PQfinish(self->conn);
        self->conn = NULL;
    }
    self->last_error = 0;
    self->error_msg[0] = '\0';
}

/* -----------------------------------------------------------------------
 * Esecuzione query generiche
 * ----------------------------------------------------------------------- */

void dbcs_exec_and_print(DBCS *self, const char *title, const char *sql)
{
    self->last_error = 0;
    printf("\n=== %s ===\n", title);

    PGresult *res = PQexec(self->conn, sql);
    ExecStatusType st = PQresultStatus(res);

    if (st != PGRES_TUPLES_OK) {
        snprintf(self->error_msg, sizeof(self->error_msg),
                 "%s", PQerrorMessage(self->conn));
        fprintf(stderr, "Errore nella query [%s]:\n%s\n", title,
                self->error_msg);
        self->last_error = 1;
        PQclear(res);
        return;
    }

    print_result_table(res);
    PQclear(res);
}

void dbcs_exec_prepared_and_print(DBCS *self, 
                                  const char *stmtName, 
                                  int nParams, 
                                  const char *const *paramValues) 
{
    self->last_error = 0;
    PGresult *res = PQexecPrepared(self->conn, stmtName, nParams, paramValues, NULL, NULL, 0);
    
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore esecuzione %s: %s\n", stmtName, PQerrorMessage(self->conn));
        self->last_error = 1;
        PQclear(res);
        return;
    }

    print_result_table(res);
    PQclear(res);
}

PGresult *dbcs_exec_or_die(DBCS *self, const char *context, const char *sql)
{
    PGresult *res = PQexec(self->conn, sql);
    ExecStatusType st = PQresultStatus(res);

    if (st != PGRES_TUPLES_OK && st != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore fatale durante: %s\n%s\n",
                context, PQerrorMessage(self->conn));
        PQclear(res);
        dbcs_disconnect(self);
        exit(1);
    }
    return res;
}

/* -----------------------------------------------------------------------
 * Utility di selezione interattiva
 * ----------------------------------------------------------------------- */

int dbcs_choose_from_pool(DBCS *self,
                          const char *title,
                          const char *sql,
                          int col_display_idx,
                          char *out,
                          size_t out_len)
{
    printf("\n=== %s ===\n", title);
    PGresult *res = dbcs_exec_or_die(self, title, sql);

    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (rows <= 0) {
        printf("(nessuna scelta disponibile)\n");
        PQclear(res);
        return 0;
    }

    if (col_display_idx < 0 || col_display_idx >= cols) {
        fprintf(stderr, "Errore interno: col_display_idx=%d fuori range (cols=%d)\n",
                col_display_idx, cols);
        PQclear(res);
        return 0;
    }

    for (int i = 0; i < rows; i++) {
        const char *v = PQgetisnull(res, i, col_display_idx) ? "" : PQgetvalue(res, i, col_display_idx);
        printf("%d) %s\n", i + 1, v);
    }

    int choice = read_int_in_range("Seleziona: ", 1, rows);
    const char *sel = PQgetvalue(res, choice - 1, col_display_idx);

    strncpy(out, sel, out_len);
    out[out_len - 1] = '\0';

    PQclear(res);
    return 1;
}

int dbcs_choose_from_pool_prepared(DBCS *self,
                                   const char *title,
                                   const char *stmtName,
                                   int nParams,
                                   const char *const *paramValues,
                                   int col_display_idx,
                                   char *out,
                                   size_t out_len)
{
    printf("\n=== %s ===\n", title);

    PGresult *res = PQexecPrepared(self->conn, stmtName, nParams, paramValues, NULL, NULL, 0);

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore durante la scelta [%s]: %s\n", title, PQerrorMessage(self->conn));
        PQclear(res);
        return 0;
    }

    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (rows <= 0) {
        printf("(nessuna scelta disponibile)\n");
        PQclear(res);
        return 0;
    }

    if (col_display_idx < 0 || col_display_idx >= cols) {
        fprintf(stderr, "Errore: indice colonna %d non valido (totale: %d)\n", col_display_idx, cols);
        PQclear(res);
        return 0;
    }

    for (int i = 0; i < rows; i++) {
        const char *v = PQgetisnull(res, i, col_display_idx) ? "NULL" : PQgetvalue(res, i, col_display_idx);
        printf("%d) %s\n", i + 1, v);
    }

    int choice = read_int_in_range("Seleziona: ", 1, rows);
    
    const char *sel = PQgetvalue(res, choice - 1, col_display_idx);
    strncpy(out, sel, out_len);
    out[out_len - 1] = '\0';

    PQclear(res);
    return 1;
}

int dbcs_choose_city_then_zone_prepared(DBCS *self, char *out_city, size_t out_city_len, char *out_zone, size_t out_zone_len)
{
    // 1. Scegli la città (prendendola da tutte le zone registrate)
    const char *q_cities = "SELECT DISTINCT Citta FROM Zona ORDER BY Citta ASC;";
    PQclear(PQprepare(self->conn, "prep_list_cities", q_cities, 0, NULL));
    
    if (!dbcs_choose_from_pool_prepared(self, "CITTA' DISPONIBILI", "prep_list_cities", 0, NULL, 0, out_city, out_city_len))
        return 0;

    // 2. Scegli la zona filtrando per la città selezionata al passo precedente
    const char *q_zones = "SELECT Nome FROM Zona WHERE Citta = $1 ORDER BY Nome ASC;";
    PQclear(PQprepare(self->conn, "prep_list_zones", q_zones, 1, NULL));

    const char *params[] = { out_city };
    if (!dbcs_choose_from_pool_prepared(self, "ZONE NELLA CITTA' SELEZIONATA", "prep_list_zones", 1, params, 0, out_zone, out_zone_len))
        return 0;

    return 1;
}

/* -----------------------------------------------------------------------
 * Query di Dominio del Database CitySharing (Adattate)
 * ----------------------------------------------------------------------- */

void dbcs_query_operator_reports(DBCS *self)
{
    // Q1: Mostra per ogni operatore il numero di segnalazioni gestite
    static const char *sql =
        "SELECT o.CF, o.Nome, o.Cognome, COUNT(s.Veicolo) AS n_seg "
        "FROM Operatore o "
        "LEFT JOIN Segnalazione s ON o.CF = s.CFOperatore "
        "GROUP BY o.CF, o.Nome, o.Cognome "
        "HAVING COUNT(s.Veicolo) > 0 "
        "ORDER BY n_seg DESC;";

    dbcs_exec_and_print(self, "SEGNALAZIONI GESTITE PER OGNI OPERATORE", sql);
}

void dbcs_query_user_spending(DBCS *self, const char *start_time, const char *end_time)
{
    // Q2: Calcolo della spesa degli utenti in un intervallo di tempo specifico
    const char *stmtName = "get_user_spending";
    const char *sql =
        "SELECT u.Email, u.Nome, u.Cognome, u.Telefono, SUM(n.CostoTotale) AS guadagno "
        "FROM Noleggio n "
        "JOIN Utente u ON n.UtenteEmail = u.Email "
        "WHERE n.DataOraFine BETWEEN $1::timestamp AND $2::timestamp "
        "GROUP BY u.Email, u.Nome, u.Cognome, u.Telefono "
        "HAVING SUM(n.CostoTotale) > 0 "
        "ORDER BY guadagno DESC;";

    // Prepariamo lo statement con 2 parametri (Data Inizio, Data Fine)
    PGresult *prep = PQprepare(self->conn, stmtName, sql, 2, NULL);
    if (PQresultStatus(prep) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore preparazione query spesa utenti: %s\n", PQerrorMessage(self->conn));
        PQclear(prep);
        return;
    }
    PQclear(prep);

    const char *params[2] = { start_time, end_time };
    printf("\n=== SPESA COMPLESSIVA DEGLI UTENTI IN UN INTERVALLO TEMPORALE ===\n");
    printf("Intervallo: da %s a %s\n", start_time, end_time);
    dbcs_exec_prepared_and_print(self, stmtName, 2, params);

    // Deallochiamo lo statement per evitare conflitti nelle esecuzioni future
    PQclear(PQexec(self->conn, "DEALLOCATE get_user_spending;"));
}

void dbcs_query_fit_users(DBCS *self, const char *start_time, const char *end_time)
{
    // Q3: Classifica utenti "più fit" in base ai minuti in bicicletta
    const char *stmtName = "get_fit_users";
    const char *sql =
        "SELECT n.UtenteEmail, "
        "       ROUND(SUM(EXTRACT(EPOCH FROM (COALESCE(n.DataOraFine, CURRENT_TIMESTAMP) - n.DataOraInizio)) / 60)) AS min_bici "
        "FROM Noleggio n "
        "JOIN Bicicletta b ON n.Veicolo = b.Veicolo "
        "WHERE COALESCE(n.DataOraFine, CURRENT_TIMESTAMP) BETWEEN $1::timestamp AND $2::timestamp "
        "GROUP BY n.UtenteEmail "
        "HAVING ROUND(SUM(EXTRACT(EPOCH FROM (COALESCE(n.DataOraFine, CURRENT_TIMESTAMP) - n.DataOraInizio)) / 60)) > 0 "
        "ORDER BY min_bici DESC;";

    PGresult *prep = PQprepare(self->conn, stmtName, sql, 2, NULL);
    if (PQresultStatus(prep) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore preparazione query utenti fit: %s\n", PQerrorMessage(self->conn));
        PQclear(prep);
        return;
    }
    PQclear(prep);

    const char *params[2] = { start_time, end_time };
    printf("\n=== UTENTI 'FIT': MINUTI COMPLESSIVI PERCORSI IN BICICLETTA ===\n");
    printf("Intervallo: da %s a %s\n", start_time, end_time);
    dbcs_exec_prepared_and_print(self, stmtName, 2, params);

    PQclear(PQexec(self->conn, "DEALLOCATE get_fit_users;"));
}

void dbcs_query_city_resources(DBCS *self)
{
    // Q4: Ottiene il conteggio delle capacità delle rastrelliere e prese di ricarica per città
    static const char *sql =
        "WITH CittaDisponibili AS ( "
        "    SELECT DISTINCT Citta FROM Zona "
        "    UNION "
        "    SELECT DISTINCT Citta FROM Hub "
        "), "
        "ConteggioRastrelliere AS ( "
        "    SELECT ZonaCitta AS Citta, SUM(MaxPosti) AS num_rastrelliere "
        "    FROM Rastrelliera "
        "    GROUP BY ZonaCitta "
        "), "
        "ConteggioPuntiRicarica AS ( "
        "    SELECT HubCitta AS Citta, COUNT(*) AS num_punti_ricarica "
        "    FROM PuntoRicarica "
        "    GROUP BY HubCitta "
        ") "
        "SELECT c.Citta, "
        "       COALESCE(r.num_rastrelliere, 0) AS posti_bici, "
        "       COALESCE(p.num_punti_ricarica, 0) AS prese "
        "FROM CittaDisponibili c "
        "LEFT JOIN ConteggioRastrelliere r ON c.Citta = r.Citta "
        "LEFT JOIN ConteggioPuntiRicarica p ON c.Citta = p.Citta "
        "ORDER BY c.Citta;";

    dbcs_exec_and_print(self, "RISORSE COMPLESSIVE (POSTI BICI E PRESE RICARICA) PER CITTA'", sql);
}

void dbcs_query_free_slots_by_zone(DBCS *self)
{
    // Q5: Calcola i posti liberi totali in ogni singola zona
    static const char *sql =
        "WITH CapacitaZona AS ( "
        "    SELECT ZonaCitta, ZonaNome, SUM(MaxPosti) AS posti_totali "
        "    FROM Rastrelliera "
        "    GROUP BY ZonaCitta, ZonaNome "
        "), "
        "BiciParcheggiate AS ( "
        "    SELECT RastrellieraCitta AS ZonaCitta, RastrellieraNome AS ZonaNome, COUNT(Veicolo) AS bici_presenti "
        "    FROM Bicicletta "
        "    WHERE RastrellieraCitta IS NOT NULL "
        "    GROUP BY RastrellieraCitta, RastrellieraNome "
        ") "
        "SELECT c.ZonaCitta AS \"Città\", "
        "       c.ZonaNome AS \"Zona\", "
        "       (c.posti_totali - COALESCE(b.bici_presenti, 0)) AS liberi "
        "FROM CapacitaZona c "
        "LEFT JOIN BiciParcheggiate b ON c.ZonaCitta = b.ZonaCitta AND c.ZonaNome = b.ZonaNome "
        "ORDER BY c.ZonaCitta, c.ZonaNome;";

    dbcs_exec_and_print(self, "POSTI LIBERI TOTALI NELLE RASTRELLIERE PER OGNI ZONA", sql);
}