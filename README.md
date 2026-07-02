# Progetto Basi — F1 DB Query Explorer

Applicazione C che si connette a un database PostgreSQL e permette di eseguire query interattive su un simulatore F1.

---

## Indice

- [Requisiti](#requisiti)
  - [Linux](#linux)
  - [Mac (Apple Silicon e Intel)](#mac-apple-silicon-e-intel)
  - [Windows](#windows)
- [Compilazione](#compilazione)
  - [Compilare l'applicazione](#compilare-lapplicazione)
  - [Pulire i file compilati](#pulire-i-file-compilati)
- [Esecuzione](#esecuzione)
- [Accortezze](#accortezze)

---

## Utilizzo consigliato

Con docker installato non servono altre dipendenze.

```bash
# per costruire il database e l'app
docker compose up -d --build
# per eseguire l'app in c
docker compose run app
```

## Requisiti

In caso non si riuscisse usando docker allora il codice va compilato con `Make` e il DB va caricato su un server Postgres. 

### Linux

```bash
sudo apt install gcc libpq-dev pkg-config libcmocka-dev
```

### Mac (Apple Silicon e Intel)

```bash
brew install postgresql pkg-config cmocka
```

### Windows

Installare [MinGW-w64](https://www.mingw-w64.org/) (include `gcc` e `mingw32-make`) e [PostgreSQL](https://www.postgresql.org/download/windows/) (versione 13–17).

Aggiungere al PATH di sistema:

```
C:\MinGW\bin
C:\Program Files\PostgreSQL\<versione>\bin
```

Il Makefile rileva automaticamente il path di PostgreSQL tramite `pg_config`.

---

## Compilazione

### Compilare l'applicazione

Linux / Mac:

```bash
make
# oppure esplicitamente
make all
```

Windows (MinGW):

```bash
mingw32-make
# oppure esplicitamente
mingw32-make all
```

Produce `app.out` su Linux/Mac, `app.exe` su Windows.

### Pulire i file compilati

Linux / Mac:

```bash
make clean
```

Windows:

```bash
mingw32-make clean
```

---

## Esecuzione

Prima di avviare l'app è necessario avere un'istanza PostgreSQL in esecuzione con il database `Simulatore_F1` caricato.

Per default l'app si connette con:

```
user=postgres password=password dbname=Simulatore_F1 host=localhost
```

Per usare una stringa di connessione diversa, impostare la variabile d'ambiente `DB_CONN`:

```bash
# Linux / Mac
export DB_CONN="user=postgres password=miapassword dbname=Simulatore_F1 host=localhost"
./app.out

# Windows (PowerShell)
$env:DB_CONN="user=postgres password=miapassword dbname=Simulatore_F1 host=localhost"
.\app.exe
```

---

## Accortezze

**Mac — `libpq-fe.h` not found**
Se `make` fallisce con questo errore, `pkg-config` non riesce a trovare PostgreSQL. Verificare che Homebrew abbia installato correttamente il pacchetto:

```bash
brew install postgresql pkg-config
pg_config --includedir   # deve restituire un path valido
```

**Windows — `pg_config` non trovato**
Verificare che `C:\Program Files\PostgreSQL\<versione>\bin` sia nel PATH di sistema. Il Makefile cerca automaticamente le versioni dalla 13 alla 17; se nessuna viene trovata, aggiungere il path manualmente.

**Windows — `mingw32-make` non trovato**
Verificare che `C:\MinGW\bin` sia nel PATH di sistema. In alternativa, alcuni pacchetti MinGW installano il comando come `make` invece di `mingw32-make` — provare entrambi.

**Windows — usare `rm` invece di `del`**
Se si usa Git Bash o WSL, il comando `rm` è disponibile e viene rilevato automaticamente dal Makefile. Con il prompt nativo `cmd.exe` viene usato `del` al suo posto.

**Encoding caratteri speciali**
Su Windows il terminale potrebbe mostrare caratteri errati (es. `Citt├á` invece di `Città`). Impostare la codepage UTF-8 prima di avviare l'app:

```
chcp 65001
```
