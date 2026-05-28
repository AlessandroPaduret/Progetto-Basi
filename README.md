- 3.4 Schema E-R
	- aggiornare l'er aggiornando persona per togliere lo stipendio
	- modificare chiave di partecipazione (pilota, gara)
	- aggiungere attributo PosPartenza in partecipazione
	- rinominare in circuito N_Curve -> NCurve
	- Modificare cardinalita di gara - campionato ad un 1,1 al posto di 0,1
	- modificare cardinalita di gara verso pilota e farla (1,N), quindi Pilota(0,N) - Gara(1,N)
- 4.2 Eliminazione delle Generalizzazioni
	- descrivere le scelte fatte per il tipo di eliminazione scelta
- 4.3 Diagramma E-R risrutturato
	- implementarlo
- 4.5 Vincoli referenziali non deducibili dallo schema E-R
	- descrivere cove ci sono i vincoli che esistono ma non sono diretti
- 5.1 Definizione delle Query
	- fare le 5 query secondo le specifiche
- 5.2 Creazione degli Indici
	- implementare un indice che sia rilevante
- 6 Applicazione Software
	- fare l'implementazione in C
    
ps. per esportare DB 
```bash 
# generale
pg_dump -U nome_utente -d database_name > backup_multiverso.sql
# quello che ho usato io
pg_dump -U postgres -d Timelines > backup_multiverso.sql
```# Timelines
