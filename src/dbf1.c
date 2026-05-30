#include "dbf1.h"
#include "table_render.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <libpq-fe.h>

/* -----------------------------------------------------------------------
 * Helpers interni
 * ----------------------------------------------------------------------- */

static void clear_stdin_line(void)
{
    int c;
    while ((c = getchar()) != '\n' && c != EOF)
        /* discard */;
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
        printf("(nessun risultato)\n");
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
 * Ciclo di vita
 * ----------------------------------------------------------------------- */

int dbf1_connect(DBF1 *self, const char *connstr)
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

void dbf1_disconnect(DBF1 *self)
{
    if (self->conn) {
        PQfinish(self->conn);
        self->conn = NULL;
    }
    self->last_error = 0;
    self->error_msg[0] = '\0';
}

/* -----------------------------------------------------------------------
 * Esecuzione query
 * ----------------------------------------------------------------------- */

void dbf1_exec_and_print(DBF1 *self,
                         const char *title,
                         const char *sql)
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

/** Esegue una query preparata e stampa il risultato */
void dbf1_exec_prepared_and_print(DBF1 *self, 
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

PGresult *dbf1_exec_or_die(DBF1 *self,
                            const char *context,
                            const char *sql)
{
    PGresult *res = PQexec(self->conn, sql);
    ExecStatusType st = PQresultStatus(res);

    if (st != PGRES_TUPLES_OK && st != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore fatale durante: %s\n%s\n",
                context, PQerrorMessage(self->conn));
        PQclear(res);
        dbf1_disconnect(self);
        exit(1);
    }
    return res;
}

/* -----------------------------------------------------------------------
 * Utility interattive
 * ----------------------------------------------------------------------- */

int dbf1_choose_from_pool(DBF1 *self,
                          const char *title,
                          const char *sql,
                          int col_display_idx,
                          char *out,
                          size_t out_len)
{
    printf("\n=== %s ===\n", title);
    PGresult *res = dbf1_exec_or_die(self, title, sql);

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
        const char *v = PQgetisnull(res, i, col_display_idx)
                        ? ""
                        : PQgetvalue(res, i, col_display_idx);
        printf("%d) %s\n", i + 1, v);
    }

    int choice = read_int_in_range("Seleziona: ", 1, rows);
    const char *sel = PQgetvalue(res, choice - 1, col_display_idx);

    strncpy(out, sel, out_len);
    out[out_len - 1] = '\0';

    PQclear(res);
    return 1;
}

int dbf1_choose_from_pool_prepared(DBF1 *self,
                                   const char *title,
                                   const char *stmtName,
                                   int nParams,
                                   const char *const *paramValues,
                                   int col_display_idx,
                                   char *out,
                                   size_t out_len)
{
    printf("\n=== %s ===\n", title);

    // Esecuzione dello statement preparato
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
        fprintf(stderr, "Errore: indice colonna %d non valido (totale colonne: %d)\n", col_display_idx, cols);
        PQclear(res);
        return 0;
    }

    // Stampa le opzioni numerate
    for (int i = 0; i < rows; i++) {
        const char *v = PQgetisnull(res, i, col_display_idx) ? "NULL" : PQgetvalue(res, i, col_display_idx);
        printf("%d) %s\n", i + 1, v);
    }

    // Input utente con validazione (usa la funzione helper read_int_in_range che avevi già)
    int choice = read_int_in_range("Seleziona: ", 1, rows);
    
    // Recupero del valore scelto
    const char *sel = PQgetvalue(res, choice - 1, col_display_idx);
    strncpy(out, sel, out_len);
    out[out_len - 1] = '\0';

    PQclear(res);
    return 1;
}

