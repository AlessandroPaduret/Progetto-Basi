# -------------------------------------------------------------------------
# Progetto F1 DB — Makefile
# -------------------------------------------------------------------------
CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11
LDFLAGS = -lpq

APP_TARGET  = app.out
TEST_TARGET = test_table_render

APP_SRCS    = query.c dbf1.c table_render.c
TEST_SRCS   = test_table_render.c table_render.c

.PHONY: all test clean

# Build principale
all: $(APP_TARGET)

$(APP_TARGET): $(APP_SRCS) dbf1.h table_render.h
	$(CC) $(CFLAGS) $(APP_SRCS) -o $@ $(LDFLAGS)

# Build + esecuzione unit test (non richiedono DB)
test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_SRCS) table_render.h
	$(CC) $(CFLAGS) $(TEST_SRCS) -o $@ -lcmocka

clean:
	rm -f $(APP_TARGET) $(TEST_TARGET)
