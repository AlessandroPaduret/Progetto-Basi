#include <stdio.h>
#include <stdlib.h>
#include <libpq-fe.h> // Libreria per PostgreSQL

#define CONNECTION "user=postgres password=password dbname=progetto_basi host=localhost"

void exit_with_error(PGconn *conn) {
    fprintf(stderr, "%s\n", PQerrorMessage(conn));
    PQfinish(conn);
    exit(1);
}

int main() {
    // 1. Connessione al database
    // Sostituisci i parametri con i tuoi dati reali
    PGconn *conn = PQconnectdb(CONNECTION);

    if (PQstatus(conn) == CONNECTION_BAD) {
        exit_with_error(conn);
    }

    printf("Connessione al simulatore F1 riuscita!\n\n");

    // --- ESECUZIONE QUERY 2: Classifica Piloti ---
    printf("--- CLASSIFICA MONDIALE STORICA PILOTI ---\n");
    
    const char *query2 = "SELECT P.Nome, P.Cognome, SUM(R.Punti) AS PuntiTotali "
                         "FROM Risultato R "
                         "JOIN Persona P ON R.Pilota = P.CF "
                         "GROUP BY R.Pilota, P.Nome, P.Cognome "
                         "ORDER BY PuntiTotali DESC;";

    PGresult *res = PQexec(conn, query2);

    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        printf("Errore nella query classifica.\n");
        PQclear(res);
    } else {
        int rows = PQntuples(res);
        for (int i = 0; i < rows; i++) {
            printf("%d. %-15s %-15s | Punti: %s\n", 
                   i + 1, 
                   PQgetvalue(res, i, 0), 
                   PQgetvalue(res, i, 1), 
                   PQgetvalue(res, i, 2));
        }
    }
    PQclear(res);

    printf("\n------------------------------------------\n");

    // --- ESECUZIONE QUERY 4: Circuiti Popolari ---
    printf("--- CIRCUITI CON PIU' DI UNA GARA ---\n");

    const char *query4 = "SELECT C.Nome, C.Paese, COUNT(G.Data) "
                         "FROM Circuito C "
                         "JOIN Gara G ON C.Nome = G.Circuito "
                         "GROUP BY C.Nome, C.Paese "
                         "HAVING COUNT(G.Data) > 1;";

    res = PQexec(conn, query4);

    if (PQresultStatus(res) == PGRES_TUPLES_OK) {
        int rows = PQntuples(res);
        for (int i = 0; i < rows; i++) {
            printf("Circuito: %-20s | Paese: %-15s | Gare: %s\n", 
                   PQgetvalue(res, i, 0), 
                   PQgetvalue(res, i, 1), 
                   PQgetvalue(res, i, 2));
        }
    }
    PQclear(res);

    // 4. Chiusura connessione
    PQfinish(conn);
    return 0;
}