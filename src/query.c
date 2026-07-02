#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dbcs.h"

static void show_menu(void)
{
    printf("\033[2J\033[H"); /* Pulisce lo schermo ed esegue l'home del cursore (ANSI) */
    printf("====================================================\n");
    printf("        CitySharing Database Query Explorer         \n");
    printf("====================================================\n\n");
    printf("1) Segnalazioni gestite per ciascun operatore\n");
    printf("2) Spesa complessiva utenti in un intervallo di tempo\n");
    printf("3) Classifica Utenti 'Fit' (Minuti totali in bici)\n");
    printf("4) Capacita' totale posti bici e prese di ricarica per citta'\n");
    printf("5) Posti liberi disponibili in ogni zona\n");
    printf("6) Test interattivo: Navigazione Città -> Zona\n");
    printf("0) Esci\n\n");
}

static int read_choice(void)
{
    int v;
    for (;;)
    {
        printf("Seleziona un'opzione: ");
        if (scanf("%d", &v) == 1)
        {
            int c;
            while ((c = getchar()) != '\n' && c != EOF)
                ;
            if (v >= 0 && v <= 6)
                return v;
        }
        else
        {
            int c;
            while ((c = getchar()) != '\n' && c != EOF)
                ;
        }
        printf("Scegli un valore compreso tra 0 e 6.\n");
    }
}

/** Helper per leggere in modo sicuro una stringa (es. timestamp) da tastiera */
static void read_string(const char *prompt, char *out, size_t max_len, const char *default_val)
{
    printf("%s", prompt);
    if (default_val != NULL) {
        printf(" [Default: %s]: ", default_val);
    } else {
        printf(": ");
    }

    if (fgets(out, max_len, stdin) != NULL) {
        // Rimuove il carattere newline finale se presente
        out[strcspn(out, "\n")] = '\0';
        
        // Se l'utente ha premuto solo INVIO, applica il valore di default
        if (strlen(out) == 0 && default_val != NULL) {
            strncpy(out, default_val, max_len);
            out[max_len - 1] = '\0';
        }
    }
}

int main(void)
{
    // Cerca la stringa di connessione dall'ambiente o usa i default del Docker Compose
    const char *conn_str = getenv("DB_CONN");
    if (conn_str == NULL)
    {
        conn_str = "user=postgres password=password dbname=CitySharing host=localhost port=5432";
    }

    DBCS db;
    if (dbcs_connect(&db, conn_str) != 0)
    {
        fprintf(stderr, "%s\n", db.error_msg);
        return 1;
    }

    for (;;)
    {
        show_menu();
        int choice = read_choice();

        if (choice == 0)
            break;

        switch (choice)
        {
        case 1:
            dbcs_query_operator_reports(&db);
            break;

        case 2:
        {
            char start_time[64];
            char end_time[64];
            
            printf("\n--- Ricerca Spesa Utenti ---\n");
            read_string("Inserisci Data/Ora Inizio (YYYY-MM-DD HH:MM:SS)", start_time, sizeof(start_time), "2024-01-01 00:00:00");
            read_string("Inserisci Data/Ora Fine (YYYY-MM-DD HH:MM:SS)", end_time, sizeof(end_time), "2024-12-31 23:59:59");
            
            dbcs_query_user_spending(&db, start_time, end_time);
            break;
        }

        case 3:
        {
            char start_time[64];
            char end_time[64];
            
            printf("\n--- Classifica Utenti Fit (In Bicicletta) ---\n");
            read_string("Inserisci Data/Ora Inizio (YYYY-MM-DD HH:MM:SS)", start_time, sizeof(start_time), "2024-01-01 00:00:00");
            read_string("Inserisci Data/Ora Fine (YYYY-MM-DD HH:MM:SS)", end_time, sizeof(end_time), "2024-12-31 23:59:59");
            
            dbcs_query_fit_users(&db, start_time, end_time);
            break;
        }

        case 4:
            dbcs_query_city_resources(&db);
            break;

        case 5:
            dbcs_query_free_slots_by_zone(&db);
            break;

        case 6:
        {
            char citta[128], zona[128];
            if (dbcs_choose_city_then_zone_prepared(&db, citta, sizeof(citta), zona, sizeof(zona))) {
                printf("\nHai selezionato correttamente:\n");
                printf(" -> Citta': %s\n", citta);
                printf(" -> Zona  : %s\n", zona);
            }
            break;
        }

        default:
            printf("Scelta non valida.\n");
            break;
        }

        printf("\nPremi INVIO per tornare al menu...");
        getchar();
    }

    dbcs_disconnect(&db);
    printf("Disconnessione completata. Alla prossima!\n");
    return 0;
}