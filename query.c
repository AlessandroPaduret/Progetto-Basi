#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <libpq-fe.h> // Libreria per PostgreSQL

#define CONNECTION "user=postgres password=password dbname=progetto_basi host=localhost"

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

static void print_result_table(PGresult *res) {
    int rows = PQntuples(res);
    int cols = PQnfields(res);

    if (cols == 0) {
        printf("(nessuna colonna)\n");
        return;
    }

    // Stampa header colonne
    for (int j = 0; j < cols; j++) {
        printf("%-25s", PQfname(res, j));
        if (j < cols - 1) printf(" | ");
    }
    printf("\n");

    // Separatore semplice
    for (int j = 0; j < cols; j++) {
        printf("-------------------------");
        if (j < cols - 1) printf("-+-");
    }
    printf("\n");

    // Righe
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            const char *v = PQgetisnull(res, i, j) ? "NULL" : PQgetvalue(res, i, j);
            printf("%-25.25s", v);
            if (j < cols - 1) printf(" | ");
        }
        printf("\n");
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

static void show_menu(void) {
    // “pseudo TUI”: menu a scelta multipla e schermata pulita
    printf("\033[2J\033[H"); // clear screen + home (ANSI)
    printf("========================================\n");
    printf("   Progetto Basi - Query Explorer (C)   \n");
    printf("========================================\n\n");

    printf("1) Classifica mondiale storica piloti\n");
    printf("2) Circuiti con piu' di una gara\n");
    printf("0) Esci\n\n");
}

int main(void) {
    PGconn *conn = PQconnectdb(CONNECTION);
    if (PQstatus(conn) == CONNECTION_BAD) {
        exit_with_error(conn, "Connessione al DB fallita");
    }

    for (;;) {
        show_menu();
        int choice = read_int_in_range("Seleziona un'opzione: ", 0, 2);

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
                    "SELECT C.Nome AS Circuito, C.Paese, COUNT(G.Data) AS NumeroGare "
                    "FROM Circuito C "
                    "JOIN Gara G ON C.Nome = G.Circuito "
                    "GROUP BY C.Nome, C.Paese "
                    "HAVING COUNT(G.Data) > 1 "
                    "ORDER BY NumeroGare DESC;";

                exec_and_print(conn, "CIRCUITI CON PIU' DI UNA GARA", query);
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
