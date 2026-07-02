-- Q5. Numoro posti liberi in ogni zona
-- 1. Calcoliamo il totale dei posti fisici (MaxPosti) per ogni Zona
WITH CapacitaZona AS (
    SELECT 
        ZonaCitta, 
        ZonaNome, 
        SUM(MaxPosti) AS posti_totali
    FROM Rastrelliera
    GROUP BY ZonaCitta, ZonaNome
),

-- 2. Contiamo quante biciclette sono attualmente parcheggiate in ogni Zona
BiciParcheggiate AS (
    SELECT 
        RastrellieraCitta AS ZonaCitta, 
        RastrellieraNome AS ZonaNome, 
        COUNT(Veicolo) AS bici_presenti
    FROM Bicicletta
    WHERE RastrellieraCitta IS NOT NULL -- Consideriamo solo le bici effettivamente parcheggiate in una rastrelliera
    GROUP BY RastrellieraCitta, RastrellieraNome
)

-- 3. Uniamo i dati e calcoliamo i posti liberi
SELECT 
    c.ZonaCitta AS "Città",
    c.ZonaNome AS "Zona",
    (c.posti_totali - COALESCE(b.bici_presenti, 0)) AS posti_liberi
FROM CapacitaZona c
LEFT JOIN BiciParcheggiate b ON c.ZonaCitta = b.ZonaCitta AND c.ZonaNome = b.ZonaNome
ORDER BY c.ZonaCitta, c.ZonaNome;