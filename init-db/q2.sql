-- Q2. Seleziona gli utenti e la loro spesa complessiva nell'intervallo di tempo
SELECT 
    u.*,
    SUM(n.CostoTotale) AS guadagno
FROM Noleggio AS n
JOIN Utente AS u ON n.UtenteEmail = u.Email
WHERE n.DataOraFine BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59' -- ps. abbiamo dati solo del 2024
GROUP BY u.email
HAVING SUM(n.CostoTotale) > 0
ORDER BY guadagno DESC;