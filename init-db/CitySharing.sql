-- =====================================================================
-- SCHEMA: Sistema di Sharing Urbano (stile Dott)
-- DBMS: PostgreSQL
-- =====================================================================

DROP TABLE IF EXISTS Attraversa CASCADE;
DROP TABLE IF EXISTS Segnalazione CASCADE;
DROP TABLE IF EXISTS Noleggio CASCADE;
DROP TABLE IF EXISTS Bicicletta CASCADE;
DROP TABLE IF EXISTS Monopattino CASCADE;
DROP TABLE IF EXISTS Veicolo CASCADE;
DROP TABLE IF EXISTS Utente CASCADE;
DROP TABLE IF EXISTS Tariffa CASCADE;
DROP TABLE IF EXISTS Rastrelliera CASCADE;
DROP TABLE IF EXISTS PuntoRicarica CASCADE;
DROP TABLE IF EXISTS Hub CASCADE;
DROP TABLE IF EXISTS Zona CASCADE;
DROP TABLE IF EXISTS Operatore CASCADE;

DROP TYPE IF EXISTS tipo_zona CASCADE;
DROP TYPE IF EXISTS tipo_veicolo CASCADE;
DROP TYPE IF EXISTS stato_veicolo CASCADE;
DROP TYPE IF EXISTS stato_presa CASCADE;
DROP TYPE IF EXISTS turno_operatore CASCADE;

-- =====================================================================
-- ENUM
-- =====================================================================

CREATE TYPE tipo_zona AS ENUM ('attiva', 'no_parking', 'velocita_ridotta');

CREATE TYPE tipo_veicolo AS ENUM ('monopattino', 'bicicletta');

CREATE TYPE stato_veicolo AS ENUM ('disponibile', 'in_uso', 'in_manutenzione');

CREATE TYPE stato_presa AS ENUM ('attivo', 'guasto', 'in_manutenzione');

CREATE TYPE turno_operatore AS ENUM ('mattina', 'pomeriggio', 'notte');

-- =====================================================================
-- ENTITÀ INDIPENDENTI
-- =====================================================================

CREATE TABLE Utente (
    Email               VARCHAR(100)    PRIMARY KEY,
    Nome                VARCHAR(50)     NOT NULL,
    Cognome             VARCHAR(50)     NOT NULL,
    Telefono            VARCHAR(20),
    DataNascita         DATE            NOT NULL,
    MetodoPagamento     VARCHAR(30)     NOT NULL
);

CREATE TABLE Zona (
    Nome                VARCHAR(50)     NOT NULL,
    Citta               VARCHAR(50)     NOT NULL,
    VelocitaMax         INT        NOT NULL,
    TipoZona            tipo_zona       NOT NULL,
    Perimetro           TEXT,

    PRIMARY KEY (Nome, Citta),
    CHECK (VelocitaMax > 0)
);

CREATE TABLE Tariffa (
    FasciaOraria        VARCHAR(20)     NOT NULL,
    TipoVeicolo         tipo_veicolo    NOT NULL,
    CostoSblocco        NUMERIC(5,2)    NOT NULL,
    CostoAlMinuto       NUMERIC(5,2)    NOT NULL,

    PRIMARY KEY (FasciaOraria, TipoVeicolo),
    CHECK (CostoSblocco >= 0),
    CHECK (CostoAlMinuto >= 0)
);

CREATE TABLE Operatore (
    CF                  CHAR(16)        PRIMARY KEY,
    Nome                VARCHAR(50)     NOT NULL,
    Cognome             VARCHAR(50)     NOT NULL,
    Turno               turno_operatore NOT NULL
);

-- =====================================================================
-- HUB — identificato da (Citta, Nome)
-- =====================================================================

CREATE TABLE Hub (
    Citta               VARCHAR(50)     NOT NULL,
    Nome                VARCHAR(50)     NOT NULL,
    Indirizzo           VARCHAR(100)    NOT NULL,
    CapacitaMax         INT             NOT NULL,

    -- Relazione 0:1 Supervisiona con Operatore
    CFOperatore        CHAR(16),

    PRIMARY KEY (Citta, Nome),                                    -- identificazione logica
    FOREIGN KEY (CFOperatore) REFERENCES Operatore(CF),
    CHECK (CapacitaMax > 0)
);

-- =====================================================================
-- RASTRELLIERA — entità debole di Zona
-- =====================================================================

CREATE TABLE Rastrelliera (
    Codice              SERIAL     NOT NULL,           -- discriminante locale
    MaxPosti            INT        NOT NULL,

    -- Relazione Situata (1:N) con Zona
    ZonaNome            VARCHAR(50)     NOT NULL,
    ZonaCitta           VARCHAR(50)     NOT NULL,

    PRIMARY KEY (ZonaCitta, ZonaNome, Codice),
    FOREIGN KEY (ZonaNome, ZonaCitta) REFERENCES Zona(Nome, Citta),
     CHECK (MaxPosti > 0)
);

-- =====================================================================
-- PUNTORICARICA — entità debole di Hub
-- =====================================================================