int dbf1_choose_track_then_date_prepared(DBF1 *self, char *out_track, size_t out_track_len, char *out_date, size_t out_date_len)
{
    // 1. Scegli il circuito (Query senza parametri, usiamo uno statement generico)
    const char *q_tracks = "SELECT DISTINCT Circuito FROM Gara ORDER BY Circuito ASC;";
    PQclear(PQprepare(self->conn, "prep_list_tracks", q_tracks, 0, NULL));
    
    if (!dbf1_choose_from_pool_prepared(self, "CIRCUITI", "prep_list_tracks", 0, NULL, 0, out_track, out_track_len))
        return 0;

    // 2. Scegli la data filtrata per il circuito scelto
    const char *q_dates = "SELECT DISTINCT Data FROM Gara WHERE Circuito = $1 ORDER BY Data ASC;";
    PQclear(PQprepare(self->conn, "prep_list_dates", q_dates, 1, NULL));

    const char *params[] = { out_track };
    if (!dbf1_choose_from_pool_prepared(self, "DATE DISPONIBILI", "prep_list_dates", 1, params, 0, out_date, out_date_len))
        return 0;

    return 1;
}

/* -----------------------------------------------------------------------
 * Query di dominio
 * ----------------------------------------------------------------------- */

void dbf1_query_driver_standings(DBF1 *self)
{
    static const char *sql =
        "SELECT P.Nome, P.Cognome, SUM(R.Punti) AS PuntiTotali "
        "FROM Risultato R "
        "JOIN Persona P ON R.Pilota = P.CF "
        "GROUP BY R.Pilota, P.Nome, P.Cognome "
        "ORDER BY PuntiTotali DESC;";

    dbf1_exec_and_print(self, "CLASSIFICA MONDIALE STORICA PILOTI", sql);
}

void dbf1_query_frequent_circuits(DBF1 *self)
{
    static const char *sql =
        "SELECT C.Nome AS NomeCircuito, C.Paese, "
        "       COUNT(G.Data) AS NumeroGareOspitate "
        "FROM Circuito C "
        "JOIN Gara G ON C.Nome = G.Circuito "
        "GROUP BY C.Nome, C.Paese "
        "HAVING COUNT(G.Data) > 1 "
        "ORDER BY NumeroGareOspitate DESC;";

    dbf1_exec_and_print(self, "CIRCUITI PIU' FREQUENTI NEI CAMPIONATI", sql);
}

void dbf1_query_team_financials(DBF1 *self)
{
    static const char *sql =
        "SELECT S.Nome AS Scuderia, S.Sede, "
        "       COUNT(C.Persona)   AS NumeroTotaleContratti, "
        "       SUM(C.Stipendio)   AS SpesaStipendiTotale "
        "FROM Scuderia S "
        "JOIN Contratto C ON S.Nome = C.Scuderia "
        "GROUP BY S.Nome, S.Sede "
        "ORDER BY SpesaStipendiTotale DESC;";

    dbf1_exec_and_print(self,
        "ANALISI FINANZIARIA E RISORSE DELLE SCUDERIE", sql);
}

void dbf1_query_fastest_laps(DBF1 *self, const char *circuito, const char *data)
{
    const char *stmtName = "get_fastest_laps";
    const char *sql = 
        "SELECT p.Nome || ' ' || p.Cognome AS Pilota, pa.Vettura AS Auto, "
        "g.GaraCircuito AS Circuito, g.GaraData AS Data_Gara, g.NGiro AS Numero_Giro, "
        "g.GommaUsata, (g.Settore1 + g.Settore2 + g.Settore3) AS Tempo_Giro "
        "FROM Giro g "
        "JOIN Persona p ON g.Pilota = p.CF "
        "JOIN Partecipazione pa ON g.Pilota = pa.Pilota "
        "   AND g.GaraCircuito = pa.GaraCircuito AND g.GaraData = pa.GaraData "
        "WHERE g.GaraData = $1 AND g.GaraCircuito = $2 " // <--- Segnaposti
        "AND (g.Settore1 + g.Settore2 + g.Settore3) = ("
        "    SELECT MIN(g2.Settore1 + g2.Settore2 + g2.Settore3) "
        "    FROM Giro g2 WHERE g2.Pilota = g.Pilota "
        "    AND g2.GaraData = g.GaraData AND g2.GaraCircuito = g.GaraCircuito);";

    // 1. Prepariamo lo statement (se non già fatto, o sovrascrivendo)
    PGresult *prep = PQprepare(self->conn, stmtName, sql, 2, NULL);
    if (PQresultStatus(prep) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore preparazione: %s\n", PQerrorMessage(self->conn));
        PQclear(prep);
        return;
    }
    PQclear(prep);

    // 2. Eseguiamo passando i parametri
    const char *params[2] = { data, circuito };
    printf("\n=== GIRO PIU' VELOCE PER OGNI PILOTA ===\n");
    dbf1_exec_prepared_and_print(self, stmtName, 2, params);
}

