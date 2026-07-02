-- Q3. Utenti fit: selezionare gli utenti e i loro minuti complessivi percosi in bici nell'intervallo di tempo previsto
SELECT 
    n.UtenteEmail,
    ROUND(SUM(EXTRACT(EPOCH FROM (n.DataOraFine - n.DataOraInizio)) / 60)) AS minuti_bici
FROM Noleggio n
JOIN Bicicletta b ON n.Veicolo = b.Veicolo
WHERE n.DataOraFine BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59'
GROUP BY n.UtenteEmail
HAVING ROUND(SUM(EXTRACT(EPOCH FROM (n.DataOraFine - n.DataOraInizio)) / 60)) > 0
ORDER BY minuti_bici DESC;