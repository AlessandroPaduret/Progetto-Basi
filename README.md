# Progetto Basi — DB Formula 1 (PostgreSQL) + App C

Questo repository contiene:
- un **database PostgreSQL** (avviabile con Docker Compose) già popolato tramite script in `init-db/`
- una piccola **app CLI in C** (`query.c`) che si collega al DB e permette di esplorare alcune query dal menù

---

## Requisiti

- **Docker** + **Docker Compose**
- (opzionale, per eseguire l’app in locale) **gcc** e libreria **libpq** (client PostgreSQL)

---

## Avvio del database con Docker Compose

Dalla root del progetto:

```bash
docker compose up -d --build
```

Questo avvia il servizio PostgreSQL:
- **container**: `f1_simulator_db`
- **DB**: `f1_db`
- **utente**: `postgres`
- **password**: `password`
- **porta**: `5432` (mappata su localhost)

Gli script SQL in `init-db/` vengono eseguiti automaticamente al primo avvio (quando il volume è “vuoto”).

### Stop / reset del DB

Stop dei container:
```bash
docker compose down
```

Stop + cancellazione dei dati persistiti (ricrea il DB da zero al prossimo `up`):
```bash
docker compose down -v
```

---

## Eseguire l’app (query explorer)

### Opzione A — Eseguire l’app **in locale** collegandosi al DB Docker

1) Avvia prima il DB con Compose (vedi sopra)
2) Compila:

```bash
make clean && make
```

3) Avvia:

```bash
./app.out
```

> L’app usa la connection string dentro `query.c`:
> `user=postgres password=password dbname=f1_db host=localhost`

### Opzione B — Eseguire l’app **da Docker Compose**

Al momento `docker-compose.yaml` avvia **solo** il database.

Se vuoi eseguire anche l’app via Compose, aggiungi un servizio `app` (oppure crea un `Dockerfile`).
Se mi dici che preferisci:
- **Dockerfile + service app**
oppure
- solo **Dockerfile** per build/run manuale,
posso prepararti la configurazione.

---

## Accesso con pgAdmin

Una volta avviato il DB:

- **Host**: `localhost`
- **Porta**: `5432`
- **Maintenance DB / Database**: `f1_db`
- **Username**: `postgres`
- **Password**: `password`

---

## Backup / export del database (pg_dump)

Esempio generico:
```bash
pg_dump -U <utente> -d <database> > backup.sql
```

Esempio per questo progetto:
```bash
pg_dump -U postgres -d f1_db > backup_f1_db.sql
```

Se stai dumpando il DB dal container (senza client installato localmente):
```bash
docker exec -t f1_simulator_db pg_dump -U postgres -d f1_db > backup_f1_db.sql
```