CREATE TABLE PuntoRicarica (
    NPresa              INT             NOT NULL,          
    Stato               stato_presa     NOT NULL DEFAULT 'attivo',
    DataUltimoTest      DATE            NOT NULL,
    HubCitta            VARCHAR(50)     NOT NULL,
    HubNome             VARCHAR(50)     NOT NULL,
    PRIMARY KEY (HubCitta, HubNome, NPresa),
    FOREIGN KEY (HubCitta, HubNome) REFERENCES Hub(Citta, Nome)
);

-- =====================================================================
-- GERARCHIA: Veicolo (padre) → Monopattino, Bicicletta (figli)
-- =====================================================================

CREATE TABLE Veicolo (
    Targa               VARCHAR(15)     PRIMARY KEY,
    Stato               stato_veicolo   NOT NULL DEFAULT 'disponibile',
    Marca               VARCHAR(50)     NOT NULL,
    TipoVeicolo         tipo_veicolo    NOT NULL
);

CREATE TABLE Monopattino (
    Veicolo             VARCHAR(15)     PRIMARY KEY,
    LivelloBatteria     INT             NOT NULL,
    VelocitaMax         INT             NOT NULL,
    PesoMax             INT             NOT NULL,
    PuntoRicarica       INTEGER,
    HubCitta            VARCHAR(50),
    HubNome             VARCHAR(50),

    FOREIGN KEY (Veicolo) REFERENCES Veicolo(Targa) ON DELETE CASCADE,
    FOREIGN KEY (HubCitta, HubNome, PuntoRicarica) REFERENCES PuntoRicarica(HubCitta, HubNome, NPresa),
    CHECK (LivelloBatteria BETWEEN 0 AND 100),
    CHECK (VelocitaMax > 0),
    CHECK (PesoMax > 0)
);

CREATE TABLE Bicicletta (
    Veicolo             VARCHAR(15)     PRIMARY KEY,
    NMarce              INT        NOT NULL,
    HasCestino          BOOLEAN         NOT NULL DEFAULT FALSE,

    -- Relazione Parcheggiata (0:1) con Rastrelliera — parcheggio corrente
    Codice              SERIAL     NOT NULL,
    RastrellieraNome            VARCHAR(50),
    RastrellieraCitta           VARCHAR(50),

    FOREIGN KEY (Veicolo) REFERENCES Veicolo(Targa) ON DELETE CASCADE,
    FOREIGN KEY (RastrellieraCitta, RastrellieraNome, Codice) REFERENCES Rastrelliera(ZonaCitta, ZonaNome, Codice),
    CHECK (NMarce > 0)
);

-- =====================================================================
-- NOLEGGIO
-- Chiave: (UtenteEmail, Targa, DataOraInizio) — relazioni Effettua + Riguarda
-- =====================================================================

CREATE TABLE Noleggio (
    UtenteEmail         VARCHAR(100)    NOT NULL,
    Veicolo             VARCHAR(15)     NOT NULL,
    DataOraInizio       TIMESTAMP       NOT NULL,
    DataOraFine         TIMESTAMP,
    CostoTotale         NUMERIC(8,2),   -- ridondante
    Valutazione         INT,

    -- Relazione Applica (N:1) con Tariffa
    FasciaOraria        VARCHAR(20),
    TipoVeicolo         tipo_veicolo,

    PRIMARY KEY (UtenteEmail, Veicolo, DataOraInizio),
    FOREIGN KEY (UtenteEmail) REFERENCES Utente(Email),
    FOREIGN KEY (Veicolo) REFERENCES Veicolo(Targa),
    FOREIGN KEY (FasciaOraria, TipoVeicolo) REFERENCES Tariffa(FasciaOraria, TipoVeicolo),
    CHECK (DataOraFine IS NULL OR DataOraFine > DataOraInizio),
    CHECK (CostoTotale >= 0),
    CHECK (Valutazione BETWEEN 1 AND 5)
);

-- =====================================================================
-- SEGNALAZIONE — entità debole di Veicolo (relazione Genera)
-- =====================================================================

CREATE TABLE Segnalazione (
    Veicolo             VARCHAR(15)     NOT NULL,
    DataOra             TIMESTAMP       NOT NULL,
    Descrizione         TEXT,
    TipoProblema        VARCHAR(50)     NOT NULL,
    CFOperatore         CHAR(16),

    PRIMARY KEY (Veicolo, DataOra),
    FOREIGN KEY (Veicolo) REFERENCES Veicolo(Targa),
    FOREIGN KEY (CFOperatore) REFERENCES Operatore(CF)
);

-- =====================================================================
-- RELAZIONI N:M
-- =====================================================================

-- Attraversa: Noleggio — Zona (N:M)
CREATE TABLE Attraversa (
    UtenteEmail         VARCHAR(100)    NOT NULL,
    Veicolo             VARCHAR(15)     NOT NULL,
    DataOraInizio       TIMESTAMP       NOT NULL,
    ZonaNome            VARCHAR(50)     NOT NULL,
    ZonaCitta           VARCHAR(50)     NOT NULL,

    PRIMARY KEY (UtenteEmail, Veicolo, DataOraInizio, ZonaNome, ZonaCitta),
    FOREIGN KEY (UtenteEmail, Veicolo, DataOraInizio) REFERENCES Noleggio(UtenteEmail, Veicolo, DataOraInizio),
    FOREIGN KEY (ZonaNome, ZonaCitta) REFERENCES Zona(Nome, Citta)
);