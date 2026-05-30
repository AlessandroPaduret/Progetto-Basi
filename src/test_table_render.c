/**
 * test_table_render.c — unit test con cmocka
 *
 * Copre le funzioni pure di table_render.h che non richiedono un DB:
 *   - table_is_numeric_oid
 *   - table_compute_col_width
 *   - table_compute_cols_that_fit
 *   - table_layout_free (smoke test su NULL)
 *
 * Compilare con:
 *   gcc test_table_render.c table_render.c -o test_table_render \
 *       -Wall -lcmocka && ./test_table_render
 */

#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>
#include <libpq-fe.h>

#include "table_render.h"


/* -----------------------------------------------------------------------
 * Gruppo 1 – table_compute_col_width
 * ----------------------------------------------------------------------- */

static void test_col_width_header_wins(void **state)
{
    (void)state;
    /* header più lungo dei valori */
    const char *values[] = {"ab", "c"};
    int w = table_compute_col_width("LongHeaderName", values, 2, 20);
    assert_int_equal(14, w); /* strlen("LongHeaderName") = 14 */
}

static void test_col_width_value_wins(void **state)
{
    (void)state;
    const char *values[] = {"ShortishValue", "x"};
    int w = table_compute_col_width("Hdr", values, 2, 20);
    assert_int_equal(13, w); /* strlen("ShortishValue") = 13 */
}

static void test_col_width_capped_at_max(void **state)
{
    (void)state;
    const char *values[] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZ"};
    int w = table_compute_col_width("Col", values, 1, 10);
    assert_int_equal(10, w);
}

static void test_col_width_minimum_four(void **state)
{
    (void)state;
    /* header "ab" (2), valore "x" (1) → min 4 */
    const char *values[] = {"x"};
    int w = table_compute_col_width("ab", values, 1, 20);
    assert_int_equal(4, w);
}

static void test_col_width_null_value_treated_as_null_string(void **state)
{
    (void)state;
    /* NULL nel valori → "NULL" (4 char) */
    const char *values[] = {NULL};
    int w = table_compute_col_width("Col", values, 1, 20);
    /* "NULL" ha 4 char, header "Col" ha 3 → min garantito è 4 */
    assert_int_equal(4, w);
}

static void test_col_width_null_header(void **state)
{
    (void)state;
    const char *values[] = {"hello"};
    /* header NULL non deve crashare */
    int w = table_compute_col_width(NULL, values, 1, 20);
    assert_int_equal(5, w); /* "hello" */
}

static void test_col_width_zero_rows(void **state)
{
    (void)state;
    /* nessuna riga → solo header */
    int w = table_compute_col_width("NomeColonna", NULL, 0, 20);
    assert_int_equal(11, w); /* strlen("NomeColonna") */
}

static void test_col_width_exact_max(void **state)
{
    (void)state;
    /* valore esattamente = max_width */
    const char *values[] = {"1234567890"};
    int w = table_compute_col_width("H", values, 1, 10);
    assert_int_equal(10, w);
}

/* -----------------------------------------------------------------------
 * Gruppo 2 – table_compute_cols_that_fit
 * ----------------------------------------------------------------------- */

static void test_cols_fit_all_columns(void **state)
{
    (void)state;
    /* 3 colonne da 10: 10 + 13 + 13 = 36 char, term_width 80 → tutte e 3 */
    int widths[] = {10, 10, 10};
    int n = table_compute_cols_that_fit(widths, 3, 80);
    assert_int_equal(3, n);
}

static void test_cols_fit_partial(void **state)
{
    (void)state;
    /* col[0]=10, col[1]=10 (+ 3 sep = 13), col[2]=10 (+ 3 sep = 13)
       10 + 13 = 23 OK, 23 + 13 = 36 OK, 36 + 13 = 49 > 40 → 3 colonne */
    int widths[] = {10, 10, 10, 10};
    int n = table_compute_cols_that_fit(widths, 4, 40);
    /* 10 + 13 + 13 = 36 ≤ 40; 36 + 13 = 49 > 40 → 3 */
    assert_int_equal(3, n);
}

static void test_cols_fit_single_oversized_col(void **state)
{
    (void)state;
    /* anche se la prima colonna supera term_width, restituisce 1 */
    int widths[] = {200, 10};
    int n = table_compute_cols_that_fit(widths, 2, 80);
    assert_int_equal(1, n);
}

static void test_cols_fit_zero_cols(void **state)
{
    (void)state;
    int n = table_compute_cols_that_fit(NULL, 0, 80);
    assert_int_equal(0, n);
}

static void test_cols_fit_exact_width(void **state)
{
    (void)state;
    /* 10 + 3 + 10 = 23, term_width = 23 → 2 colonne */
    int widths[] = {10, 10};
    int n = table_compute_cols_that_fit(widths, 2, 23);
    assert_int_equal(2, n);
}

static void test_cols_fit_one_pixel_short(void **state)
{
    (void)state;
    /* 10 + 3 + 10 = 23, term_width = 22 → solo 1 colonna */
    int widths[] = {10, 10};
    int n = table_compute_cols_that_fit(widths, 2, 22);
    assert_int_equal(1, n);
}

static void test_cols_fit_large_term(void **state)
{
    (void)state;
    int widths[] = {5, 5, 5, 5, 5};
    /* 5 + (5+3)*4 = 5 + 32 = 37, termine 1000 → tutte e 5 */
    int n = table_compute_cols_that_fit(widths, 5, 1000);
    assert_int_equal(5, n);
}

/* -----------------------------------------------------------------------
 * Gruppo 3 – table_layout_free smoke test
 * ----------------------------------------------------------------------- */

static void test_layout_free_null_does_not_crash(void **state)
{
    (void)state;
    table_layout_free(NULL); /* non deve crashare */
}

/* -----------------------------------------------------------------------
 * Runner
 * ----------------------------------------------------------------------- */

int main(void)
{
    const struct CMUnitTest tests[] = {
        /* compute_col_width */
        cmocka_unit_test(test_col_width_header_wins),
        cmocka_unit_test(test_col_width_value_wins),
        cmocka_unit_test(test_col_width_capped_at_max),
        cmocka_unit_test(test_col_width_minimum_four),
        cmocka_unit_test(test_col_width_null_value_treated_as_null_string),
        cmocka_unit_test(test_col_width_null_header),
        cmocka_unit_test(test_col_width_zero_rows),
        cmocka_unit_test(test_col_width_exact_max),

        /* compute_cols_that_fit */
        cmocka_unit_test(test_cols_fit_all_columns),
        cmocka_unit_test(test_cols_fit_partial),
        cmocka_unit_test(test_cols_fit_single_oversized_col),
        cmocka_unit_test(test_cols_fit_zero_cols),
        cmocka_unit_test(test_cols_fit_exact_width),
        cmocka_unit_test(test_cols_fit_one_pixel_short),
        cmocka_unit_test(test_cols_fit_large_term),

        /* layout_free */
        cmocka_unit_test(test_layout_free_null_does_not_crash),
    };

    return cmocka_run_group_tests(tests, NULL, NULL);
}
