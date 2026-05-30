#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <libpq-fe.h> // Libreria per PostgreSQL

#define CONNECTION "user=postgres password=password dbname=f1_db host=localhost"

// Limiti output tabella
#define MAX_CELL_WIDTH 20
#define MAX_COLUMNS_TO_PRINT 6

static void exit_with_error(PGconn *conn, const char *context) {
    if (context && *context) {
        fprintf(stderr, "[ERRORE] %s\n", context);
    }
    fprintf(stderr, "%s\n", PQerrorMessage(conn));
    PQfinish(conn);
    exit(1);
}

static void clear_stdin_line(void) {
    int c;
    while ((c = getchar()) != '\n' && c != EOF) {
        /* discard */
    }
}

static int read_int_in_range(const char *prompt, int min, int max) {
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

static void print_padded_trunc(const char *s, int width) {
    // stampa al massimo width caratteri, aggiungendo padding a destra
    int len = (int)strlen(s);
    int n = len > width ? width : len;
    fwrite(s, 1, (size_t)n, stdout);
    for (int i = n; i < width; i++) putchar(' ');
}

static void print_result_table(PGresult *res) {
    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (cols == 0) {
        printf("(nessuna colonna)\n");
        return;
    }

    // Se troppe colonne, stampo solo le prime N e avviso
    int cols_to_print = cols;
    if (cols_to_print > MAX_COLUMNS_TO_PRINT) {
        cols_to_print = MAX_COLUMNS_TO_PRINT;
        printf("(tabella molto larga: mostro solo le prime %d colonne su %d)\n\n",
               cols_to_print, cols);
    }

    // Header
    for (int j = 0; j < cols_to_print; j++) {
        const char *name = PQfname(res, j);
        print_padded_trunc(name ? name : "", MAX_CELL_WIDTH);
        if (j < cols_to_print - 1) printf(" | ");
    }
    printf("\n");

    // Separatore
    for (int j = 0; j < cols_to_print; j++) {
        for (int k = 0; k < MAX_CELL_WIDTH; k++) putchar('-');
        if (j < cols_to_print - 1) printf("-+-");
    }
    printf("\n");

    // Righe
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols_to_print; j++) {
            const char *v = PQgetisnull(res, i, j) ? "NULL" : PQgetvalue(res, i, j);
            print_padded_trunc(v ? v : "", MAX_CELL_WIDTH);
            if (j < cols_to_print - 1) printf(" | ");
        }
        printf("\n");
    }

    if (cols_to_print < cols) {
        printf("\nSuggerimento: se vuoi vedere tutte le colonne, lancia l'app con piping: ./app.out | less -S\n");
        printf("(in less: usa frecce sinistra/destra oppure tasti h/l per scorrere orizzontalmente)\n");
    }
}

static void exec_and_print(PGconn *conn, const char *title, const char *sql) {
    printf("\n=== %s ===\n", title);

    PGresult *res = PQexec(conn, sql);
    ExecStatusType st = PQresultStatus(res);

    if (st != PGRES_TUPLES_OK) {
        fprintf(stderr, "Errore nell'esecuzione della query.\n");
        fprintf(stderr, "Query: %s\n", sql);
        fprintf(stderr, "Dettagli: %s\n", PQerrorMessage(conn));
        PQclear(res);
        return;
    }

    if (PQntuples(res) == 0) {
        printf("(nessun risultato)\n");
        PQclear(res);
        return;
    }

    print_result_table(res);
    PQclear(res);
}

