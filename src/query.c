#include <stdio.h>
#include <stdlib.h>

#include "dbf1.h"

#define CONNECTION \
    "user=postgres password=password dbname=Simulatore_F1 host=localhost"

static void show_menu(void)
{
    printf("\033[2J\033[H"); /* clear screen + home (ANSI) */
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

static int read_choice(void)
{
    int v;
    for (;;) {
        printf("Seleziona un'opzione: ");
        if (scanf("%d", &v) == 1) {
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
            if (v >= 0 && v <= 5)
                return v;
        } else {
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
        }
        printf("Scegli un valore tra 0 e 5.\n");
    }
}

int main(void)
{
    DBF1 db;
    if (dbf1_connect(&db, CONNECTION) != 0) {
        fprintf(stderr, "%s\n", db.error_msg);
        return 1;
    }

    for (;;) {
        show_menu();
        int choice = read_choice();

        if (choice == 0)
            break;

        switch (choice) {
        case 1:
            dbf1_query_driver_standings(&db);
            break;

        case 2:
            dbf1_query_frequent_circuits(&db);
            break;

        case 3:
            dbf1_query_team_financials(&db);
            break;

        case 4: {
            char circuito[128], data[32];
            if (dbf1_choose_track_then_date(&db,
                    circuito, sizeof(circuito),
                    data,     sizeof(data)))
                dbf1_query_fastest_laps(&db, circuito, data);
            break;
        }

        case 5: {
            char circuito[128], data[32];
            if (dbf1_choose_track_then_date(&db,
                    circuito, sizeof(circuito),
                    data,     sizeof(data)))
                dbf1_query_live_standings(&db, circuito, data);
            break;
        }

        default:
            printf("Scelta non valida.\n");
            break;
        }

        printf("\nPremi INVIO per tornare al menu...");
        getchar();
    }

    dbf1_disconnect(&db);
    printf("Uscita.\n");
    return 0;
}
