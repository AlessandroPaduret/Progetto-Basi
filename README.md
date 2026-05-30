ps. per esportare DB 
```bash 
# generale
pg_dump -U nome_utente -d database_name > backup_multiverso.sql
# quello che ho usato io
pg_dump -U postgres -d Timelines > backup_multiverso.sql
```

# Docker Facile

Questo progetto permette di configurare e avviare un database completo e già popolato in pochi secondi, garantendo la massima semplicità di setup.

##  Avvio Rapido
Per creare il database e popolarlo automaticamente con i dati, segui questi passaggi:

1. Apri il terminale nella cartella principale del progetto.
2. Esegui il seguente comando:

```bash
docker compose up -d --build
```

Accesso ai Dati (pgAdmin)

Una volta che i container sono attivi:

1. Apri pgAdmin.
2. Crea una nuova connessione cliccando su "Add New Server".
3. Inserisci i parametri di connessione (Host: localhost, Porta: quella definita nel file compose).
4. Inserisci le credenziali definite nel file compose
5. crea connessione