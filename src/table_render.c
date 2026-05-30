#include "table_render.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* -----------------------------------------------------------------------
 * Funzioni pure (no libpq) — testabili con unit test
 * ----------------------------------------------------------------------- */

int table_is_numeric_oid(unsigned int oid)
{
    return (oid == OID_INT2  ||
            oid == OID_INT4  ||
            oid == OID_INT8  ||
            oid == OID_FLOAT4 ||
            oid == OID_FLOAT8 ||
            oid == OID_NUMERIC);
}

int table_compute_col_width(const char *header,
                            const char * const *values,
                            int num_rows,
                            int max_width)
{
    int width = 0;

    /* larghezza header */
    if (header) {
        int hlen = (int)strlen(header);
        if (hlen > width)
            width = hlen;
    }

    /* larghezza massima tra i valori */
    for (int i = 0; i < num_rows; i++) {
        const char *v = values[i] ? values[i] : "NULL";
        int len = (int)strlen(v);
        if (len > width)
            width = len;
        if (width >= max_width) {
            width = max_width;
            break;
        }
    }

    /* minimo 4 per mantenere la struttura della tabella */
    if (width < 4)
        width = 4;
    if (width > max_width)
        width = max_width;

    return width;
}

int table_compute_cols_that_fit(const int *col_widths,
                                int num_cols,
                                int term_width)
{
    if (!col_widths || num_cols <= 0)
        return 0;

    int used = 0;
    int n    = 0;

    for (int j = 0; j < num_cols; j++) {
        /* prima colonna: solo la sua larghezza;
           le successive aggiungono " | " (3 char) */
        int add = col_widths[j] + (j > 0 ? 3 : 0);
        if (used + add > term_width)
            break;
        used += add;
        n++;
    }

    /* almeno 1 colonna sempre visibile */
    if (n < 1 && num_cols > 0)
        n = 1;

    return n;
}

void table_print_cell(const char *s, int width)
{
    if (!s) s = "";
    int len = (int)strlen(s);
    int n   = (len > width) ? width : len;
    fwrite(s, 1, (size_t)n, stdout);
    for (int i = n; i < width; i++)
        putchar(' ');
}

void table_print_separator(const int *col_widths, int cols_to_print)
{
    for (int j = 0; j < cols_to_print; j++) {
        for (int k = 0; k < col_widths[j]; k++)
            putchar('-');
        if (j < cols_to_print - 1)
            printf("-+-");
    }
    printf("\n");
}

/* -----------------------------------------------------------------------
 * Integrazione libpq — compilata solo se libpq-fe.h è incluso prima di noi
 * ----------------------------------------------------------------------- */

#ifdef LIBPQ_FE_H

TableLayout *table_layout_from_pgresult(PGresult *res)
{
    if (!res)
        return NULL;

    int num_cols = PQnfields(res);
    int num_rows = PQntuples(res);

    TableLayout *layout = malloc(sizeof(TableLayout));
    if (!layout)
        return NULL;

    layout->num_cols = num_cols;
    layout->col_widths = calloc((size_t)num_cols, sizeof(int));
    if (!layout->col_widths) {
        free(layout);
        return NULL;
    }

    for (int j = 0; j < num_cols; j++) {
        int max_w = table_is_numeric_oid((unsigned int)PQftype(res, j))
                    ? TABLE_MAX_CELL_WIDTH_NUM
                    : TABLE_MAX_CELL_WIDTH;

        /* costruisce un array temporaneo di puntatori ai valori */
        const char **vals = malloc((size_t)num_rows * sizeof(char *));
        if (!vals) {
            table_layout_free(layout);
            return NULL;
        }
        for (int i = 0; i < num_rows; i++)
            vals[i] = PQgetisnull(res, i, j) ? NULL : PQgetvalue(res, i, j);

        layout->col_widths[j] = table_compute_col_width(
            PQfname(res, j), vals, num_rows, max_w
        );
        free(vals);
    }

    layout->cols_to_print = table_compute_cols_that_fit(
        layout->col_widths, num_cols, TABLE_DEFAULT_TERM_WIDTH
    );

    return layout;
}

#endif /* LIBPQ_FE_H */

void table_layout_free(TableLayout *layout)
{
    if (!layout)
        return;
    free(layout->col_widths);
    free(layout);
}
