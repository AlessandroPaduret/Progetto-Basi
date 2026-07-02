-- Q1. per ogni Operatore il numero di segnalazioni gestite
SELECT 
    o.CF,
    o.Nome,
    o.Cognome,
    COUNT(s.Veicolo) AS num_segnalazioni
FROM Operatore o
LEFT JOIN Segnalazione s ON o.CF = s.CFOperatore
GROUP BY o.CF, o.Nome, o.Cognome
HAVING COUNT(s.Veicolo) > 0 
ORDER BY num_segnalazioni DESC