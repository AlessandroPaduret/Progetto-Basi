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
```


ho bigogno di alcune modifiche al file `query.c`. praticamente ho bisogno di implementare tutte e 5 le query descritte nel file `demo.tex`. in più bisogna creare query parametrizzate.

query:
```sql
-- tempo totale di una gara
SELECT g.Pilota, SUM(g.settore1::interval + g.settore2::interval + g.settore3::interval)
FROM Giro g
WHERE g.GaraData = '2026-03-29' 
  AND g.GaraCircuito = 'Monza' 
GROUP BY g.Pilota
ORDER BY SUM(g.settore1::interval + g.settore2::interval + g.settore3::interval)
```

```sql
-- la classifica e il distacco dal primo in una determinata gara
SELECT 
    c.Posizione,
    c.Nome_Pilota AS Pilota,
    c.Vettura,
    c.Giri_Completati,
    c.Gomma_Attuale,
    CASE 
        WHEN c.Posizione = 1 THEN 'LEADER'
        ELSE '+' || c.Gap::text 
    END AS Distacco,
    r.Ritiro AS Stato_Ritiro
FROM Vista_Classifica_Live c
LEFT JOIN Risultato r ON c.Pilota_CF = r.Pilota 
    AND c.GaraData = r.GaraData 
    AND c.GaraCircuito = r.GaraCircuito
WHERE c.GaraData = '2026-03-29' 
  AND c.GaraCircuito = 'Monza'
ORDER BY c.Posizione ASC;
```

```sql
-- tempo per le qualifiche
SELECT DISTINCT ON (p.CF)
    p.Nome || ' ' || p.Cognome AS Pilota,
    pa.Vettura AS Auto,
    g.GaraCircuito AS Circuito,
    g.GaraData AS Data_Gara,
    g.NGiro AS Numero_Giro,
    g.GommaUsata,
    g.Settore1 AS S1,
    g.Settore2 AS S2,
    g.Settore3 AS S3,
    (g.Settore1::interval + g.Settore2::interval + g.Settore3::interval) AS Tempo_Totale_Giro
FROM 
    Giro g
JOIN 
    Persona p ON g.Pilota = p.CF
JOIN 
    Partecipazione pa ON g.Pilota = pa.Pilota 
                     AND g.GaraCircuito = pa.GaraCircuito 
                     AND g.GaraData = pa.GaraData
WHERE 
    g.GaraData = '2026-03-29' 
    AND g.GaraCircuito = 'Monza'
ORDER BY 
    p.CF, 
    (g.Settore1::interval + g.Settore2::interval + g.Settore3::interval) ASC;
```