static PGresult *exec_or_die(PGconn *conn, const char *context, const char *sql) {
    PGresult *res = PQexec(conn, sql);
    ExecStatusType st = PQresultStatus(res);
    if (!(st == PGRES_TUPLES_OK || st == PGRES_COMMAND_OK)) {
        fprintf(stderr, "Errore durante: %s\n", context);
        fprintf(stderr, "Query: %s\n", sql);
        fprintf(stderr, "Dettagli: %s\n", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        exit(1);
    }
    return res;
}

static int choose_from_pool(PGconn *conn,
                            const char *title,
                            const char *sql,
                            int col_to_display,
                            char *out,
                            size_t out_len) {
    printf("\n=== %s ===\n", title);

    PGresult *res = exec_or_die(conn, title, sql);

    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (rows <= 0) {
        printf("(nessuna scelta disponibile)\n");
        PQclear(res);
        return 0;
    }

    if (col_to_display < 0 || col_to_display >= cols) {
        fprintf(stderr, "Errore interno: col_to_display=%d non valida (cols=%d)\n", col_to_display, cols);
        PQclear(res);
        return 0;
    }

    // stampa pool
    for (int i = 0; i < rows; i++) {
        const char *v = PQgetisnull(res, i, col_to_display) ? "" : PQgetvalue(res, i, col_to_display);
        printf("%d) %s\n", i + 1, v);
    }

    int choice = read_int_in_range("Seleziona: ", 1, rows);
    const char *sel = PQgetvalue(res, choice - 1, col_to_display);

    strncpy(out, sel, out_len);
    out[out_len - 1] = '\0';

    PQclear(res);
    return 1;
}

static int choose_track_then_date(PGconn *conn,
                                 char *out_track,
                                 size_t out_track_len,
                                 char *out_date,
                                 size_t out_date_len) {
    // 1) scegli pista
    // Nota: uso la tabella Gara nello schema relazionale di demo.tex: (Circuito, Data, ...)
    if (!choose_from_pool(conn,
                          "Scegli il circuito",
                          "SELECT DISTINCT Circuito FROM Gara ORDER BY Circuito ASC;",
                          0,
                          out_track,
                          out_track_len)) {
        return 0;
    }

    // 2) scegli data tra le date per quella pista
    // escape del valore circuito per sicurezza (anche se arriva dal DB)
    char track_esc[256];
    int err = 0;
    PQescapeStringConn(conn, track_esc, out_track, strlen(out_track), &err);
    if (err) {
        fprintf(stderr, "Errore escape stringa circuito.\n");
        return 0;
    }

    char sql[512];
    snprintf(sql, sizeof(sql),
             "SELECT DISTINCT Data FROM Gara WHERE Circuito = '%s' ORDER BY Data ASC;",
             track_esc);

    if (!choose_from_pool(conn,
                          "Scegli la data",
                          sql,
                          0,
                          out_date,
                          out_date_len)) {
        return 0;
    }

    printf("Scelta: %s - %s\n", out_track, out_date);
    return 1;
}

static void show_menu(void) {
    // “pseudo TUI”: menu a scelta multipla e schermata pulita
    printf("\033[2J\033[H"); // clear screen + home (ANSI)
    printf("========================================\n");
    printf("   Progetto Basi - Query Explorer (C)   \n");
    printf("========================================\n\n");

    printf("1) Classifica mondiale storica piloti\n");
    printf("2) Circuiti con piu' di una gara\n");
    printf("3) Analisi finanziaria e risorse delle scuderie\n");
    printf("4) Giro piu' veloce per ogni pilota in una gara\n");
    printf("5) Classifica live e strategia gomme (viste)\n");
    printf("0) Esci\n\n");
}

int main(void) {
    PGconn *conn = PQconnectdb(CONNECTION);
    if (PQstatus(conn) == CONNECTION_BAD) {
        exit_with_error(conn, "Connessione al DB fallita");
    }

    for (;;) {
        show_menu();
        int choice = read_int_in_range("Seleziona un'opzione: ", 0, 5);

        if (choice == 0) {
            break;
        }

        switch (choice) {
            case 1: {
                const char *query =
                    "SELECT P.Nome, P.Cognome, SUM(R.Punti) AS PuntiTotali "
                    "FROM Risultato R "
                    "JOIN Persona P ON R.Pilota = P.CF "
                    "GROUP BY R.Pilota, P.Nome, P.Cognome "
                    "ORDER BY PuntiTotali DESC;";

                exec_and_print(conn, "CLASSIFICA MONDIALE STORICA PILOTI", query);
                break;
            }

            case 2: {
                const char *query =
                    "SELECT C.Nome AS NomeCircuito, C.Paese, COUNT(G.Data) AS NumeroGareOspitate "
                    "FROM Circuito C "
                    "JOIN Gara G ON C.Nome = G.Circuito "
                    "GROUP BY C.Nome, C.Paese "
                    "HAVING COUNT(G.Data) > 1 "
                    "ORDER BY NumeroGareOspitate DESC;";

                exec_and_print(conn, "CIRCUITI PIU' FREQUENTI NEI CAMPIONATI", query);
                break;
            }

            case 3: {
                const char *query =
                    "SELECT S.Nome AS Scuderia, S.Sede, "
                    "COUNT(C.Persona) AS NumeroTotaleContratti, "
                    "SUM(C.Stipendio) AS SpesaStipendiTotale "
                    "FROM Scuderia S "
                    "JOIN Contratto C ON S.Nome = C.Scuderia "
                    "GROUP BY S.Nome, S.Sede "
                    "ORDER BY SpesaStipendiTotale DESC;";

                exec_and_print(conn, "ANALISI FINANZIARIA E RISORSE DELLE SCUDERIE", query);
                break;
            }

            case 4: {
                // Parametrizzata via pool: prima circuito, poi data
                char circuito[128];
                char data[32];
                if (!choose_track_then_date(conn, circuito, sizeof(circuito), data, sizeof(data))) {
                    break;
                }

                char circuito_esc[256];
                char data_esc[64];
                int err1 = 0, err2 = 0;
                PQescapeStringConn(conn, circuito_esc, circuito, strlen(circuito), &err1);
                PQescapeStringConn(conn, data_esc, data, strlen(data), &err2);
                if (err1 || err2) {
                    fprintf(stderr, "Errore escape parametri.\n");
                    break;
                }

                char sql[4096];
                // Nota: per semplicita' usiamo string formatting. In produzione andrebbero usate query parametrizzate.
                snprintf(sql, sizeof(sql),
                         "SELECT "
                         "  p.Nome || ' ' || p.Cognome AS Pilota, "
                         "  pa.Vettura AS Auto, "
                         "  g.GaraCircuito AS Circuito, "
                         "  g.GaraData AS Data_Gara, "
                         "  g.NGiro AS Numero_Giro, "
                         "  g.GommaUsata, "
                         "  (g.Settore1 + g.Settore2 + g.Settore3) AS Tempo_Giro "
                         "FROM Giro g "
                         "JOIN Persona p ON g.Pilota = p.CF "
                         "JOIN Partecipazione pa ON g.Pilota = pa.Pilota "
                         "                   AND g.GaraCircuito = pa.GaraCircuito "
                         "                   AND g.GaraData = pa.GaraData "
                         "WHERE g.GaraData = '%s' "
                         "  AND g.GaraCircuito = '%s' "
                         "  AND (g.Settore1 + g.Settore2 + g.Settore3) = ("
                         "      SELECT MIN(g2.Settore1 + g2.Settore2 + g2.Settore3) "
                         "      FROM Giro g2 "
                         "      WHERE g2.Pilota = g.Pilota "
                         "        AND g2.GaraData = g.GaraData "
                         "        AND g2.GaraCircuito = g.GaraCircuito"
                         "  );",
                         data_esc, circuito_esc);

                exec_and_print(conn, "GIRO PIU' VELOCE PER OGNI PILOTA IN UNA GARA", sql);
                break;
            }

            case 5: {
                // Parametrizzata via pool: prima circuito, poi data
                char circuito[128];
                char data[32];
                if (!choose_track_then_date(conn, circuito, sizeof(circuito), data, sizeof(data))) {
                    break;
                }

                char circuito_esc[256];
                char data_esc[64];
                int err1 = 0, err2 = 0;
                PQescapeStringConn(conn, circuito_esc, circuito, strlen(circuito), &err1);
                PQescapeStringConn(conn, data_esc, data, strlen(data), &err2);
                if (err1 || err2) {
                    fprintf(stderr, "Errore escape parametri.\n");
                    break;
                }

                // 1) Creazione (o aggiornamento) viste
                const char *views_sql =
                    "CREATE OR REPLACE VIEW Vista_Gomma_Attuale AS "
                    "SELECT DISTINCT "
                    "    GaraData, "
                    "    GaraCircuito, "
                    "    Pilota, "
                    "    FIRST_VALUE(GommaUsata) OVER ( "
                    "        PARTITION BY GaraData, GaraCircuito, Pilota "
                    "        ORDER BY NGiro DESC "
                    "    ) AS Ultima_Gomma "
                    "FROM Giro; "
                    " "
                    "CREATE OR REPLACE VIEW Vista_Tempo_Attuale AS "
                    "SELECT "
                    "    g.GaraData, "
                    "    g.GaraCircuito, "
                    "    p.Nome || ' ' || p.Cognome AS Nome_Pilota, "
                    "    pa.Vettura, "
                    "    COUNT(g.NGiro) AS Giri_Completati, "
                    "    SUM(g.Settore1 + g.Settore2 + g.Settore3) AS Tempo_Totale "
                    "FROM Giro g "
                    "JOIN Partecipazione pa ON g.Pilota = pa.Pilota "
                    "                 AND g.GaraData = pa.GaraData "
                    "                 AND g.GaraCircuito = pa.GaraCircuito "
                    "JOIN Persona p ON g.Pilota = p.CF "
                    "GROUP BY g.GaraData, g.GaraCircuito, g.Pilota, pa.Vettura, p.Nome, p.Cognome; "
                    " "
                    "CREATE OR REPLACE VIEW Vista_Classifica_Posizioni AS "
                    "SELECT *, "
                    "    RANK() OVER ( "
                    "        PARTITION BY GaraData, GaraCircuito "
                    "        ORDER BY Giri_Completati DESC, Tempo_Totale ASC "
                    "    ) AS Posizione "
                    "FROM Vista_Tempo_Attuale; "
                    " "
                    "CREATE OR REPLACE VIEW Vista_Classifica_Live_Scomposta AS "
                    "SELECT *, "
                    "    Tempo_Totale - FIRST_VALUE(Tempo_Totale) OVER ( "
                    "        PARTITION BY GaraData, GaraCircuito "
                    "        ORDER BY Posizione ASC "
                    "    ) AS Gap "
                    "FROM Vista_Classifica_Posizioni;";

                PGresult *vres = PQexec(conn, views_sql);
                ExecStatusType vst = PQresultStatus(vres);
                if (vst != PGRES_COMMAND_OK) {
                    fprintf(stderr, "Errore nella creazione delle viste.\n");
                    fprintf(stderr, "Dettagli: %s\n", PQerrorMessage(conn));
                    PQclear(vres);
                    break;
                }
                PQclear(vres);

                // 2) Query finale su vista
                char sql[2048];
                snprintf(sql, sizeof(sql),
                         "SELECT * FROM Vista_Classifica_Live_Scomposta c "
                         "WHERE c.GaraData = '%s' AND c.GaraCircuito = '%s';",
                         data_esc, circuito_esc);

                exec_and_print(conn, "CLASSIFICA LIVE E STRATEGIA GOMME (VISTE)", sql);
                break;
            }

            default:
                // Non dovrebbe succedere per via del range check
                printf("Scelta non valida.\n");
                break;
        }

        printf("\nPremi INVIO per tornare al menu...");
        getchar();
    }

    PQfinish(conn);
    printf("Uscita.\n");
    return 0;
}
