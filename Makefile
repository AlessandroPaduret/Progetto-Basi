# -------------------------------------------------------------------------
# Progetto F1 DB — Makefile
# -------------------------------------------------------------------------
CC      = gcc
# -Iinclude dice a gcc di cercare gli header nella cartella include/
CFLAGS  = -Wall -Wextra -std=c11 -Iinclude
LDFLAGS = -lpq

APP_TARGET  = app.out
TEST_TARGET = test_table_render

# Aggiunti i prefissi dei percorsi src/
APP_SRCS    = src/query.c src/dbf1.c src/table_render.c
TEST_SRCS   = src/test_table_render.c src/table_render.c

# Percorsi degli header per le dipendenze
HEADERS     = include/dbf1.h include/table_render.h

.PHONY: all test clean

# Build principale
all: $(APP_TARGET)

$(APP_TARGET): $(APP_SRCS) $(HEADERS)
	$(CC) $(CFLAGS) $(APP_SRCS) -o $@ $(LDFLAGS)

# Build + esecuzione unit test
# Nota: ho spostato -lcmocka alla fine insieme a LDFLAGS per evitare problemi di linking
test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_SRCS) include/table_render.h
	$(CC) $(CFLAGS) $(TEST_SRCS) -o $@ $(LDFLAGS) -lcmocka

clean:
	rm -f $(APP_TARGET) $(TEST_TARGET)
	rm -f *.o src/*.o
	rm -f *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz