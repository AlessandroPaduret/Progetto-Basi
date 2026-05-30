# -------------------------------------------------------------------------
# Progetto F1 DB — Makefile Universale Automatico (Linux & Windows)
# -------------------------------------------------------------------------
CC      = gcc
CFLAGS  = -Wall -Wextra -std=c11 -Iinclude
LDFLAGS = 

# --- RILEVAMENTO AUTOMATICO SISTEMA OPERATIVO E COMANDI ---
ifeq ($(OS),Windows_NT)
    APP_TARGET  = app.exe
    TEST_TARGET = test_table_render.exe
    
    # Verifica REALE se il comando 'rm' è disponibile nel sistema
    RM_AVAILABLE := $(shell rm --version 2>nul)
    
    ifneq ($(RM_AVAILABLE),)
        # Se 'rm' risponde, lo usiamo in sicurezza con le sbarre dritte
        RM = rm -f
        CLEAN_FILES = app.exe test_table_render.exe *.o src/*.o *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
    else
        # Altrimenti usiamo il comando nativo 'del' di Windows con le sbarre rovesciate
        RM = del /Q /F
        CLEAN_FILES = app.exe test_table_render.exe *.o src\*.o *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
    endif

    # --- RILEVAMENTO LIBRERIE POSTGRESQL SU WINDOWS ---
    PG_INCLUDE_DETECTED := $(shell pg_config --includedir 2>nul)
    PG_LIB_DETECTED     := $(shell pg_config --libdir 2>nul)
    
    ifneq ($(PG_INCLUDE_DETECTED),)
        CFLAGS  += -I"$(PG_INCLUDE_DETECTED)"
        LDFLAGS += -L"$(PG_LIB_DETECTED)" -lpq
    else
        STANDARD_PG_PATHS := $(wildcard C:/Program\ Files/PostgreSQL/17 \
                                       C:/Program\ Files/PostgreSQL/16 \
                                       C:/Program\ Files/PostgreSQL/15 \
                                       C:/Program\ Files/PostgreSQL/14 \
                                       C:/Program\ Files/PostgreSQL/13)
        DETECTED_PATH := $(firstword $(STANDARD_PG_PATHS))
        ifneq ($(DETECTED_PATH),)
            CFLAGS  += -I"$(DETECTED_PATH)/include"
            LDFLAGS += -L"$(DETECTED_PATH)/lib" -lpq
        else
            LDFLAGS += -lpq
        endif
    endif
else
    # --- CONFIGURAZIONE LINUX / MAC ---
    APP_TARGET  = app.out
    TEST_TARGET = test_table_render.out
    RM          = rm -f
    CLEAN_FILES = app.out test_table_render.out *.o src/*.o *.aux *.log *.out *.toc *.fdb_latexmk *.fls *.synctex.gz
    
    CFLAGS  += $(shell pkg-config --cflags libpq 2>/dev/null || echo "")
    LDFLAGS += $(shell pkg-config --libs libpq 2>/dev/null || echo "-lpq")
endif

# --- SORGENTI ---
APP_SRCS    = src/query.c src/dbf1.c src/table_render.c
TEST_SRCS   = src/test_table_render.c src/table_render.c 
HEADERS     = include/dbf1.h include/table_render.h

.PHONY: all test clean

# Target principale
all: $(APP_TARGET)

$(APP_TARGET): $(APP_SRCS) $(HEADERS)
	$(CC) $(CFLAGS) $(APP_SRCS) -o $@ $(LDFLAGS)

# Target per i test
test: $(TEST_TARGET)
	./$(TEST_TARGET)

$(TEST_TARGET): $(TEST_SRCS) include/table_render.h
	$(CC) $(CFLAGS) $(TEST_SRCS) -o $@ $(LDFLAGS) -lcmocka

# Pulizia Universale (Il trattino '-' iniziale ignora gli errori se i file non esistono)
clean:
	-$(RM) $(CLEAN_FILES)