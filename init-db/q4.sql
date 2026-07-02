-- Q4. Otteniamo i Parcheggi e punti di ricarica totali per ogni città
-- 1. Otteniamo l'elenco di tutte le città univoche presenti nel sistema
WITH CittaDisponibili AS (
    SELECT DISTINCT Citta FROM Zona
    UNION
    SELECT DISTINCT Citta FROM Hub
),

-- 2. Contiamo le rastrelliere raggruppandole per città
ConteggioRastrelliere AS (
    SELECT 
        ZonaCitta AS Citta, 
        SUM(MaxPosti) AS num_rastrelliere
    FROM Rastrelliera
    GROUP BY ZonaCitta
),

-- 3. Contiamo i punti di ricarica raggruppandoli per città
ConteggioPuntiRicarica AS (
    SELECT 
        HubCitta AS Citta, 
        COUNT(*) AS num_punti_ricarica
    FROM PuntoRicarica
    GROUP BY HubCitta
)

-- 4. Uniamo le città con i rispettivi conteggi
SELECT 
    c.Citta,
    COALESCE(r.num_rastrelliere, 0) AS num_rastrelliere,
    COALESCE(p.num_punti_ricarica, 0) AS num_punti_ricarica
FROM 
    CittaDisponibili c
LEFT JOIN 
    ConteggioRastrelliere r ON c.Citta = r.Citta
LEFT JOIN 
    ConteggioPuntiRicarica p ON c.Citta = p.Citta
ORDER BY 
    c.Citta;