#ifndef DBCS_H
#define DBCS_H

#include <libpq-fe.h>
#include <stddef.h>

typedef struct {
    PGconn *conn;
    int last_error;
    char error_msg[512];
} DBCS;

/* Ciclo di vita della connessione */
int dbcs_connect(DBCS *self, const char *connstr);
void dbcs_disconnect(DBCS *self);

/* Esecuzione query generiche */
void dbcs_exec_and_print(DBCS *self, const char *title, const char *sql);
void dbcs_exec_prepared_and_print(DBCS *self, const char *stmtName, int nParams, const char *const *paramValues);
PGresult *dbcs_exec_or_die(DBCS *self, const char *context, const char *sql);

/* Selezioni interattive da pool */
int dbcs_choose_from_pool(DBCS *self, const char *title, const char *sql, int col_display_idx, char *out, size_t out_len);
int dbcs_choose_from_pool_prepared(DBCS *self, const char *title, const char *stmtName, int nParams, const char *const *paramValues, int col_display_idx, char *out, size_t out_len);

/* Helper specifico di dominio: Sceglie prima la città, poi una zona di quella città */
int dbcs_choose_city_then_zone_prepared(DBCS *self, char *out_city, size_t out_city_len, char *out_zone, size_t out_zone_len);

/* -----------------------------------------------------------------------
 * Query di Dominio (Q1 - Q5 adattate)
 * ----------------------------------------------------------------------- */

/* Q1: Mostra per ogni operatore il numero di segnalazioni gestite */
void dbcs_query_operator_reports(DBCS *self);

/* Q2: Guadagni totali per utente in un determinato intervallo temporale (Parametrizzata) */
void dbcs_query_user_spending(DBCS *self, const char *start_time, const char *end_time);

/* Q3: Minuti complessivi in bicicletta per gli utenti "fit" nell'intervallo di tempo (Parametrizzata) */
void dbcs_query_fit_users(DBCS *self, const char *start_time, const char *end_time);

/* Q4: Risorse complessive (posti rastrelliere e prese di ricarica) per ogni città */
void dbcs_query_city_resources(DBCS *self);

/* Q5: Numero di posti liberi per ogni singola zona */
void dbcs_query_free_slots_by_zone(DBCS *self);

#endif /* DBCS_H */