void dbf1_query_live_standings(DBF1 *self,
                                const char *circuito,
                                const char *data)
{
    /* 1) crea/aggiorna le viste */
    static const char *views_sql =
        "CREATE OR REPLACE VIEW Vista_Gomma_Attuale AS "
        "SELECT DISTINCT GaraData, GaraCircuito, Pilota, "
        "    FIRST_VALUE(GommaUsata) OVER ( "
        "        PARTITION BY GaraData, GaraCircuito, Pilota "
        "        ORDER BY NGiro DESC "
        "    ) AS Ultima_Gomma "
        "FROM Giro; "

        "CREATE OR REPLACE VIEW Vista_Tempo_Attuale AS "
        "SELECT g.GaraData, g.GaraCircuito, "
        "    p.Nome || ' ' || p.Cognome AS Nome_Pilota, "
        "    pa.Vettura, "
        "    COUNT(g.NGiro)                          AS Giri_Completati, "
        "    SUM(g.Settore1 + g.Settore2 + g.Settore3) AS Tempo_Totale "
        "FROM Giro g "
        "JOIN Partecipazione pa ON g.Pilota = pa.Pilota "
        "    AND g.GaraData = pa.GaraData "
        "    AND g.GaraCircuito = pa.GaraCircuito "
        "JOIN Persona p ON g.Pilota = p.CF "
        "GROUP BY g.GaraData, g.GaraCircuito, g.Pilota, "
        "         pa.Vettura, p.Nome, p.Cognome; "

        "CREATE OR REPLACE VIEW Vista_Classifica_Posizioni AS "
        "SELECT *, "
        "    RANK() OVER ( "
        "        PARTITION BY GaraData, GaraCircuito "
        "        ORDER BY Giri_Completati DESC, Tempo_Totale ASC "
        "    ) AS Posizione "
        "FROM Vista_Tempo_Attuale; "

        "CREATE OR REPLACE VIEW Vista_Classifica_Live_Scomposta AS "
        "SELECT *, "
        "    Tempo_Totale - FIRST_VALUE(Tempo_Totale) OVER ( "
        "        PARTITION BY GaraData, GaraCircuito "
        "        ORDER BY Posizione ASC "
        "    ) AS Gap "
        "FROM Vista_Classifica_Posizioni;";

    PGresult *vres = PQexec(self->conn, views_sql);
    if (PQresultStatus(vres) != PGRES_COMMAND_OK) {
        fprintf(stderr, "Errore creazione viste:\n%s\n",
                PQerrorMessage(self->conn));
        PQclear(vres);
        self->last_error = 1;
        return;
    }
    PQclear(vres);

    /* 2) interroga la vista con i parametri */
    char circ_esc[256], data_esc[64];
    int err1 = 0, err2 = 0;
    PQescapeStringConn(self->conn, circ_esc, circuito,
                       strlen(circuito), &err1);
    PQescapeStringConn(self->conn, data_esc, data,
                       strlen(data), &err2);
    if (err1 || err2) {
        fprintf(stderr, "Errore escape parametri live_standings.\n");
        return;
    }

    char sql[512];
    snprintf(sql, sizeof(sql),
             "SELECT * FROM Vista_Classifica_Live_Scomposta "
             "WHERE GaraData = '%s' AND GaraCircuito = '%s';",
             data_esc, circ_esc);

    dbf1_exec_and_print(self,
        "CLASSIFICA LIVE E STRATEGIA GOMME (VISTE)", sql);
}
