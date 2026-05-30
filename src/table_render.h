#ifndef TABLE_RENDER_H
#define TABLE_RENDER_H

#include <stddef.h>

/* Tipi OID PostgreSQL usati per rilevare colonne numeriche */
#define OID_INT2    21
#define OID_INT4    23
#define OID_INT8    20
#define OID_FLOAT4  700
#define OID_FLOAT8  701
#define OID_NUMERIC 1700

#define TABLE_MAX_CELL_WIDTH     14
#define TABLE_MAX_CELL_WIDTH_NUM 10
#define TABLE_DEFAULT_TERM_WIDTH 120

/* -----------------------------------------------------------------------
 * TableLayout
 * Contiene le larghezze per colonna e quante colonne entrano a schermo.
 * Allocata dinamicamente: usare table_layout_free() dopo l'uso.
 * ----------------------------------------------------------------------- */
typedef struct {
    int *col_widths;    /* array[num_cols] di larghezze calcolate */
    int  num_cols;      /* numero totale di colonne nella query     */
    int  cols_to_print; /* quante colonne entrano nel terminale     */
} TableLayout;

/* -----------------------------------------------------------------------
 * API pubblica
 * ----------------------------------------------------------------------- */

/**
 * Ritorna 1 se l'OID PostgreSQL corrisponde a un tipo numerico.
 */
int table_is_numeric_oid(unsigned int oid);

/**
 * Calcola la larghezza ottimale per una singola colonna.
 * @param header    nome della colonna
 * @param values    array di stringhe (righe), può contenere NULL (→ "NULL")
 * @param num_rows  numero di righe
 * @param max_width larghezza massima consentita
 * @return larghezza calcolata (min 4, max max_width)
 */
int table_compute_col_width(const char *header,
                            const char * const *values,
                            int num_rows,
                            int max_width);

/**
 * Calcola quante colonne entrano in term_width caratteri di terminale.
 * @param col_widths array di larghezze per colonna
 * @param num_cols   numero di colonne
 * @param term_width larghezza disponibile
 * @return numero di colonne che ci stanno (almeno 1)
 */
int table_compute_cols_that_fit(const int *col_widths,
                                int num_cols,
                                int term_width);

/**
 * Stampa la stringa s troncata e paddata fino a width caratteri.
 */
void table_print_cell(const char *s, int width);

/**
 * Alloca e popola un TableLayout dato un risultato PGresult.
 * Dipende da libpq.
 * @return puntatore allocato o NULL in caso di errore di memoria.
 */
#ifdef LIBPQ_FE_H
TableLayout *table_layout_from_pgresult(PGresult *res);
#endif

/**
 * Libera un TableLayout allocato da table_layout_from_pgresult.
 */
void table_layout_free(TableLayout *layout);

/**
 * Stampa una riga separatrice in base alle larghezze e al numero di colonne.
 */
void table_print_separator(const int *col_widths, int cols_to_print);

#endif /* TABLE_RENDER_H */
