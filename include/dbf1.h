#ifndef DBF1_H
#define DBF1_H

#include <libpq-fe.h>
#include "table_render.h"

/* -----------------------------------------------------------------------
 * DBF1 — "oggetto" che incapsula la connessione al DB F1
 *
 * Convenzione:
 *   - ogni funzione che opera sull'oggetto riceve DBF1 *self come primo arg
 *   - il nome segue il pattern  dbf1_<verbo>_<complemento>
 *   - le funzioni di query parametrizzate ricevono i parametri dopo self
 * ----------------------------------------------------------------------- */

typedef struct {
    PGconn *conn;           /* connessione libpq attiva                  */
    int     last_error;     /* 0 = ok, 1 = errore nell'ultima operazione */
    char    error_msg[512]; /* messaggio dell'ultimo errore               */
} DBF1;

/* -----------------------------------------------------------------------
 * Ciclo di vita
 * ----------------------------------------------------------------------- */

/**
 * Apre la connessione e inizializza self.
 * @param self    struttura da inizializzare (già allocata)
 * @param connstr stringa di connessione libpq (es. "user=... dbname=...")
 * @return 0 successo, 1 errore (self->error_msg contiene i dettagli)
 */
int dbf1_connect(DBF1 *self, const char *connstr);

/**
 * Chiude la connessione e azzera i campi.
 */
void dbf1_disconnect(DBF1 *self);

/* -----------------------------------------------------------------------
 * Esecuzione query
 * ----------------------------------------------------------------------- */

/**
 * Esegue una query e stampa il risultato come tabella ASCII.
 * In caso di errore stampa su stderr e imposta self->last_error.
 */
void dbf1_exec_and_print(DBF1 *self,
                         const char *title,
                         const char *sql);

/**
 * Esegue una query e ritorna il PGresult.
 * In caso di errore: stampa su stderr, imposta last_error, esce dal processo.
 * Il chiamante è responsabile di PQclear() sul risultato.
 */
PGresult *dbf1_exec_or_die(DBF1 *self,
                            const char *context,
                            const char *sql);

/* -----------------------------------------------------------------------
 * Utility interattive
 * ----------------------------------------------------------------------- */

/**
 * Mostra una lista numerata dei valori nella colonna col_display_idx
 * del risultato di sql, fa scegliere all'utente un elemento,
 * e copia il valore in out (max out_len byte).
 * @return 1 se la scelta è avvenuta, 0 se non ci sono righe disponibili.
 */
int dbf1_choose_from_pool(DBF1 *self,
                          const char *title,
                          const char *sql,
                          int col_display_idx,
                          char *out,
                          size_t out_len);

/**
 * Guida l'utente a scegliere prima un circuito poi una data.
 * Scrive i valori scelti in out_track e out_date.
 * @return 1 successo, 0 se non ci sono dati disponibili.
 */
int dbf1_choose_track_then_date(DBF1 *self,
                                char *out_track, size_t out_track_len,
                                char *out_date,  size_t out_date_len);

/* -----------------------------------------------------------------------
 * Query di dominio (le 5 voci del menu)
 * ----------------------------------------------------------------------- */

/** 1) Classifica mondiale storica dei piloti */
void dbf1_query_driver_standings(DBF1 *self);

/** 2) Circuiti con più di una gara ospitata */
void dbf1_query_frequent_circuits(DBF1 *self);

/** 3) Analisi finanziaria delle scuderie */
void dbf1_query_team_financials(DBF1 *self);

/** 4) Giro più veloce per ogni pilota in una gara */
void dbf1_query_fastest_laps(DBF1 *self,
                             const char *circuito,
                             const char *data);

/** 5) Classifica live e strategia gomme (crea viste, poi interroga) */
void dbf1_query_live_standings(DBF1 *self,
                               const char *circuito,
                               const char *data);

#endif /* DBF1_H */
