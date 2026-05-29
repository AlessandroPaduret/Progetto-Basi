
-- TOC entry 864 (class 1247 OID 16430)
-- Name: causaritiro; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.causaritiro AS ENUM (
    'Incidente',
    'Guasto meccanico',
    'Squalifica',
    'Abbandono'
);


--
-- TOC entry 858 (class 1247 OID 16410)
-- Name: condizionimeteo; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.condizionimeteo AS ENUM (
    'Soleggiato',
    'Nuvoloso',
    'Pioggia'
);


--
-- TOC entry 861 (class 1247 OID 16418)
-- Name: gomma; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.gomma AS ENUM (
    'Soft',
    'Medium',
    'Hard',
    'Intermedie',
    'Wet'
);


--
-- TOC entry 852 (class 1247 OID 16394)
-- Name: specializzazione; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.specializzazione AS ENUM (
    'Aerodinamica',
    'Motore',
    'Gomme'
);


--
-- TOC entry 849 (class 1247 OID 16386)
-- Name: stileguida; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.stileguida AS ENUM (
    'Aggressivo',
    'Conservativo',
    'Bilanciato'
);


--
-- TOC entry 855 (class 1247 OID 16402)
-- Name: tipocircuito; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipocircuito AS ENUM (
    'Cittadino',
    'Permanente',
    'Misto'
);


--
-- TOC entry 215 (class 1259 OID 16446)
-- Name: campionato; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campionato (
    nome character varying(30) NOT NULL,
    anno integer NOT NULL,
    budgetcap integer NOT NULL,
    montepremi integer NOT NULL,
    regolamento double precision NOT NULL,
    CONSTRAINT campionato_anno_check CHECK ((anno >= 1950)),
    CONSTRAINT campionato_budgetcap_check CHECK ((budgetcap >= 0)),
    CONSTRAINT campionato_montepremi_check CHECK ((montepremi >= 0))
);


--
-- TOC entry 216 (class 1259 OID 16459)
-- Name: circuito; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circuito (
    nome character varying(20) NOT NULL,
    paese character varying(20) NOT NULL,
    lunghezza double precision NOT NULL,
    ncurve integer NOT NULL,
    tipo public.tipocircuito NOT NULL,
    CONSTRAINT circuito_lunghezza_check CHECK ((lunghezza > (0)::double precision)),
    CONSTRAINT circuito_ncurve_check CHECK ((ncurve >= 1))
);


--
-- TOC entry 223 (class 1259 OID 16523)
-- Name: contratto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contratto (
    persona character varying(16) NOT NULL,
    scuderia character varying(20) NOT NULL,
    annoinizio integer NOT NULL,
    annofine integer,
    stipendio integer NOT NULL,
    CONSTRAINT contratto_check CHECK ((annofine >= annoinizio)),
    CONSTRAINT contratto_stipendio_check CHECK ((stipendio >= 0))
);


--
-- TOC entry 217 (class 1259 OID 16466)
-- Name: gara; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gara (
    data date NOT NULL,
    circuito character varying(20) NOT NULL,
    meteo public.condizionimeteo NOT NULL,
    temperatura double precision NOT NULL,
    campionatonome character varying(30) NOT NULL,
    campionatoanno integer NOT NULL
);


--
-- TOC entry 225 (class 1259 OID 16568)
-- Name: giro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.giro (
    pilota character varying(16) NOT NULL,
    garadata date NOT NULL,
    garacircuito character varying(20) NOT NULL,
    ngiro integer NOT NULL,
    settore1 numeric(6,3) DEFAULT 0.000 NOT NULL,
    settore2 numeric(6,3) DEFAULT 0.000 NOT NULL,
    settore3 numeric(6,3) DEFAULT 0.000 NOT NULL,
    gommausata public.gomma NOT NULL,
    CONSTRAINT giro_ngiro_check CHECK ((ngiro >= 1))
);


--
-- TOC entry 224 (class 1259 OID 16540)
-- Name: partecipazione; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partecipazione (
    pilota character varying(16) NOT NULL,
    vettura character varying(10) NOT NULL,
    garadata date NOT NULL,
    garacircuito character varying(20) NOT NULL,
    tecnico character varying(16) NOT NULL,
    pospartenza integer NOT NULL,
    note character varying(100),
    CONSTRAINT partecipazione_pospartenza_check CHECK ((pospartenza > 0))
);


--
-- TOC entry 220 (class 1259 OID 16497)
-- Name: persona; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persona (
    cf character varying(16) NOT NULL,
    nome character varying(20) NOT NULL,
    cognome character varying(20) NOT NULL,
    nazionalita character varying(20) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 16502)
-- Name: pilota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pilota (
    persona character varying(16) NOT NULL,
    stileguida public.stileguida NOT NULL,
    esperienza integer NOT NULL,
    CONSTRAINT pilota_esperienza_check CHECK ((esperienza >= 0))
);


--
-- TOC entry 214 (class 1259 OID 16439)
-- Name: regolamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regolamento (
    versione double precision NOT NULL,
    pesomax double precision NOT NULL,
    pesomin double precision NOT NULL,
    drsconsentito boolean NOT NULL,
    datarilascio date NOT NULL,
    CONSTRAINT regolamento_check CHECK (((pesomax > (0)::double precision) AND (pesomin > (0)::double precision))),
    CONSTRAINT regolamento_check1 CHECK ((pesomax > pesomin))
);


--
-- TOC entry 226 (class 1259 OID 16587)
-- Name: risultato; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.risultato (
    pilota character varying(16) NOT NULL,
    garadata date NOT NULL,
    garacircuito character varying(20) NOT NULL,
    posizione integer,
    punti integer,
    ritiro public.causaritiro,
    CONSTRAINT risultato_posizione_check CHECK ((posizione >= 1)),
    CONSTRAINT risultato_punti_check CHECK ((punti >= 0))
);


--
-- TOC entry 218 (class 1259 OID 16481)
-- Name: scuderia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scuderia (
    nome character varying(20) NOT NULL,
    sede character varying(20) NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 16513)
-- Name: tecnico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tecnico (
    persona character varying(16) NOT NULL,
    specializzazione public.specializzazione NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16486)
-- Name: vettura; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vettura (
    modello character varying(10) NOT NULL,
    peso double precision NOT NULL,
    accelerazione double precision NOT NULL,
    velocita double precision NOT NULL,
    scuderia character varying(20) NOT NULL,
    CONSTRAINT vettura_check CHECK (((peso > (0)::double precision) AND (accelerazione > (0)::double precision) AND (velocita > (0)::double precision)))
);


--
-- TOC entry 3530 (class 0 OID 16446)
-- Dependencies: 215
-- Data for Name: campionato; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.campionato VALUES ('Formula 1 World Championship', 2022, 140000000, 100000000, 1);
INSERT INTO public.campionato VALUES ('Formula 1 World Championship', 2023, 135000000, 100000000, 2);
INSERT INTO public.campionato VALUES ('Formula 1 World Championship', 2024, 135000000, 105000000, 3);
INSERT INTO public.campionato VALUES ('Formula 1 World Championship', 2025, 140000000, 110000000, 4);
INSERT INTO public.campionato VALUES ('Formula 1 World Championship', 2026, 142000000, 115000000, 5);


--
-- TOC entry 3531 (class 0 OID 16459)
-- Dependencies: 216
-- Data for Name: circuito; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.circuito VALUES ('Sakhir', 'Bahrain', 5.412, 15, 'Permanente');
INSERT INTO public.circuito VALUES ('Jeddah', 'Arabia Saudita', 6.174, 27, 'Cittadino');
INSERT INTO public.circuito VALUES ('Albert Park', 'Australia', 5.278, 14, 'Cittadino');
INSERT INTO public.circuito VALUES ('Suzuka', 'Giappone', 5.807, 18, 'Permanente');
INSERT INTO public.circuito VALUES ('Shanghai', 'Cina', 5.451, 16, 'Permanente');
INSERT INTO public.circuito VALUES ('Miami', 'Stati Uniti', 5.412, 19, 'Cittadino');
INSERT INTO public.circuito VALUES ('Imola', 'Italia', 4.909, 19, 'Permanente');
INSERT INTO public.circuito VALUES ('Monaco', 'Monaco', 3.337, 19, 'Cittadino');
INSERT INTO public.circuito VALUES ('Montreal', 'Canada', 4.361, 14, 'Misto');
INSERT INTO public.circuito VALUES ('Barcelona', 'Spagna', 4.657, 14, 'Permanente');
INSERT INTO public.circuito VALUES ('Spielberg', 'Austria', 4.318, 10, 'Permanente');
INSERT INTO public.circuito VALUES ('Silverstone', 'Regno Unito', 5.891, 18, 'Permanente');
INSERT INTO public.circuito VALUES ('Budapest', 'Ungheria', 4.381, 14, 'Permanente');
INSERT INTO public.circuito VALUES ('Spa', 'Belgio', 7.004, 20, 'Permanente');
INSERT INTO public.circuito VALUES ('Zandvoort', 'Paesi Bassi', 4.259, 14, 'Permanente');
INSERT INTO public.circuito VALUES ('Monza', 'Italia', 5.793, 11, 'Permanente');
INSERT INTO public.circuito VALUES ('Baku', 'Azerbaigian', 6.003, 20, 'Cittadino');
INSERT INTO public.circuito VALUES ('Marina Bay', 'Singapore', 4.94, 19, 'Cittadino');
INSERT INTO public.circuito VALUES ('Austin', 'Stati Uniti', 5.513, 20, 'Permanente');
INSERT INTO public.circuito VALUES ('Città del Messico', 'Messico', 4.304, 17, 'Permanente');
INSERT INTO public.circuito VALUES ('Interlagos', 'Brasile', 4.309, 15, 'Permanente');
INSERT INTO public.circuito VALUES ('Las Vegas', 'Stati Uniti', 6.201, 17, 'Cittadino');
INSERT INTO public.circuito VALUES ('Losail', 'Qatar', 5.419, 16, 'Permanente');
INSERT INTO public.circuito VALUES ('Yas Marina', 'Emirati Arabi', 5.281, 16, 'Permanente');


--
-- TOC entry 3538 (class 0 OID 16523)
-- Dependencies: 223
-- Data for Name: contratto; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.contratto VALUES ('HMLWLS85A07XX5E', 'McLaren', 2007, 2012, 15000000);
INSERT INTO public.contratto VALUES ('VRSMAX97M30XX1A', 'Red Bull', 2016, 2028, 55000000);
INSERT INTO public.contratto VALUES ('LNSFND81H29XX9I', 'Alpine', 2021, 2022, 20000000);
INSERT INTO public.contratto VALUES ('NWYADR69C26XX1C', 'Aston Martin', 2025, 2029, 15000000);
INSERT INTO public.contratto VALUES ('LCRCHL97G16XX3C', 'Ferrari', 2019, 2029, 35000000);
INSERT INTO public.contratto VALUES ('SNZCLS94M01XX4D', 'McLaren', 2019, 2020, 8000000);
INSERT INTO public.contratto VALUES ('LLSJMS72H09XX2D', 'Mercedes', 2017, 2026, 4500000);
INSERT INTO public.contratto VALUES ('RCCDNL89H01XX6R', 'Red Bull', 2014, 2018, 12000000);
INSERT INTO public.contratto VALUES ('NRSLND97L13XX7G', 'McLaren', 2019, 2027, 25000000);
INSERT INTO public.contratto VALUES ('PRZSRG90C29XX2B', 'Red Bull', 2021, 2025, 10000000);
INSERT INTO public.contratto VALUES ('VTLSBS87D03XX3Y', 'Ferrari', 2015, 2020, 40000000);
INSERT INTO public.contratto VALUES ('CRDNRC73B28XX3E', 'Ferrari', 2015, 2026, 3500000);
INSERT INTO public.contratto VALUES ('PSTOCR01A06XX8H', 'McLaren', 2023, 2026, 8000000);
INSERT INTO public.contratto VALUES ('RSSGGE98B15XX6F', 'Mercedes', 2022, 2026, 18000000);
INSERT INTO public.contratto VALUES ('BTTVAL89B28XX7S', 'Mercedes', 2017, 2021, 12000000);
INSERT INTO public.contratto VALUES ('GRNNDW80H12XX4F', 'Aston Martin', 2021, 2027, 3000000);
INSERT INTO public.contratto VALUES ('LNSFND81H29XX9I', 'Aston Martin', 2023, 2026, 22000000);
INSERT INTO public.contratto VALUES ('STRLNC98H29XX0L', 'Aston Martin', 2019, 2026, 5000000);
INSERT INTO public.contratto VALUES ('GSNPRE96L07XX2N', 'Red Bull', 2019, 2019, 2000000);
INSERT INTO public.contratto VALUES ('FRYPTC78D22XX5G', 'Alpine', 2023, 2026, 2500000);
INSERT INTO public.contratto VALUES ('OCNEBN96A17XX1M', 'Alpine', 2020, 2024, 7000000);
INSERT INTO public.contratto VALUES ('GSNPRE96L07XX2N', 'Alpine', 2023, 2025, 6000000);
INSERT INTO public.contratto VALUES ('LBNALX96L23XX3O', 'Red Bull', 2019, 2020, 1500000);
INSERT INTO public.contratto VALUES ('RBSDVE82L30XX6H', 'Williams', 2019, 2026, 2200000);
INSERT INTO public.contratto VALUES ('LBNALX96L23XX3O', 'Williams', 2022, 2026, 3000000);
INSERT INTO public.contratto VALUES ('SRGLGN98D03XX4P', 'Williams', 2023, 2024, 1000000);
INSERT INTO public.contratto VALUES ('HLKNIC87M01XX0V', 'Alpine', 2017, 2019, 5000000);
INSERT INTO public.contratto VALUES ('EGGNJDY76H18XX7I', 'RB', 2019, 2026, 2000000);
INSERT INTO public.contratto VALUES ('TSNYKI04A03XX5Q', 'RB', 2021, 2025, 1500000);
INSERT INTO public.contratto VALUES ('RCCDNL89H01XX6R', 'RB', 2023, 2024, 7000000);
INSERT INTO public.contratto VALUES ('RKKKIM79L17XX2X', 'Ferrari', 2014, 2018, 28000000);
INSERT INTO public.contratto VALUES ('LNNLSN79D14XX8L', 'Sauber', 2022, 2026, 3000000);
INSERT INTO public.contratto VALUES ('BTTVAL89B28XX7S', 'Sauber', 2022, 2024, 10000000);
INSERT INTO public.contratto VALUES ('ZHOGYN99D30XX8T', 'Sauber', 2022, 2024, 2000000);
INSERT INTO public.contratto VALUES ('MGNKVN92L05XX9U', 'McLaren', 2014, 2015, 1500000);
INSERT INTO public.contratto VALUES ('RSTSME74H20XX9M', 'Haas', 2021, 2024, 1800000);
INSERT INTO public.contratto VALUES ('MGNKVN92L05XX9U', 'Haas', 2022, 2024, 3000000);
INSERT INTO public.contratto VALUES ('HLKNIC87M01XX0V', 'Haas', 2023, 2024, 2000000);
INSERT INTO public.contratto VALUES ('GVNNTN93H21XX1W', 'Sauber', 2019, 2021, 1000000);
INSERT INTO public.contratto VALUES ('PRDPTR80L08XX0N', 'McLaren', 2014, 2026, 2500000);
INSERT INTO public.contratto VALUES ('GVNNTN93H21XX1W', 'Ferrari', 2023, 2026, 1200000);
INSERT INTO public.contratto VALUES ('RKKKIM79L17XX2X', 'Sauber', 2019, 2021, 4000000);
INSERT INTO public.contratto VALUES ('BTNNSN80D19XX4Z', 'McLaren', 2010, 2016, 16000000);
INSERT INTO public.contratto VALUES ('OTLNEL77L22XX1O', 'McLaren', 2010, 2026, 2800000);
INSERT INTO public.contratto VALUES ('SNZCLS94M01XX4D', 'Ferrari', 2021, 2024, 12000000);
INSERT INTO public.contratto VALUES ('HMLWLS85A07XX5E', 'Ferrari', 2025, 2027, 50000000);
INSERT INTO public.contratto VALUES ('NWYADR69C26XX1C', 'Red Bull', 2006, 2024, 12000000);
INSERT INTO public.contratto VALUES ('TNDDGO85H30XX2P', 'Ferrari', 2020, 2026, 1500000);
INSERT INTO public.contratto VALUES ('VTLSBS87D03XX3Y', 'Aston Martin', 2021, 2022, 15000000);
INSERT INTO public.contratto VALUES ('BTNNSN80D19XX4Z', 'Williams', 2021, 2024, 2000000);
INSERT INTO public.contratto VALUES ('SCHMCK99G22XX5A', 'Haas', 2021, 2022, 1000000);
INSERT INTO public.contratto VALUES ('FLLDAN88D19XX3Q', 'Aston Martin', 2022, 2027, 3000000);
INSERT INTO public.contratto VALUES ('SCHMCK99G22XX5A', 'Mercedes', 2023, 2025, 1500000);
INSERT INTO public.contratto VALUES ('MRBPLO64H07XX4R', 'Ferrari', 2019, 2025, 1200000);
INSERT INTO public.contratto VALUES ('HRMMTT86L14XX5S', 'Alpine', 2022, 2024, 1300000);
INSERT INTO public.contratto VALUES ('DMSFNX91D20XX6T', 'Alpine', 2023, 2026, 2100000);
INSERT INTO public.contratto VALUES ('MNCJNN84H23XX7U', 'Sauber', 2019, 2023, 1400000);
INSERT INTO public.contratto VALUES ('KMTAYO68L18XX8V', 'Haas', 2016, 2026, 2500000);
INSERT INTO public.contratto VALUES ('PLOGGE69D12XX9W', 'Ferrari', 2015, 2025, 1000000);
INSERT INTO public.contratto VALUES ('SRRLOC72L04XX0X', 'Ferrari', 2024, 2027, 3000000);
INSERT INTO public.contratto VALUES ('BLNERC93H28XX1Y', 'Aston Martin', 2022, 2026, 2800000);
INSERT INTO public.contratto VALUES ('MTSMRC72D14XX2Z', 'RB', 2024, 2026, 1500000);
INSERT INTO public.contratto VALUES ('DBRDKR73L21XX3A', 'Alpine', 2020, 2025, 2000000);
INSERT INTO public.contratto VALUES ('CRTJNT74H08XX4B', 'Williams', 2023, 2026, 1800000);
INSERT INTO public.contratto VALUES ('PJLXEV75D19XX5C', 'Sauber', 2020, 2025, 2200000);
INSERT INTO public.contratto VALUES ('STNGHT76L12XX6D', 'Haas', 2016, 2023, 3500000);
INSERT INTO public.contratto VALUES ('TSTFRN77D30XX7E', 'RB', 2006, 2023, 3000000);
INSERT INTO public.contratto VALUES ('MKSLRT78L11XX8F', 'RB', 2024, 2027, 3200000);
INSERT INTO public.contratto VALUES ('WLFTTO68H12XX9G', 'Mercedes', 2013, 2026, 8000000);
INSERT INTO public.contratto VALUES ('HRNCRN74D25XX0H', 'Red Bull', 2005, 2026, 10000000);
INSERT INTO public.contratto VALUES ('SZFOTM74L23XX1I', 'Alpine', 2022, 2023, 4000000);
INSERT INTO public.contratto VALUES ('KRKMKE82H14XX2L', 'Aston Martin', 2022, 2026, 3800000);
INSERT INTO public.contratto VALUES ('VSSFRK83D19XX3M', 'Ferrari', 2023, 2027, 6000000);
INSERT INTO public.contratto VALUES ('TMBNIK84L21XX4N', 'Ferrari', 1997, 2003, 2000000);
INSERT INTO public.contratto VALUES ('TMBNIK84L21XX4N', 'Ferrari', 2021, 2026, 4000000);
INSERT INTO public.contratto VALUES ('MRSHLL85H08XX5O', 'McLaren', 2024, 2027, 4200000);


--
-- TOC entry 3532 (class 0 OID 16466)
-- Dependencies: 217
-- Data for Name: gara; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.gara VALUES ('2022-03-20', 'Sakhir', 'Soleggiato', 29.5, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2022-03-27', 'Jeddah', 'Soleggiato', 31, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2022-04-10', 'Albert Park', 'Soleggiato', 23, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2022-05-29', 'Monaco', 'Pioggia', 19, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2022-09-04', 'Zandvoort', 'Soleggiato', 24.5, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2022-09-11', 'Monza', 'Soleggiato', 29, 'Formula 1 World Championship', 2022);
INSERT INTO public.gara VALUES ('2023-03-05', 'Miami', 'Soleggiato', 30, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2023-03-19', 'Imola', 'Nuvoloso', 22, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2023-04-02', 'Montreal', 'Soleggiato', 18.5, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2023-05-28', 'Spielberg', 'Soleggiato', 25, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2023-08-27', 'Budapest', 'Pioggia', 21.5, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2023-09-03', 'Spa', 'Soleggiato', 23, 'Formula 1 World Championship', 2023);
INSERT INTO public.gara VALUES ('2024-03-02', 'Suzuka', 'Soleggiato', 21.5, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2024-03-09', 'Shanghai', 'Soleggiato', 19, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2024-03-24', 'Barcelona', 'Soleggiato', 24, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2024-05-26', 'Silverstone', 'Nuvoloso', 17.1, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2024-08-25', 'Baku', 'Soleggiato', 31, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2024-09-01', 'Marina Bay', 'Nuvoloso', 30.5, 'Formula 1 World Championship', 2024);
INSERT INTO public.gara VALUES ('2025-03-02', 'Austin', 'Soleggiato', 26, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2025-03-09', 'Città del Messico', 'Soleggiato', 24.5, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2025-03-23', 'Interlagos', 'Nuvoloso', 22.5, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2025-05-25', 'Las Vegas', 'Soleggiato', 18, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2025-08-24', 'Losail', 'Soleggiato', 34.5, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2025-08-31', 'Yas Marina', 'Soleggiato', 32, 'Formula 1 World Championship', 2025);
INSERT INTO public.gara VALUES ('2026-03-15', 'Spa', 'Nuvoloso', 15, 'Formula 1 World Championship', 2026);
INSERT INTO public.gara VALUES ('2026-03-29', 'Monza', 'Soleggiato', 22, 'Formula 1 World Championship', 2026);
INSERT INTO public.gara VALUES ('2026-04-12', 'Suzuka', 'Soleggiato', 18.5, 'Formula 1 World Championship', 2026);
INSERT INTO public.gara VALUES ('2026-05-24', 'Monaco', 'Soleggiato', 24, 'Formula 1 World Championship', 2026);
INSERT INTO public.gara VALUES ('2026-07-05', 'Silverstone', 'Pioggia', 16, 'Formula 1 World Championship', 2026);
INSERT INTO public.gara VALUES ('2026-09-06', 'Interlagos', 'Soleggiato', 25, 'Formula 1 World Championship', 2026);


--
-- TOC entry 3540 (class 0 OID 16568)
-- Dependencies: 225
-- Data for Name: giro; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-20', 'Sakhir', 1, 29.112, 39.050, 23.141, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-20', 'Sakhir', 2, 28.216, 38.133, 23.499, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-20', 'Sakhir', 3, 28.376, 39.315, 24.019, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-20', 'Sakhir', 1, 30.353, 39.180, 24.320, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-20', 'Sakhir', 2, 29.413, 39.026, 23.384, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-20', 'Sakhir', 3, 29.333, 40.352, 24.079, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-20', 'Sakhir', 1, 28.196, 38.162, 23.253, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-20', 'Sakhir', 2, 28.253, 38.269, 22.184, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-20', 'Sakhir', 3, 28.290, 38.059, 23.196, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-20', 'Sakhir', 1, 29.431, 39.407, 23.146, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-20', 'Sakhir', 2, 29.434, 38.064, 23.423, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-20', 'Sakhir', 3, 29.410, 39.337, 23.212, 'Soft');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-03-20', 'Sakhir', 1, 29.438, 39.439, 24.349, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-03-20', 'Sakhir', 2, 29.055, 39.011, 24.249, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-03-20', 'Sakhir', 3, 29.386, 39.246, 23.267, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-03-20', 'Sakhir', 1, 30.496, 40.245, 24.202, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-03-20', 'Sakhir', 2, 29.382, 39.068, 24.390, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-03-20', 'Sakhir', 3, 29.290, 39.336, 24.044, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-27', 'Jeddah', 1, 32.440, 28.175, 27.135, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-27', 'Jeddah', 2, 31.074, 28.040, 27.173, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-03-27', 'Jeddah', 3, 32.136, 28.433, 27.236, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-27', 'Jeddah', 1, 31.305, 28.175, 27.338, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-27', 'Jeddah', 2, 31.210, 28.030, 27.092, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-03-27', 'Jeddah', 3, 32.334, 29.394, 27.178, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-27', 'Jeddah', 1, 31.023, 28.467, 27.105, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-27', 'Jeddah', 2, 31.211, 27.284, 26.100, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-03-27', 'Jeddah', 3, 31.239, 28.318, 27.092, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-27', 'Jeddah', 1, 32.163, 28.020, 27.136, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-27', 'Jeddah', 2, 32.435, 28.243, 27.453, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-03-27', 'Jeddah', 3, 32.061, 28.325, 27.230, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-03-27', 'Jeddah', 1, 32.486, 29.060, 28.188, 'Hard');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-03-27', 'Jeddah', 2, 32.251, 29.039, 28.358, 'Hard');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-03-27', 'Jeddah', 3, 32.133, 29.151, 28.075, 'Hard');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-03-27', 'Jeddah', 1, 33.256, 29.070, 28.460, 'Hard');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-03-27', 'Jeddah', 2, 32.059, 29.218, 28.321, 'Hard');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-03-27', 'Jeddah', 3, 33.394, 29.329, 28.465, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-04-10', 'Albert Park', 1, 27.027, 22.104, 31.452, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-04-10', 'Albert Park', 2, 27.173, 22.157, 31.264, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-04-10', 'Albert Park', 3, 27.251, 22.298, 31.257, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-04-10', 'Albert Park', 1, 26.475, 22.093, 30.030, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-04-10', 'Albert Park', 2, 26.038, 21.162, 30.270, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-04-10', 'Albert Park', 3, 26.186, 22.093, 30.476, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-04-10', 'Albert Park', 1, 27.282, 22.016, 31.483, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-04-10', 'Albert Park', 2, 27.447, 22.136, 31.018, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-04-10', 'Albert Park', 3, 27.126, 22.012, 31.025, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-04-10', 'Albert Park', 1, 27.323, 23.392, 31.172, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-04-10', 'Albert Park', 2, 27.011, 23.155, 31.138, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2022-04-10', 'Albert Park', 3, 27.041, 22.279, 31.268, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-04-10', 'Albert Park', 1, 27.210, 22.473, 31.023, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-04-10', 'Albert Park', 2, 27.218, 22.017, 31.367, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2022-04-10', 'Albert Park', 3, 27.203, 22.398, 31.302, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-04-10', 'Albert Park', 1, 28.138, 23.333, 32.372, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-04-10', 'Albert Park', 2, 28.138, 23.177, 32.384, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-04-10', 'Albert Park', 3, 28.273, 23.439, 32.059, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-05-29', 'Monaco', 1, 24.092, 35.361, 26.354, 'Intermedie');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-05-29', 'Monaco', 2, 24.030, 35.096, 25.082, 'Intermedie');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-05-29', 'Monaco', 3, 23.144, 34.288, 25.439, 'Intermedie');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-05-29', 'Monaco', 1, 23.223, 34.107, 25.041, 'Intermedie');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-05-29', 'Monaco', 2, 23.066, 34.315, 24.239, 'Intermedie');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2022-05-29', 'Monaco', 3, 23.311, 34.079, 24.140, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-05-29', 'Monaco', 1, 23.352, 33.389, 25.150, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-05-29', 'Monaco', 2, 23.477, 33.259, 24.472, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-05-29', 'Monaco', 3, 23.419, 34.442, 25.041, 'Intermedie');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-05-29', 'Monaco', 1, 23.476, 34.083, 25.466, 'Intermedie');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-05-29', 'Monaco', 2, 23.173, 34.024, 25.128, 'Intermedie');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2022-05-29', 'Monaco', 3, 23.297, 34.326, 24.395, 'Intermedie');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-05-29', 'Monaco', 1, 24.491, 36.436, 26.245, 'Wet');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-05-29', 'Monaco', 2, 24.250, 36.109, 26.411, 'Wet');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-05-29', 'Monaco', 3, 24.259, 35.211, 26.205, 'Wet');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-05-29', 'Monaco', 1, 25.314, 37.195, 27.080, 'Wet');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-05-29', 'Monaco', 2, 25.035, 36.137, 27.483, 'Wet');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-05-29', 'Monaco', 3, 25.055, 36.122, 27.306, 'Wet');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-04', 'Zandvoort', 1, 25.317, 26.004, 23.162, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-04', 'Zandvoort', 2, 24.202, 26.088, 22.313, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-04', 'Zandvoort', 3, 24.046, 26.127, 23.328, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-04', 'Zandvoort', 1, 25.331, 26.164, 23.204, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-04', 'Zandvoort', 2, 25.251, 26.127, 23.125, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-04', 'Zandvoort', 3, 25.200, 26.446, 23.335, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-09-04', 'Zandvoort', 1, 25.426, 27.015, 24.118, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-09-04', 'Zandvoort', 2, 25.485, 27.461, 23.176, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2022-09-04', 'Zandvoort', 3, 25.022, 27.295, 24.144, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2022-09-04', 'Zandvoort', 1, 26.143, 27.435, 24.389, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2022-09-04', 'Zandvoort', 2, 25.499, 27.472, 24.314, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2022-09-04', 'Zandvoort', 3, 26.346, 27.270, 24.179, 'Medium');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-09-04', 'Zandvoort', 1, 26.232, 27.044, 24.127, 'Hard');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-09-04', 'Zandvoort', 2, 26.126, 27.089, 24.193, 'Hard');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2022-09-04', 'Zandvoort', 3, 26.376, 27.224, 24.399, 'Hard');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-09-04', 'Zandvoort', 1, 26.126, 28.361, 25.079, 'Hard');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-09-04', 'Zandvoort', 2, 26.128, 27.092, 25.101, 'Hard');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2022-09-04', 'Zandvoort', 3, 26.239, 27.421, 25.431, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-11', 'Monza', 1, 27.058, 29.458, 28.405, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-11', 'Monza', 2, 26.099, 29.033, 28.412, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2022-09-11', 'Monza', 3, 26.124, 29.163, 27.445, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-11', 'Monza', 1, 27.411, 28.042, 28.222, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-11', 'Monza', 2, 27.040, 28.465, 28.204, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2022-09-11', 'Monza', 3, 27.383, 28.046, 28.299, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-09-11', 'Monza', 1, 28.199, 30.237, 29.087, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-09-11', 'Monza', 2, 27.145, 30.167, 29.304, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2022-09-11', 'Monza', 3, 28.172, 30.206, 29.317, 'Medium');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-09-11', 'Monza', 1, 28.103, 30.034, 29.290, 'Medium');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-09-11', 'Monza', 2, 28.458, 30.104, 29.029, 'Medium');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2022-09-11', 'Monza', 3, 28.464, 30.274, 29.052, 'Medium');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2022-09-11', 'Monza', 1, 28.366, 30.247, 29.173, 'Hard');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2022-09-11', 'Monza', 2, 28.248, 30.070, 29.051, 'Hard');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2022-09-11', 'Monza', 3, 28.377, 30.042, 29.209, 'Hard');
INSERT INTO public.giro VALUES ('SRGLGN98D03XX4P', '2022-09-11', 'Monza', 1, 29.086, 31.413, 30.154, 'Hard');
INSERT INTO public.giro VALUES ('SRGLGN98D03XX4P', '2022-09-11', 'Monza', 2, 28.181, 31.231, 30.091, 'Hard');
INSERT INTO public.giro VALUES ('SRGLGN98D03XX4P', '2022-09-11', 'Monza', 3, 29.274, 31.232, 30.360, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-05', 'Miami', 1, 29.141, 34.306, 27.201, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-05', 'Miami', 2, 29.390, 33.089, 27.171, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-05', 'Miami', 3, 29.373, 34.336, 27.338, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-03-05', 'Miami', 1, 29.103, 34.276, 27.408, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-03-05', 'Miami', 2, 29.361, 34.011, 27.044, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-03-05', 'Miami', 3, 30.029, 34.067, 28.145, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-03-05', 'Miami', 1, 30.033, 35.006, 28.305, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-03-05', 'Miami', 2, 30.477, 34.246, 27.101, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-03-05', 'Miami', 3, 30.165, 35.276, 28.002, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-03-05', 'Miami', 1, 30.279, 35.116, 27.029, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-03-05', 'Miami', 2, 30.077, 34.427, 27.164, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-03-05', 'Miami', 3, 30.253, 35.109, 28.462, 'Hard');
INSERT INTO public.giro VALUES ('TSNYKI04A03XX5Q', '2023-03-05', 'Miami', 1, 31.422, 36.209, 29.143, 'Soft');
INSERT INTO public.giro VALUES ('TSNYKI04A03XX5Q', '2023-03-05', 'Miami', 2, 30.448, 35.334, 28.403, 'Soft');
INSERT INTO public.giro VALUES ('TSNYKI04A03XX5Q', '2023-03-05', 'Miami', 3, 30.229, 35.054, 29.230, 'Soft');
INSERT INTO public.giro VALUES ('RCCDNL89H01XX6R', '2023-03-05', 'Miami', 1, 30.027, 36.243, 28.245, 'Soft');
INSERT INTO public.giro VALUES ('RCCDNL89H01XX6R', '2023-03-05', 'Miami', 2, 30.141, 35.006, 28.008, 'Soft');
INSERT INTO public.giro VALUES ('RCCDNL89H01XX6R', '2023-03-05', 'Miami', 3, 30.382, 35.492, 28.485, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-19', 'Imola', 1, 25.448, 28.123, 24.363, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-19', 'Imola', 2, 25.440, 27.315, 24.383, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-03-19', 'Imola', 3, 25.167, 28.116, 24.145, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-03-19', 'Imola', 1, 25.237, 28.282, 24.451, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-03-19', 'Imola', 2, 25.442, 28.078, 24.350, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-03-19', 'Imola', 3, 25.207, 28.355, 24.447, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-03-19', 'Imola', 1, 26.201, 28.405, 25.133, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-03-19', 'Imola', 2, 25.168, 28.033, 25.069, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-03-19', 'Imola', 3, 26.303, 28.055, 25.349, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-03-19', 'Imola', 1, 26.298, 28.417, 25.466, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-03-19', 'Imola', 2, 26.196, 28.345, 25.399, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-03-19', 'Imola', 3, 26.033, 28.241, 25.321, 'Medium');
INSERT INTO public.giro VALUES ('BTTVAL89B28XX7S', '2023-03-19', 'Imola', 1, 26.176, 29.167, 25.357, 'Hard');
INSERT INTO public.giro VALUES ('BTTVAL89B28XX7S', '2023-03-19', 'Imola', 2, 26.327, 29.283, 25.056, 'Hard');
INSERT INTO public.giro VALUES ('BTTVAL89B28XX7S', '2023-03-19', 'Imola', 3, 26.334, 29.186, 25.429, 'Hard');
INSERT INTO public.giro VALUES ('ZHOGYN99D30XX8T', '2023-03-19', 'Imola', 1, 27.172, 29.477, 26.491, 'Hard');
INSERT INTO public.giro VALUES ('ZHOGYN99D30XX8T', '2023-03-19', 'Imola', 2, 26.354, 29.312, 26.177, 'Hard');
INSERT INTO public.giro VALUES ('ZHOGYN99D30XX8T', '2023-03-19', 'Imola', 3, 27.285, 29.189, 26.106, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-04-02', 'Montreal', 1, 22.289, 23.048, 25.480, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-04-02', 'Montreal', 2, 21.026, 23.173, 25.020, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-04-02', 'Montreal', 3, 22.211, 23.290, 25.003, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-04-02', 'Montreal', 1, 22.064, 23.405, 25.480, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-04-02', 'Montreal', 2, 22.072, 23.235, 25.193, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-04-02', 'Montreal', 3, 22.266, 23.110, 25.083, 'Soft');
INSERT INTO public.giro VALUES ('MGNKVN92L05XX9U', '2023-04-02', 'Montreal', 1, 23.297, 24.288, 26.431, 'Medium');
INSERT INTO public.giro VALUES ('MGNKVN92L05XX9U', '2023-04-02', 'Montreal', 2, 23.310, 24.291, 26.381, 'Medium');
INSERT INTO public.giro VALUES ('MGNKVN92L05XX9U', '2023-04-02', 'Montreal', 3, 23.398, 24.398, 26.410, 'Medium');
INSERT INTO public.giro VALUES ('HLKNIC87M01XX0V', '2023-04-02', 'Montreal', 1, 23.064, 24.160, 26.399, 'Medium');
INSERT INTO public.giro VALUES ('HLKNIC87M01XX0V', '2023-04-02', 'Montreal', 2, 23.249, 24.252, 26.312, 'Medium');
INSERT INTO public.giro VALUES ('HLKNIC87M01XX0V', '2023-04-02', 'Montreal', 3, 23.020, 24.078, 26.064, 'Medium');
INSERT INTO public.giro VALUES ('GVNNTN93H21XX1W', '2023-04-02', 'Montreal', 1, 24.149, 25.489, 27.451, 'Hard');
INSERT INTO public.giro VALUES ('GVNNTN93H21XX1W', '2023-04-02', 'Montreal', 2, 23.294, 25.377, 27.151, 'Hard');
INSERT INTO public.giro VALUES ('GVNNTN93H21XX1W', '2023-04-02', 'Montreal', 3, 24.066, 25.401, 27.204, 'Hard');
INSERT INTO public.giro VALUES ('RKKKIM79L17XX2X', '2023-04-02', 'Montreal', 1, 23.133, 25.461, 26.276, 'Hard');
INSERT INTO public.giro VALUES ('RKKKIM79L17XX2X', '2023-04-02', 'Montreal', 2, 23.265, 25.374, 26.152, 'Hard');
INSERT INTO public.giro VALUES ('RKKKIM79L17XX2X', '2023-04-02', 'Montreal', 3, 23.294, 25.407, 26.227, 'Hard');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-05-28', 'Spielberg', 1, 17.430, 30.250, 21.453, 'Soft');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-05-28', 'Spielberg', 2, 16.479, 30.166, 20.063, 'Soft');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-05-28', 'Spielberg', 3, 17.439, 30.016, 21.355, 'Soft');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2023-05-28', 'Spielberg', 1, 17.329, 31.409, 21.223, 'Soft');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2023-05-28', 'Spielberg', 2, 17.182, 30.217, 21.035, 'Soft');
INSERT INTO public.giro VALUES ('STRLNC98H29XX0L', '2023-05-28', 'Spielberg', 3, 17.383, 31.378, 21.099, 'Soft');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2023-05-28', 'Spielberg', 1, 17.389, 31.080, 21.092, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2023-05-28', 'Spielberg', 2, 17.007, 31.332, 21.252, 'Medium');
INSERT INTO public.giro VALUES ('OCNEBN96A17XX1M', '2023-05-28', 'Spielberg', 3, 17.059, 31.353, 21.157, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-05-28', 'Spielberg', 1, 17.336, 31.318, 21.155, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-05-28', 'Spielberg', 2, 17.328, 30.043, 21.335, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-05-28', 'Spielberg', 3, 17.242, 31.456, 21.294, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-05-28', 'Spielberg', 1, 17.190, 31.400, 21.397, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-05-28', 'Spielberg', 2, 17.152, 31.049, 21.108, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-05-28', 'Spielberg', 3, 17.211, 31.196, 21.359, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2023-05-28', 'Spielberg', 1, 18.269, 32.217, 22.368, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2023-05-28', 'Spielberg', 2, 17.113, 32.059, 22.109, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2023-05-28', 'Spielberg', 3, 18.046, 32.337, 22.389, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-08-27', 'Budapest', 1, 30.065, 29.045, 23.391, 'Intermedie');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-08-27', 'Budapest', 2, 29.140, 29.493, 22.496, 'Intermedie');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-08-27', 'Budapest', 3, 30.142, 29.170, 23.397, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-08-27', 'Budapest', 1, 30.068, 29.461, 23.242, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-08-27', 'Budapest', 2, 30.126, 29.029, 23.017, 'Intermedie');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-08-27', 'Budapest', 3, 30.471, 29.314, 23.142, 'Intermedie');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-08-27', 'Budapest', 1, 31.018, 30.424, 24.397, 'Intermedie');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-08-27', 'Budapest', 2, 30.205, 30.313, 24.449, 'Intermedie');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2023-08-27', 'Budapest', 3, 31.263, 30.451, 24.203, 'Intermedie');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2023-08-27', 'Budapest', 1, 31.102, 30.191, 24.416, 'Intermedie');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2023-08-27', 'Budapest', 2, 31.276, 30.466, 24.075, 'Intermedie');
INSERT INTO public.giro VALUES ('GSNPRE96L07XX2N', '2023-08-27', 'Budapest', 3, 31.018, 30.471, 24.067, 'Intermedie');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-08-27', 'Budapest', 1, 31.496, 30.368, 24.355, 'Intermedie');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-08-27', 'Budapest', 2, 31.272, 30.481, 24.043, 'Intermedie');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2023-08-27', 'Budapest', 3, 31.415, 30.168, 24.356, 'Intermedie');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2023-08-27', 'Budapest', 1, 32.136, 31.334, 25.078, 'Wet');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2023-08-27', 'Budapest', 2, 32.115, 31.398, 25.463, 'Wet');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2023-08-27', 'Budapest', 3, 32.090, 31.068, 25.446, 'Wet');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-09-03', 'Spa', 1, 41.251, 48.187, 28.152, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-09-03', 'Spa', 2, 40.011, 47.151, 28.247, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2023-09-03', 'Spa', 3, 40.482, 48.376, 28.142, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-09-03', 'Spa', 1, 41.481, 48.224, 28.462, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-09-03', 'Spa', 2, 41.442, 48.337, 28.003, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2023-09-03', 'Spa', 3, 41.056, 49.135, 29.227, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-09-03', 'Spa', 1, 41.267, 49.497, 29.423, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-09-03', 'Spa', 2, 41.038, 48.337, 29.295, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2023-09-03', 'Spa', 3, 41.112, 49.259, 29.197, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-09-03', 'Spa', 1, 41.018, 48.317, 28.336, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-09-03', 'Spa', 2, 41.418, 48.279, 28.241, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2023-09-03', 'Spa', 3, 41.116, 48.128, 28.169, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-09-03', 'Spa', 1, 42.343, 49.245, 29.489, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-09-03', 'Spa', 2, 41.154, 49.218, 29.014, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2023-09-03', 'Spa', 3, 42.158, 49.248, 29.207, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-09-03', 'Spa', 1, 42.468, 49.286, 29.108, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-09-03', 'Spa', 2, 41.232, 49.050, 29.026, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2023-09-03', 'Spa', 3, 42.199, 49.085, 29.133, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-02', 'Suzuka', 1, 32.101, 41.401, 18.303, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-02', 'Suzuka', 2, 31.376, 40.430, 18.198, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-02', 'Suzuka', 3, 31.070, 41.420, 18.196, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-02', 'Suzuka', 1, 32.174, 41.339, 18.252, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-02', 'Suzuka', 2, 32.157, 41.178, 18.195, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-02', 'Suzuka', 3, 32.469, 42.379, 19.219, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-02', 'Suzuka', 1, 32.211, 41.123, 18.000, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-02', 'Suzuka', 2, 32.072, 40.344, 18.394, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-02', 'Suzuka', 3, 32.062, 41.354, 18.084, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-03-02', 'Suzuka', 1, 32.308, 41.235, 18.476, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-03-02', 'Suzuka', 2, 32.142, 41.324, 18.219, 'Medium');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-03-02', 'Suzuka', 3, 32.123, 41.163, 18.388, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-02', 'Suzuka', 1, 33.250, 42.114, 19.328, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-02', 'Suzuka', 2, 33.485, 42.298, 19.411, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-02', 'Suzuka', 3, 33.480, 42.280, 19.034, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-02', 'Suzuka', 1, 33.012, 42.327, 19.156, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-02', 'Suzuka', 2, 33.055, 42.370, 19.420, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-02', 'Suzuka', 3, 33.378, 42.292, 19.224, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-09', 'Shanghai', 1, 26.400, 29.480, 40.282, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-09', 'Shanghai', 2, 25.298, 29.037, 39.295, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-09', 'Shanghai', 3, 26.118, 29.357, 40.269, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-09', 'Shanghai', 1, 26.001, 29.311, 40.339, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-09', 'Shanghai', 2, 26.007, 29.217, 40.298, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-03-09', 'Shanghai', 3, 26.086, 30.441, 41.475, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-09', 'Shanghai', 1, 26.139, 30.276, 40.395, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-09', 'Shanghai', 2, 26.208, 29.495, 40.278, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-09', 'Shanghai', 3, 26.337, 30.186, 40.217, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-09', 'Shanghai', 1, 26.292, 29.092, 40.017, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-09', 'Shanghai', 2, 26.378, 29.003, 40.019, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-09', 'Shanghai', 3, 26.437, 29.400, 40.341, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-09', 'Shanghai', 1, 27.175, 30.485, 41.331, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-09', 'Shanghai', 2, 26.456, 30.083, 41.217, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-09', 'Shanghai', 3, 27.474, 30.398, 41.239, 'Soft');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2024-03-09', 'Shanghai', 1, 27.080, 30.377, 41.449, 'Soft');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2024-03-09', 'Shanghai', 2, 27.046, 30.112, 41.283, 'Soft');
INSERT INTO public.giro VALUES ('LNSFND81H29XX9I', '2024-03-09', 'Shanghai', 3, 27.199, 30.266, 41.486, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-24', 'Barcelona', 1, 23.456, 30.052, 21.228, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-24', 'Barcelona', 2, 22.119, 30.298, 21.468, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-03-24', 'Barcelona', 3, 23.059, 30.042, 21.117, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-24', 'Barcelona', 1, 23.137, 31.167, 21.328, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-24', 'Barcelona', 2, 23.319, 30.234, 21.258, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-03-24', 'Barcelona', 3, 23.454, 31.060, 21.098, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-24', 'Barcelona', 1, 24.186, 31.111, 22.305, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-24', 'Barcelona', 2, 24.004, 31.404, 22.216, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-03-24', 'Barcelona', 3, 24.431, 31.135, 22.159, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-24', 'Barcelona', 1, 24.066, 31.440, 22.129, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-24', 'Barcelona', 2, 24.056, 31.165, 22.139, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-03-24', 'Barcelona', 3, 24.016, 31.329, 22.154, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-24', 'Barcelona', 1, 23.400, 30.426, 21.273, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-24', 'Barcelona', 2, 23.029, 30.163, 21.213, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-03-24', 'Barcelona', 3, 23.462, 30.257, 21.044, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-24', 'Barcelona', 1, 24.079, 31.012, 22.136, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-24', 'Barcelona', 2, 23.446, 31.395, 22.024, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-03-24', 'Barcelona', 3, 24.395, 31.094, 22.376, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-05-26', 'Silverstone', 1, 28.255, 36.169, 25.205, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-05-26', 'Silverstone', 2, 28.209, 35.221, 25.053, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-05-26', 'Silverstone', 3, 28.136, 36.179, 25.116, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-05-26', 'Silverstone', 1, 28.047, 36.193, 25.309, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-05-26', 'Silverstone', 2, 28.326, 35.257, 25.481, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-05-26', 'Silverstone', 3, 28.277, 36.137, 25.225, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-05-26', 'Silverstone', 1, 28.101, 35.483, 25.284, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-05-26', 'Silverstone', 2, 28.014, 35.249, 24.146, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-05-26', 'Silverstone', 3, 28.353, 35.306, 25.419, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-05-26', 'Silverstone', 1, 28.107, 36.090, 25.421, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-05-26', 'Silverstone', 2, 28.106, 36.422, 25.452, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-05-26', 'Silverstone', 3, 28.303, 36.022, 25.226, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-05-26', 'Silverstone', 1, 28.359, 36.431, 25.072, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-05-26', 'Silverstone', 2, 28.174, 36.497, 25.056, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-05-26', 'Silverstone', 3, 28.329, 36.312, 25.482, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-05-26', 'Silverstone', 1, 28.184, 36.153, 25.118, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-05-26', 'Silverstone', 2, 28.052, 35.159, 25.226, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-05-26', 'Silverstone', 3, 28.218, 36.038, 25.294, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-08-25', 'Baku', 1, 36.047, 41.196, 26.360, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-08-25', 'Baku', 2, 35.486, 41.129, 26.378, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-08-25', 'Baku', 3, 36.185, 41.257, 26.064, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-08-25', 'Baku', 1, 36.467, 41.064, 26.126, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-08-25', 'Baku', 2, 36.031, 41.191, 26.025, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2024-08-25', 'Baku', 3, 36.365, 41.421, 26.284, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-08-25', 'Baku', 1, 36.373, 41.420, 26.093, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-08-25', 'Baku', 2, 35.009, 41.318, 25.010, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-08-25', 'Baku', 3, 36.448, 41.168, 26.291, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-08-25', 'Baku', 1, 37.395, 42.091, 27.296, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-08-25', 'Baku', 2, 37.377, 42.276, 27.176, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-08-25', 'Baku', 3, 37.463, 42.258, 27.490, 'Hard');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-08-25', 'Baku', 1, 36.032, 41.209, 26.145, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-08-25', 'Baku', 2, 36.043, 41.463, 26.360, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2024-08-25', 'Baku', 3, 36.354, 41.185, 26.143, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-08-25', 'Baku', 1, 36.093, 41.240, 26.388, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-08-25', 'Baku', 2, 35.048, 41.238, 26.264, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-08-25', 'Baku', 3, 36.091, 41.482, 26.045, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-09-01', 'Marina Bay', 1, 31.402, 40.323, 33.136, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-09-01', 'Marina Bay', 2, 30.055, 40.246, 33.022, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2024-09-01', 'Marina Bay', 3, 31.116, 40.117, 33.326, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-09-01', 'Marina Bay', 1, 31.011, 41.493, 34.109, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-09-01', 'Marina Bay', 2, 31.499, 40.017, 34.291, 'Medium');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2024-09-01', 'Marina Bay', 3, 31.394, 41.469, 34.061, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-09-01', 'Marina Bay', 1, 32.101, 41.183, 34.002, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-09-01', 'Marina Bay', 2, 31.214, 41.297, 34.305, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2024-09-01', 'Marina Bay', 3, 32.462, 41.494, 34.102, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-09-01', 'Marina Bay', 1, 31.004, 41.386, 34.232, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-09-01', 'Marina Bay', 2, 31.274, 40.233, 33.107, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2024-09-01', 'Marina Bay', 3, 31.042, 41.328, 34.136, 'Hard');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-09-01', 'Marina Bay', 1, 32.070, 41.218, 34.180, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-09-01', 'Marina Bay', 2, 31.454, 41.302, 34.274, 'Soft');
INSERT INTO public.giro VALUES ('SNZCLS94M01XX4D', '2024-09-01', 'Marina Bay', 3, 32.354, 41.073, 34.417, 'Soft');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-09-01', 'Marina Bay', 1, 32.017, 42.057, 35.309, 'Soft');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-09-01', 'Marina Bay', 2, 32.183, 41.500, 35.261, 'Soft');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2024-09-01', 'Marina Bay', 3, 32.103, 42.095, 35.486, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-02', 'Austin', 1, 28.466, 39.418, 31.268, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-02', 'Austin', 2, 27.276, 39.427, 30.472, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-02', 'Austin', 3, 28.450, 39.393, 31.428, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-02', 'Austin', 1, 28.145, 39.451, 31.230, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-02', 'Austin', 2, 28.289, 39.135, 31.459, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-02', 'Austin', 3, 28.028, 39.264, 31.224, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-02', 'Austin', 1, 28.240, 40.038, 31.045, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-02', 'Austin', 2, 28.101, 39.300, 31.005, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-02', 'Austin', 3, 28.440, 40.032, 31.383, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-02', 'Austin', 1, 28.066, 39.255, 31.444, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-02', 'Austin', 2, 28.293, 39.065, 31.426, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-02', 'Austin', 3, 28.047, 39.404, 31.376, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-02', 'Austin', 1, 29.196, 40.128, 32.064, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-02', 'Austin', 2, 29.222, 40.116, 31.462, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-02', 'Austin', 3, 29.353, 40.323, 32.399, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-02', 'Austin', 1, 29.417, 40.292, 32.351, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-02', 'Austin', 2, 28.115, 40.331, 31.208, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-02', 'Austin', 3, 29.349, 40.236, 32.003, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-09', 'Città del Messico', 1, 27.264, 30.385, 21.462, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-09', 'Città del Messico', 2, 26.470, 30.172, 21.156, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-09', 'Città del Messico', 3, 27.256, 30.201, 21.260, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-03-09', 'Città del Messico', 1, 27.444, 31.155, 22.460, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-03-09', 'Città del Messico', 2, 27.416, 30.149, 21.317, 'Soft');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-03-09', 'Città del Messico', 3, 27.348, 31.108, 22.402, 'Soft');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-09', 'Città del Messico', 1, 27.303, 30.310, 21.381, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-09', 'Città del Messico', 2, 27.479, 30.298, 21.304, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-09', 'Città del Messico', 3, 27.274, 30.456, 21.149, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-09', 'Città del Messico', 1, 27.223, 31.097, 21.214, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-09', 'Città del Messico', 2, 27.496, 30.227, 21.008, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-09', 'Città del Messico', 3, 27.113, 31.493, 21.395, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-09', 'Città del Messico', 1, 27.275, 31.414, 21.327, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-09', 'Città del Messico', 2, 27.471, 31.061, 21.109, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-09', 'Città del Messico', 3, 27.292, 31.499, 21.063, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-09', 'Città del Messico', 1, 28.491, 31.072, 22.014, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-09', 'Città del Messico', 2, 27.371, 31.301, 22.050, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-09', 'Città del Messico', 3, 28.163, 31.199, 22.058, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-23', 'Interlagos', 1, 19.371, 36.064, 17.165, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-23', 'Interlagos', 2, 18.418, 36.196, 17.056, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-03-23', 'Interlagos', 3, 19.233, 36.445, 17.021, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-23', 'Interlagos', 1, 19.457, 36.093, 17.161, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-23', 'Interlagos', 2, 19.317, 35.003, 17.205, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-03-23', 'Interlagos', 3, 19.010, 36.240, 17.023, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-23', 'Interlagos', 1, 19.489, 36.339, 17.082, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-23', 'Interlagos', 2, 19.465, 36.430, 17.455, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-03-23', 'Interlagos', 3, 19.446, 36.114, 17.088, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-23', 'Interlagos', 1, 19.247, 36.163, 17.106, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-23', 'Interlagos', 2, 19.213, 36.018, 17.004, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-03-23', 'Interlagos', 3, 19.361, 36.469, 17.015, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-23', 'Interlagos', 1, 20.378, 37.443, 18.262, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-23', 'Interlagos', 2, 19.405, 37.261, 18.364, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-03-23', 'Interlagos', 3, 20.337, 37.432, 18.230, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-23', 'Interlagos', 1, 20.223, 37.250, 18.145, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-23', 'Interlagos', 2, 19.371, 37.242, 18.166, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-03-23', 'Interlagos', 3, 20.248, 37.075, 18.420, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-05-25', 'Las Vegas', 1, 28.159, 32.355, 34.335, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-05-25', 'Las Vegas', 2, 27.466, 32.226, 33.124, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-05-25', 'Las Vegas', 3, 28.074, 32.243, 34.024, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-05-25', 'Las Vegas', 1, 28.327, 33.423, 34.202, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-05-25', 'Las Vegas', 2, 28.270, 32.198, 34.154, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-05-25', 'Las Vegas', 3, 29.471, 33.476, 35.130, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-05-25', 'Las Vegas', 1, 28.393, 32.317, 34.433, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-05-25', 'Las Vegas', 2, 28.431, 32.439, 34.367, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-05-25', 'Las Vegas', 3, 28.420, 32.273, 34.209, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-05-25', 'Las Vegas', 1, 28.199, 33.295, 34.412, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-05-25', 'Las Vegas', 2, 28.265, 32.423, 34.368, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-05-25', 'Las Vegas', 3, 28.193, 33.094, 34.203, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-05-25', 'Las Vegas', 1, 28.108, 32.482, 34.324, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-05-25', 'Las Vegas', 2, 28.490, 32.314, 34.095, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-05-25', 'Las Vegas', 3, 28.032, 32.329, 34.340, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-05-25', 'Las Vegas', 1, 29.259, 33.071, 35.403, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-05-25', 'Las Vegas', 2, 28.049, 33.407, 35.269, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-05-25', 'Las Vegas', 3, 29.318, 33.255, 35.002, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-24', 'Losail', 1, 25.263, 28.076, 29.282, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-24', 'Losail', 2, 25.174, 27.294, 29.036, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-24', 'Losail', 3, 25.432, 28.203, 29.379, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-08-24', 'Losail', 1, 25.205, 28.407, 29.261, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-08-24', 'Losail', 2, 25.276, 28.080, 29.048, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2025-08-24', 'Losail', 3, 26.486, 28.058, 30.260, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-24', 'Losail', 1, 25.299, 28.130, 29.268, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-24', 'Losail', 2, 25.387, 28.134, 29.035, 'Hard');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-24', 'Losail', 3, 25.040, 28.248, 29.193, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-24', 'Losail', 1, 25.334, 29.161, 29.252, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-24', 'Losail', 2, 25.023, 28.134, 29.331, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-24', 'Losail', 3, 25.095, 29.314, 29.045, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-24', 'Losail', 1, 25.226, 28.274, 29.178, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-24', 'Losail', 2, 25.254, 28.306, 29.456, 'Soft');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-24', 'Losail', 3, 25.284, 28.098, 29.055, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-24', 'Losail', 1, 26.314, 29.300, 30.165, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-24', 'Losail', 2, 25.207, 29.212, 30.307, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-24', 'Losail', 3, 26.243, 29.432, 30.431, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-31', 'Yas Marina', 1, 26.319, 40.022, 29.079, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-31', 'Yas Marina', 2, 25.046, 39.101, 29.215, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2025-08-31', 'Yas Marina', 3, 26.261, 40.419, 29.045, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-31', 'Yas Marina', 1, 26.406, 40.098, 29.317, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-31', 'Yas Marina', 2, 26.348, 40.275, 29.303, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2025-08-31', 'Yas Marina', 3, 26.049, 40.386, 29.416, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-31', 'Yas Marina', 1, 26.114, 41.180, 30.202, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-31', 'Yas Marina', 2, 26.048, 40.222, 30.181, 'Hard');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2025-08-31', 'Yas Marina', 3, 26.449, 41.035, 30.387, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-31', 'Yas Marina', 1, 26.269, 40.389, 29.462, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-31', 'Yas Marina', 2, 26.235, 40.240, 29.435, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2025-08-31', 'Yas Marina', 3, 26.177, 40.334, 29.044, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-31', 'Yas Marina', 1, 27.257, 41.419, 30.083, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-31', 'Yas Marina', 2, 26.438, 41.405, 30.093, 'Soft');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2025-08-31', 'Yas Marina', 3, 27.219, 41.124, 30.088, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-08-31', 'Yas Marina', 1, 27.390, 41.211, 30.398, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-08-31', 'Yas Marina', 2, 26.060, 41.294, 30.259, 'Soft');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2025-08-31', 'Yas Marina', 3, 27.272, 41.295, 30.228, 'Soft');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-15', 'Spa', 1, 41.283, 48.313, 28.207, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-15', 'Spa', 2, 40.302, 47.097, 28.047, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-15', 'Spa', 3, 40.407, 48.107, 28.123, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-15', 'Spa', 1, 41.170, 48.193, 28.333, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-15', 'Spa', 2, 41.442, 48.170, 28.042, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-15', 'Spa', 3, 41.485, 49.336, 29.294, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-15', 'Spa', 1, 41.178, 49.183, 29.291, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-15', 'Spa', 2, 41.160, 48.021, 29.250, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-15', 'Spa', 3, 41.018, 49.216, 29.205, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-15', 'Spa', 1, 41.324, 48.340, 28.411, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-15', 'Spa', 2, 41.255, 48.391, 28.444, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-15', 'Spa', 3, 41.363, 48.378, 28.290, 'Medium');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2026-03-15', 'Spa', 1, 42.063, 49.483, 29.098, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2026-03-15', 'Spa', 2, 41.302, 49.486, 29.194, 'Hard');
INSERT INTO public.giro VALUES ('RSSGGE98B15XX6F', '2026-03-15', 'Spa', 3, 42.328, 49.390, 29.411, 'Hard');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2026-03-15', 'Spa', 1, 42.109, 49.423, 29.478, 'Hard');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2026-03-15', 'Spa', 2, 41.191, 49.288, 29.053, 'Hard');
INSERT INTO public.giro VALUES ('LBNALX96L23XX3O', '2026-03-15', 'Spa', 3, 42.211, 49.112, 29.158, 'Hard');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-29', 'Monza', 1, 27.149, 29.494, 28.044, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-29', 'Monza', 2, 26.407, 29.317, 28.126, 'Medium');
INSERT INTO public.giro VALUES ('VRSMAX97M30XX1A', '2026-03-29', 'Monza', 3, 26.032, 29.248, 27.380, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2026-03-29', 'Monza', 1, 27.239, 29.145, 28.086, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2026-03-29', 'Monza', 2, 27.041, 29.355, 28.021, 'Medium');
INSERT INTO public.giro VALUES ('PRZSRG90C29XX2B', '2026-03-29', 'Monza', 3, 27.181, 29.058, 28.163, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-29', 'Monza', 1, 27.088, 28.250, 28.308, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-29', 'Monza', 2, 27.397, 28.142, 28.184, 'Medium');
INSERT INTO public.giro VALUES ('LCRCHL97G16XX3C', '2026-03-29', 'Monza', 3, 27.059, 28.396, 28.282, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-29', 'Monza', 1, 27.496, 28.316, 28.270, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-29', 'Monza', 2, 27.422, 28.234, 28.323, 'Medium');
INSERT INTO public.giro VALUES ('HMLWLS85A07XX5E', '2026-03-29', 'Monza', 3, 27.113, 28.113, 28.038, 'Medium');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-29', 'Monza', 1, 28.034, 30.066, 29.385, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-29', 'Monza', 2, 27.335, 30.328, 29.318, 'Hard');
INSERT INTO public.giro VALUES ('NRSLND97L13XX7G', '2026-03-29', 'Monza', 3, 28.415, 30.021, 29.282, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2026-03-29', 'Monza', 1, 28.399, 30.405, 29.498, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2026-03-29', 'Monza', 2, 28.111, 30.065, 29.125, 'Hard');
INSERT INTO public.giro VALUES ('PSTOCR01A06XX8H', '2026-03-29', 'Monza', 3, 28.486, 30.182, 29.470, 'Hard');


--
-- TOC entry 3539 (class 0 OID 16540)
-- Dependencies: 224
-- Data for Name: partecipazione; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.partecipazione VALUES ('OCNEBN96A17XX1M', 'A524', '2023-05-28', 'Spielberg', 'PLOGGE69D12XX9W', 4, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'W15', '2023-05-28', 'Spielberg', 'SRRLOC72L04XX0X', 5, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2023-05-28', 'Spielberg', 'BLNERC93H28XX1Y', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2023-08-27', 'Budapest', 'MTSMRC72D14XX2Z', 1, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2023-08-27', 'Budapest', 'DBRDKR73L21XX3A', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LNSFND81H29XX9I', 'AMR24', '2023-08-27', 'Budapest', 'CRTJNT74H08XX4B', 3, NULL);
INSERT INTO public.partecipazione VALUES ('GSNPRE96L07XX2N', 'A524', '2023-08-27', 'Budapest', 'PJLXEV75D19XX5C', 4, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2023-08-27', 'Budapest', 'STNGHT76L12XX6D', 5, NULL);
INSERT INTO public.partecipazione VALUES ('LBNALX96L23XX3O', 'FW44', '2023-08-27', 'Budapest', 'TSTFRN77D30XX7E', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2023-09-03', 'Spa', 'MKSLRT78L11XX8F', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2023-09-03', 'Spa', 'WLFTTO68H12XX9G', 2, NULL);
INSERT INTO public.partecipazione VALUES ('SNZCLS94M01XX4D', 'SF-24', '2023-09-03', 'Spa', 'HRNCRN74D25XX0H', 3, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2023-09-03', 'Spa', 'SZFOTM74L23XX1I', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2023-09-03', 'Spa', 'KRKMKE82H14XX2L', 5, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'W15', '2023-09-03', 'Spa', 'VSSFRK83D19XX3M', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2024-03-02', 'Suzuka', 'NWYADR69C26XX1C', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2024-03-02', 'Suzuka', 'LLSJMS72H09XX2D', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-03-02', 'Suzuka', 'CRDNRC73B28XX3E', 3, NULL);
INSERT INTO public.partecipazione VALUES ('SNZCLS94M01XX4D', 'SF-24', '2024-03-02', 'Suzuka', 'GRNNDW80H12XX4F', 4, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-03-02', 'Suzuka', 'FRYPTC78D22XX5G', 5, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-03-02', 'Suzuka', 'RBSDVE82L30XX6H', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2024-03-09', 'Shanghai', 'LNNLSN79D14XX8L', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2024-03-09', 'Shanghai', 'RSTSME74H20XX9M', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-03-09', 'Shanghai', 'PRDPTR80L08XX0N', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-03-09', 'Shanghai', 'OTLNEL77L22XX1O', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-03-09', 'Shanghai', 'TNDDGO85H30XX2P', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2024-03-09', 'Shanghai', 'FLLDAN88D19XX3Q', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2024-03-24', 'Barcelona', 'DMSFNX91D20XX6T', 1, NULL);
INSERT INTO public.partecipazione VALUES ('SNZCLS94M01XX4D', 'SF-24', '2024-03-24', 'Barcelona', 'MNCJNN84H23XX7U', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-03-24', 'Barcelona', 'KMTAYO68L18XX8V', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-03-24', 'Barcelona', 'PLOGGE69D12XX9W', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-03-24', 'Barcelona', 'SRRLOC72L04XX0X', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2024-03-24', 'Barcelona', 'BLNERC93H28XX1Y', 6, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-05-26', 'Silverstone', 'MTSMRC72D14XX2Z', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-05-26', 'Silverstone', 'DBRDKR73L21XX3A', 2, NULL);
INSERT INTO public.partecipazione VALUES ('SNZCLS94M01XX4D', 'SF-24', '2024-05-26', 'Silverstone', 'CRTJNT74H08XX4B', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-05-26', 'Silverstone', 'PJLXEV75D19XX5C', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2024-05-26', 'Silverstone', 'STNGHT76L12XX6D', 5, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2024-05-26', 'Silverstone', 'TSTFRN77D30XX7E', 6, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-08-25', 'Baku', 'MKSLRT78L11XX8F', 1, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2024-08-25', 'Baku', 'WLFTTO68H12XX9G', 2, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-08-25', 'Baku', 'HRNCRN74D25XX0H', 3, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2024-08-25', 'Baku', 'SZFOTM74L23XX1I', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2024-08-25', 'Baku', 'KRKMKE82H14XX2L', 5, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-08-25', 'Baku', 'VSSFRK83D19XX3M', 6, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2024-09-01', 'Marina Bay', 'TMBNIK84L21XX4N', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2024-09-01', 'Marina Bay', 'MRSHLL85H08XX5O', 2, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2024-09-01', 'Marina Bay', 'NWYADR69C26XX1C', 3, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2024-09-01', 'Marina Bay', 'LLSJMS72H09XX2D', 4, NULL);
INSERT INTO public.partecipazione VALUES ('SNZCLS94M01XX4D', 'SF-24', '2024-09-01', 'Marina Bay', 'CRDNRC73B28XX3E', 5, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'W15', '2024-09-01', 'Marina Bay', 'GRNNDW80H12XX4F', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-03-02', 'Austin', 'RBSDVE82L30XX6H', 1, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-03-02', 'Austin', 'EGGNJDY76H18XX7I', 2, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-03-02', 'Austin', 'LNNLSN79D14XX8L', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-03-02', 'Austin', 'RSTSME74H20XX9M', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2025-03-02', 'Austin', 'PRDPTR80L08XX0N', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2025-03-02', 'Austin', 'OTLNEL77L22XX1O', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-03-09', 'Città del Messico', 'TNDDGO85H30XX2P', 1, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-03-09', 'Città del Messico', 'FLLDAN88D19XX3Q', 2, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-03-09', 'Città del Messico', 'MRBPLO64H07XX4R', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-03-09', 'Città del Messico', 'HRMMTT86L14XX5S', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2025-03-09', 'Città del Messico', 'DMSFNX91D20XX6T', 5, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2025-03-09', 'Città del Messico', 'MNCJNN84H23XX7U', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-03-23', 'Interlagos', 'KMTAYO68L18XX8V', 1, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-03-23', 'Interlagos', 'PLOGGE69D12XX9W', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-03-23', 'Interlagos', 'SRRLOC72L04XX0X', 3, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-03-23', 'Interlagos', 'BLNERC93H28XX1Y', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2025-03-23', 'Interlagos', 'MTSMRC72D14XX2Z', 5, NULL);
INSERT INTO public.partecipazione VALUES ('LNSFND81H29XX9I', 'AMR24', '2025-03-23', 'Interlagos', 'DBRDKR73L21XX3A', 6, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-05-25', 'Las Vegas', 'CRTJNT74H08XX4B', 1, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-05-25', 'Las Vegas', 'PJLXEV75D19XX5C', 2, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-05-25', 'Las Vegas', 'STNGHT76L12XX6D', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-05-25', 'Las Vegas', 'TSTFRN77D30XX7E', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2025-05-25', 'Las Vegas', 'MKSLRT78L11XX8F', 5, NULL);
INSERT INTO public.partecipazione VALUES ('STRLNC98H29XX0L', 'AMR24', '2025-05-25', 'Las Vegas', 'WLFTTO68H12XX9G', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-08-24', 'Losail', 'HRNCRN74D25XX0H', 1, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-08-24', 'Losail', 'SZFOTM74L23XX1I', 2, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2025-08-24', 'Losail', 'KRKMKE82H14XX2L', 3, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-08-24', 'Losail', 'VSSFRK83D19XX3M', 4, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-08-24', 'Losail', 'TMBNIK84L21XX4N', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2025-08-24', 'Losail', 'MRSHLL85H08XX5O', 6, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2025-08-31', 'Yas Marina', 'NWYADR69C26XX1C', 1, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2025-08-31', 'Yas Marina', 'LLSJMS72H09XX2D', 2, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2025-08-31', 'Yas Marina', 'CRDNRC73B28XX3E', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2025-08-31', 'Yas Marina', 'GRNNDW80H12XX4F', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2025-08-31', 'Yas Marina', 'FRYPTC78D22XX5G', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2025-08-31', 'Yas Marina', 'RBSDVE82L30XX6H', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-03-15', 'Spa', 'EGGNJDY76H18XX7I', 1, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-03-15', 'Spa', 'LNNLSN79D14XX8L', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-03-15', 'Spa', 'RSTSME74H20XX9M', 3, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-03-15', 'Spa', 'PRDPTR80L08XX0N', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2026-03-15', 'Spa', 'OTLNEL77L22XX1O', 5, NULL);
INSERT INTO public.partecipazione VALUES ('LBNALX96L23XX3O', 'FW46', '2026-03-15', 'Spa', 'TNDDGO85H30XX2P', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-03-29', 'Monza', 'FLLDAN88D19XX3Q', 1, NULL);
INSERT INTO public.partecipazione VALUES ('PRZSRG90C29XX2B', 'RB20', '2026-03-29', 'Monza', 'MRBPLO64H07XX4R', 2, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-03-29', 'Monza', 'HRMMTT86L14XX5S', 3, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-03-29', 'Monza', 'DMSFNX91D20XX6T', 4, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-03-29', 'Monza', 'MNCJNN84H23XX7U', 5, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2026-03-29', 'Monza', 'KMTAYO68L18XX8V', 6, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-04-12', 'Suzuka', 'PLOGGE69D12XX9W', 1, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-04-12', 'Suzuka', 'SRRLOC72L04XX0X', 2, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-04-12', 'Suzuka', 'BLNERC93H28XX1Y', 4, NULL);
INSERT INTO public.partecipazione VALUES ('ZHOGYN99D30XX8T', 'C44', '2026-04-12', 'Suzuka', 'MTSMRC72D14XX2Z', 3, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-04-12', 'Suzuka', 'DBRDKR73L21XX3A', 5, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2026-04-12', 'Suzuka', 'CRTJNT74H08XX4B', 6, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-05-24', 'Monaco', 'PJLXEV75D19XX5C', 1, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-05-24', 'Monaco', 'STNGHT76L12XX6D', 2, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-05-24', 'Monaco', 'TSTFRN77D30XX7E', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-05-24', 'Monaco', 'MKSLRT78L11XX8F', 4, NULL);
INSERT INTO public.partecipazione VALUES ('PSTOCR01A06XX8H', 'MCL38', '2026-05-24', 'Monaco', 'WLFTTO68H12XX9G', 5, NULL);
INSERT INTO public.partecipazione VALUES ('LNSFND81H29XX9I', 'AMR24', '2026-05-24', 'Monaco', 'HRNCRN74D25XX0H', 6, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-07-05', 'Silverstone', 'SZFOTM74L23XX1I', 1, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-07-05', 'Silverstone', 'KRKMKE82H14XX2L', 2, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2026-07-05', 'Silverstone', 'VSSFRK83D19XX3M', 3, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-07-05', 'Silverstone', 'TMBNIK84L21XX4N', 4, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-07-05', 'Silverstone', 'MRSHLL85H08XX5O', 5, NULL);
INSERT INTO public.partecipazione VALUES ('STRLNC98H29XX0L', 'AMR24', '2026-07-05', 'Silverstone', 'NWYADR69C26XX1C', 6, NULL);
INSERT INTO public.partecipazione VALUES ('LCRCHL97G16XX3C', 'SF-24', '2026-09-06', 'Interlagos', 'LLSJMS72H09XX2D', 1, NULL);
INSERT INTO public.partecipazione VALUES ('HMLWLS85A07XX5E', 'SF-24', '2026-09-06', 'Interlagos', 'CRDNRC73B28XX3E', 2, NULL);
INSERT INTO public.partecipazione VALUES ('VRSMAX97M30XX1A', 'RB20', '2026-09-06', 'Interlagos', 'GRNNDW80H12XX4F', 3, NULL);
INSERT INTO public.partecipazione VALUES ('NRSLND97L13XX7G', 'MCL38', '2026-09-06', 'Interlagos', 'FRYPTC78D22XX5G', 4, NULL);
INSERT INTO public.partecipazione VALUES ('RSSGGE98B15XX6F', 'W15', '2026-09-06', 'Interlagos', 'RBSDVE82L30XX6H', 5, NULL);
INSERT INTO public.partecipazione VALUES ('HLKNIC87M01XX0V', 'VF-24', '2026-09-06', 'Interlagos', 'EGGNJDY76H18XX7I', 6, NULL);


--
-- TOC entry 3535 (class 0 OID 16497)
-- Dependencies: 220
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.persona VALUES ('VRSMAX97M30XX1A', 'Max', 'Verstappen', 'Olandese');
INSERT INTO public.persona VALUES ('PRZSRG90C29XX2B', 'Sergio', 'Perez', 'Messicano');
INSERT INTO public.persona VALUES ('LCRCHL97G16XX3C', 'Charles', 'Leclerc', 'Monegasco');
INSERT INTO public.persona VALUES ('SNZCLS94M01XX4D', 'Carlos', 'Sainz', 'Spagnolo');
INSERT INTO public.persona VALUES ('HMLWLS85A07XX5E', 'Lewis', 'Hamilton', 'Britannico');
INSERT INTO public.persona VALUES ('RSSGGE98B15XX6F', 'George', 'Russell', 'Britannico');
INSERT INTO public.persona VALUES ('NRSLND97L13XX7G', 'Lando', 'Norris', 'Britannico');
INSERT INTO public.persona VALUES ('PSTOCR01A06XX8H', 'Oscar', 'Piastri', 'Australiano');
INSERT INTO public.persona VALUES ('LNSFND81H29XX9I', 'Fernando', 'Alonso', 'Spagnolo');
INSERT INTO public.persona VALUES ('STRLNC98H29XX0L', 'Lance', 'Stroll', 'Canadese');
INSERT INTO public.persona VALUES ('OCNEBN96A17XX1M', 'Esteban', 'Ocon', 'Francese');
INSERT INTO public.persona VALUES ('GSNPRE96L07XX2N', 'Pierre', 'Gasly', 'Francese');
INSERT INTO public.persona VALUES ('LBNALX96L23XX3O', 'Alexander', 'Albon', 'Thailandese');
INSERT INTO public.persona VALUES ('SRGLGN98D03XX4P', 'Logan', 'Sargeant', 'Americano');
INSERT INTO public.persona VALUES ('TSNYKI04A03XX5Q', 'Yuki', 'Tsunoda', 'Giapponese');
INSERT INTO public.persona VALUES ('RCCDNL89H01XX6R', 'Daniel', 'Ricciardo', 'Australiano');
INSERT INTO public.persona VALUES ('BTTVAL89B28XX7S', 'Valtteri', 'Bottas', 'Finlandese');
INSERT INTO public.persona VALUES ('ZHOGYN99D30XX8T', 'Guanyu', 'Zhou', 'Cinese');
INSERT INTO public.persona VALUES ('MGNKVN92L05XX9U', 'Kevin', 'Magnussen', 'Danese');
INSERT INTO public.persona VALUES ('HLKNIC87M01XX0V', 'Nico', 'Hulkenberg', 'Tedesco');
INSERT INTO public.persona VALUES ('GVNNTN93H21XX1W', 'Antonio', 'Giovinazzi', 'Italiano');
INSERT INTO public.persona VALUES ('RKKKIM79L17XX2X', 'Kimi', 'Raikkonen', 'Finlandese');
INSERT INTO public.persona VALUES ('VTLSBS87D03XX3Y', 'Sebastian', 'Vettel', 'Tedesco');
INSERT INTO public.persona VALUES ('BTNNSN80D19XX4Z', 'Jenson', 'Button', 'Britannico');
INSERT INTO public.persona VALUES ('SCHMCK99G22XX5A', 'Mick', 'Schumacher', 'Tedesco');
INSERT INTO public.persona VALUES ('NWYADR69C26XX1C', 'Adrian', 'Newey', 'Britannico');
INSERT INTO public.persona VALUES ('LLSJMS72H09XX2D', 'James', 'Allison', 'Britannico');
INSERT INTO public.persona VALUES ('CRDNRC73B28XX3E', 'Enrico', 'Cardile', 'Italiano');
INSERT INTO public.persona VALUES ('GRNNDW80H12XX4F', 'Andrew', 'Green', 'Britannico');
INSERT INTO public.persona VALUES ('FRYPTC78D22XX5G', 'Pat', 'Fry', 'Britannico');
INSERT INTO public.persona VALUES ('RBSDVE82L30XX6H', 'Dave', 'Robson', 'Britannico');
INSERT INTO public.persona VALUES ('EGGNJDY76H18XX7I', 'Jody', 'Egginton', 'Britannico');
INSERT INTO public.persona VALUES ('LNNLSN79D14XX8L', 'Alessandro', 'Alunni Bravi', 'Italiano');
INSERT INTO public.persona VALUES ('RSTSME74H20XX9M', 'Simone', 'Resta', 'Italiano');
INSERT INTO public.persona VALUES ('PRDPTR80L08XX0N', 'Peter', 'Prodromou', 'Cipriota');
INSERT INTO public.persona VALUES ('OTLNEL77L22XX1O', 'Neil', 'Oatley', 'Britannico');
INSERT INTO public.persona VALUES ('TNDDGO85H30XX2P', 'Diego', 'Tondi', 'Italiano');
INSERT INTO public.persona VALUES ('FLLDAN88D19XX3Q', 'Dan', 'Fallows', 'Britannico');
INSERT INTO public.persona VALUES ('MRBPLO64H07XX4R', 'Paolo', 'Marabini', 'Italiano');
INSERT INTO public.persona VALUES ('HRMMTT86L14XX5S', 'Matt', 'Harman', 'Britannico');
INSERT INTO public.persona VALUES ('DMSFNX91D20XX6T', 'FX', 'Demaison', 'Francese');
INSERT INTO public.persona VALUES ('MNCJNN84H23XX7U', 'Jan', 'Monchaux', 'Francese');
INSERT INTO public.persona VALUES ('KMTAYO68L18XX8V', 'Ayao', 'Komatsu', 'Giapponese');
INSERT INTO public.persona VALUES ('PLOGGE69D12XX9W', 'Giorgio', 'Piola', 'Italiano');
INSERT INTO public.persona VALUES ('SRRLOC72L04XX0X', 'Loic', 'Serra', 'Francese');
INSERT INTO public.persona VALUES ('BLNERC93H28XX1Y', 'Eric', 'Blandin', 'Francese');
INSERT INTO public.persona VALUES ('MTSMRC72D14XX2Z', 'Marco', 'Matassa', 'Italiano');
INSERT INTO public.persona VALUES ('DBRDKR73L21XX3A', 'Dirk', 'De Beer', 'Sudafricano');
INSERT INTO public.persona VALUES ('CRTJNT74H08XX4B', 'Jonathan', 'Carter', 'Britannico');
INSERT INTO public.persona VALUES ('PJLXEV75D19XX5C', 'Xevi', 'Pujolar', 'Spagnolo');
INSERT INTO public.persona VALUES ('STNGHT76L12XX6D', 'Guenther', 'Steiner', 'Italiano');
INSERT INTO public.persona VALUES ('TSTFRN77D30XX7E', 'Franz', 'Tost', 'Austriaco');
INSERT INTO public.persona VALUES ('MKSLRT78L11XX8F', 'Laurent', 'Mekies', 'Francese');
INSERT INTO public.persona VALUES ('WLFTTO68H12XX9G', 'Toto', 'Wolff', 'Austriaco');
INSERT INTO public.persona VALUES ('HRNCRN74D25XX0H', 'Christian', 'Horner', 'Britannico');
INSERT INTO public.persona VALUES ('SZFOTM74L23XX1I', 'Otmar', 'Szafnauer', 'Rumeno');
INSERT INTO public.persona VALUES ('KRKMKE82H14XX2L', 'Mike', 'Krack', 'Lussemburghese');
INSERT INTO public.persona VALUES ('VSSFRK83D19XX3M', 'Frederic', 'Vasseur', 'Francese');
INSERT INTO public.persona VALUES ('TMBNIK84L21XX4N', 'Nikolas', 'Tombazis', 'Greco');
INSERT INTO public.persona VALUES ('MRSHLL85H08XX5O', 'Rob', 'Marshall', 'Britannico');


--
-- TOC entry 3536 (class 0 OID 16502)
-- Dependencies: 221
-- Data for Name: pilota; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pilota VALUES ('VRSMAX97M30XX1A', 'Aggressivo', 180);
INSERT INTO public.pilota VALUES ('PRZSRG90C29XX2B', 'Conservativo', 260);
INSERT INTO public.pilota VALUES ('LCRCHL97G16XX3C', 'Aggressivo', 130);
INSERT INTO public.pilota VALUES ('SNZCLS94M01XX4D', 'Bilanciato', 190);
INSERT INTO public.pilota VALUES ('HMLWLS85A07XX5E', 'Bilanciato', 340);
INSERT INTO public.pilota VALUES ('RSSGGE98B15XX6F', 'Aggressivo', 110);
INSERT INTO public.pilota VALUES ('NRSLND97L13XX7G', 'Bilanciato', 110);
INSERT INTO public.pilota VALUES ('PSTOCR01A06XX8H', 'Conservativo', 40);
INSERT INTO public.pilota VALUES ('LNSFND81H29XX9I', 'Aggressivo', 380);
INSERT INTO public.pilota VALUES ('STRLNC98H29XX0L', 'Conservativo', 150);
INSERT INTO public.pilota VALUES ('OCNEBN96A17XX1M', 'Aggressivo', 140);
INSERT INTO public.pilota VALUES ('GSNPRE96L07XX2N', 'Bilanciato', 130);
INSERT INTO public.pilota VALUES ('LBNALX96L23XX3O', 'Bilanciato', 90);
INSERT INTO public.pilota VALUES ('SRGLGN98D03XX4P', 'Conservativo', 30);
INSERT INTO public.pilota VALUES ('TSNYKI04A03XX5Q', 'Aggressivo', 70);
INSERT INTO public.pilota VALUES ('RCCDNL89H01XX6R', 'Bilanciato', 240);
INSERT INTO public.pilota VALUES ('BTTVAL89B28XX7S', 'Conservativo', 230);
INSERT INTO public.pilota VALUES ('ZHOGYN99D30XX8T', 'Bilanciato', 50);
INSERT INTO public.pilota VALUES ('MGNKVN92L05XX9U', 'Aggressivo', 170);
INSERT INTO public.pilota VALUES ('HLKNIC87M01XX0V', 'Bilanciato', 210);
INSERT INTO public.pilota VALUES ('GVNNTN93H21XX1W', 'Conservativo', 62);
INSERT INTO public.pilota VALUES ('RKKKIM79L17XX2X', 'Conservativo', 350);
INSERT INTO public.pilota VALUES ('VTLSBS87D03XX3Y', 'Bilanciato', 300);
INSERT INTO public.pilota VALUES ('BTNNSN80D19XX4Z', 'Conservativo', 306);
INSERT INTO public.pilota VALUES ('SCHMCK99G22XX5A', 'Bilanciato', 44);


--
-- TOC entry 3529 (class 0 OID 16439)
-- Dependencies: 214
-- Data for Name: regolamento; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.regolamento VALUES (1, 798, 795, false, '2022-12-01');
INSERT INTO public.regolamento VALUES (2, 798, 795, false, '2023-12-01');
INSERT INTO public.regolamento VALUES (3, 798, 795, true, '2024-06-15');
INSERT INTO public.regolamento VALUES (4, 800, 796, true, '2024-12-01');
INSERT INTO public.regolamento VALUES (5, 802, 798, false, '2025-12-01');


--
-- TOC entry 3541 (class 0 OID 16587)
-- Dependencies: 226
-- Data for Name: risultato; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2023-09-03', 'Spa', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-03-20', 'Sakhir', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2022-03-20', 'Sakhir', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2022-03-20', 'Sakhir', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2022-03-20', 'Sakhir', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-03-20', 'Sakhir', NULL, 0, 'Guasto meccanico');
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2022-03-20', 'Sakhir', NULL, 0, 'Guasto meccanico');
INSERT INTO public.risultato VALUES ('GSNPRE96L07XX2N', '2022-03-27', 'Jeddah', NULL, 0, 'Incidente');
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-04-10', 'Albert Park', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2022-04-10', 'Albert Park', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2022-04-10', 'Albert Park', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2022-04-10', 'Albert Park', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-04-10', 'Albert Park', NULL, 0, 'Guasto meccanico');
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2022-04-10', 'Albert Park', NULL, 0, 'Incidente');
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-09-04', 'Zandvoort', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-09-04', 'Zandvoort', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2022-09-04', 'Zandvoort', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-09-11', 'Monza', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-09-11', 'Monza', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('OCNEBN96A17XX1M', '2022-09-11', 'Monza', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2023-03-05', 'Miami', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2023-03-05', 'Miami', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2023-03-19', 'Imola', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2023-03-19', 'Imola', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2023-03-19', 'Imola', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2023-03-19', 'Imola', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('BTTVAL89B28XX7S', '2023-03-19', 'Imola', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('ZHOGYN99D30XX8T', '2023-03-19', 'Imola', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2023-04-02', 'Montreal', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2023-04-02', 'Montreal', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('MGNKVN92L05XX9U', '2023-04-02', 'Montreal', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('HLKNIC87M01XX0V', '2023-04-02', 'Montreal', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('LNSFND81H29XX9I', '2023-05-28', 'Spielberg', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('STRLNC98H29XX0L', '2023-05-28', 'Spielberg', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2023-05-28', 'Spielberg', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2023-05-28', 'Spielberg', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2023-08-27', 'Budapest', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2023-08-27', 'Budapest', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('LNSFND81H29XX9I', '2023-08-27', 'Budapest', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('GSNPRE96L07XX2N', '2023-08-27', 'Budapest', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2023-08-27', 'Budapest', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LBNALX96L23XX3O', '2023-08-27', 'Budapest', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2023-09-03', 'Spa', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2023-09-03', 'Spa', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2024-03-02', 'Suzuka', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2024-03-02', 'Suzuka', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2024-03-02', 'Suzuka', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2024-03-09', 'Shanghai', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2024-03-09', 'Shanghai', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LNSFND81H29XX9I', '2024-03-09', 'Shanghai', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2024-03-24', 'Barcelona', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2024-09-01', 'Marina Bay', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2024-09-01', 'Marina Bay', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2024-09-01', 'Marina Bay', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-03-02', 'Austin', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-03-02', 'Austin', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-03-09', 'Città del Messico', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-03-09', 'Città del Messico', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-03-23', 'Interlagos', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-03-23', 'Interlagos', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-03-23', 'Interlagos', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-03-23', 'Interlagos', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-03-23', 'Interlagos', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2025-03-23', 'Interlagos', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-05-25', 'Las Vegas', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-05-25', 'Las Vegas', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-05-25', 'Las Vegas', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-08-24', 'Losail', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-08-24', 'Losail', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2025-08-31', 'Yas Marina', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-08-31', 'Yas Marina', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-08-31', 'Yas Marina', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-08-31', 'Yas Marina', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2026-03-15', 'Spa', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2026-03-15', 'Spa', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('LBNALX96L23XX3O', '2026-03-15', 'Spa', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2026-03-29', 'Monza', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2026-03-29', 'Monza', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2026-03-29', 'Monza', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-03-27', 'Jeddah', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-03-27', 'Jeddah', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2022-03-27', 'Jeddah', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2022-03-27', 'Jeddah', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('OCNEBN96A17XX1M', '2022-03-27', 'Jeddah', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2022-05-29', 'Monaco', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2022-05-29', 'Monaco', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2022-05-29', 'Monaco', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2022-05-29', 'Monaco', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('LNSFND81H29XX9I', '2022-05-29', 'Monaco', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('STRLNC98H29XX0L', '2022-05-29', 'Monaco', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2022-09-04', 'Zandvoort', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LNSFND81H29XX9I', '2022-09-04', 'Zandvoort', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('STRLNC98H29XX0L', '2022-09-04', 'Zandvoort', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('GSNPRE96L07XX2N', '2022-09-11', 'Monza', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LBNALX96L23XX3O', '2022-09-11', 'Monza', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('SRGLGN98D03XX4P', '2022-09-11', 'Monza', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2023-03-05', 'Miami', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2023-03-05', 'Miami', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('RCCDNL89H01XX6R', '2023-03-05', 'Miami', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('TSNYKI04A03XX5Q', '2023-03-05', 'Miami', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RKKKIM79L17XX2X', '2023-04-02', 'Montreal', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('GVNNTN93H21XX1W', '2023-04-02', 'Montreal', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2023-05-28', 'Spielberg', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('OCNEBN96A17XX1M', '2023-05-28', 'Spielberg', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2023-09-03', 'Spa', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2023-09-03', 'Spa', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2023-09-03', 'Spa', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-03-02', 'Suzuka', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('SNZCLS94M01XX4D', '2024-03-02', 'Suzuka', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2024-03-02', 'Suzuka', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2024-03-09', 'Shanghai', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2024-03-09', 'Shanghai', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-03-09', 'Shanghai', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2024-03-24', 'Barcelona', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-03-24', 'Barcelona', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2024-03-24', 'Barcelona', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2024-03-24', 'Barcelona', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2024-03-24', 'Barcelona', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2024-05-26', 'Silverstone', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-05-26', 'Silverstone', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2024-05-26', 'Silverstone', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2024-05-26', 'Silverstone', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2024-05-26', 'Silverstone', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2024-05-26', 'Silverstone', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2024-08-25', 'Baku', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2024-08-25', 'Baku', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-08-25', 'Baku', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('VRSMAX97M30XX1A', '2024-08-25', 'Baku', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2024-08-25', 'Baku', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2024-08-25', 'Baku', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2024-09-01', 'Marina Bay', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2024-09-01', 'Marina Bay', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2024-09-01', 'Marina Bay', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-03-02', 'Austin', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-03-02', 'Austin', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2025-03-02', 'Austin', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-03-02', 'Austin', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-03-09', 'Città del Messico', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-03-09', 'Città del Messico', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-03-09', 'Città del Messico', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2025-03-09', 'Città del Messico', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-05-25', 'Las Vegas', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-05-25', 'Las Vegas', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2025-05-25', 'Las Vegas', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2025-08-24', 'Losail', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2025-08-24', 'Losail', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2025-08-24', 'Losail', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2025-08-24', 'Losail', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('PSTOCR01A06XX8H', '2025-08-31', 'Yas Marina', 5, 10, NULL);
INSERT INTO public.risultato VALUES ('RSSGGE98B15XX6F', '2025-08-31', 'Yas Marina', 6, 8, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2026-03-15', 'Spa', 2, 18, NULL);
INSERT INTO public.risultato VALUES ('NRSLND97L13XX7G', '2026-03-15', 'Spa', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2026-03-15', 'Spa', 4, 12, NULL);
INSERT INTO public.risultato VALUES ('LCRCHL97G16XX3C', '2026-03-29', 'Monza', 1, 25, NULL);
INSERT INTO public.risultato VALUES ('HMLWLS85A07XX5E', '2026-03-29', 'Monza', 3, 15, NULL);
INSERT INTO public.risultato VALUES ('PRZSRG90C29XX2B', '2026-03-29', 'Monza', 4, 12, NULL);


--
-- TOC entry 3533 (class 0 OID 16481)
-- Dependencies: 218
-- Data for Name: scuderia; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.scuderia VALUES ('Ferrari', 'Maranello');
INSERT INTO public.scuderia VALUES ('McLaren', 'Woking');
INSERT INTO public.scuderia VALUES ('Red Bull', 'Milton Keynes');
INSERT INTO public.scuderia VALUES ('Mercedes', 'Brackley');
INSERT INTO public.scuderia VALUES ('Aston Martin', 'Silverstone');
INSERT INTO public.scuderia VALUES ('Alpine', 'Enstone');
INSERT INTO public.scuderia VALUES ('Haas', 'Kannapolis');
INSERT INTO public.scuderia VALUES ('Williams', 'Grove');
INSERT INTO public.scuderia VALUES ('RB', 'Faenza');
INSERT INTO public.scuderia VALUES ('Sauber', 'Hinwil');


--
-- TOC entry 3537 (class 0 OID 16513)
-- Dependencies: 222
-- Data for Name: tecnico; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.tecnico VALUES ('NWYADR69C26XX1C', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('LLSJMS72H09XX2D', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('CRDNRC73B28XX3E', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('GRNNDW80H12XX4F', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('FRYPTC78D22XX5G', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('RBSDVE82L30XX6H', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('EGGNJDY76H18XX7I', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('LNNLSN79D14XX8L', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('RSTSME74H20XX9M', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('PRDPTR80L08XX0N', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('OTLNEL77L22XX1O', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('TNDDGO85H30XX2P', 'Aerodinamica');
INSERT INTO public.tecnico VALUES ('FLLDAN88D19XX3Q', 'Motore');
INSERT INTO public.tecnico VALUES ('MRBPLO64H07XX4R', 'Motore');
INSERT INTO public.tecnico VALUES ('HRMMTT86L14XX5S', 'Motore');
INSERT INTO public.tecnico VALUES ('DMSFNX91D20XX6T', 'Motore');
INSERT INTO public.tecnico VALUES ('MNCJNN84H23XX7U', 'Motore');
INSERT INTO public.tecnico VALUES ('KMTAYO68L18XX8V', 'Motore');
INSERT INTO public.tecnico VALUES ('PLOGGE69D12XX9W', 'Motore');
INSERT INTO public.tecnico VALUES ('SRRLOC72L04XX0X', 'Motore');
INSERT INTO public.tecnico VALUES ('BLNERC93H28XX1Y', 'Motore');
INSERT INTO public.tecnico VALUES ('MTSMRC72D14XX2Z', 'Motore');
INSERT INTO public.tecnico VALUES ('DBRDKR73L21XX3A', 'Motore');
INSERT INTO public.tecnico VALUES ('CRTJNT74H08XX4B', 'Motore');
INSERT INTO public.tecnico VALUES ('PJLXEV75D19XX5C', 'Gomme');
INSERT INTO public.tecnico VALUES ('STNGHT76L12XX6D', 'Gomme');
INSERT INTO public.tecnico VALUES ('TSTFRN77D30XX7E', 'Gomme');
INSERT INTO public.tecnico VALUES ('MKSLRT78L11XX8F', 'Gomme');
INSERT INTO public.tecnico VALUES ('WLFTTO68H12XX9G', 'Gomme');
INSERT INTO public.tecnico VALUES ('HRNCRN74D25XX0H', 'Gomme');
INSERT INTO public.tecnico VALUES ('SZFOTM74L23XX1I', 'Gomme');
INSERT INTO public.tecnico VALUES ('KRKMKE82H14XX2L', 'Gomme');
INSERT INTO public.tecnico VALUES ('VSSFRK83D19XX3M', 'Gomme');
INSERT INTO public.tecnico VALUES ('TMBNIK84L21XX4N', 'Gomme');
INSERT INTO public.tecnico VALUES ('MRSHLL85H08XX5O', 'Gomme');


--
-- TOC entry 3534 (class 0 OID 16486)
-- Dependencies: 219
-- Data for Name: vettura; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vettura VALUES ('SF-24', 798, 9.8, 345, 'Ferrari');
INSERT INTO public.vettura VALUES ('F1-75', 798, 9.6, 340, 'Ferrari');
INSERT INTO public.vettura VALUES ('SF70H', 728, 9.4, 350, 'Ferrari');
INSERT INTO public.vettura VALUES ('F2004', 605, 9.9, 360, 'Ferrari');
INSERT INTO public.vettura VALUES ('MCL38', 798, 9.7, 344, 'McLaren');
INSERT INTO public.vettura VALUES ('MCL35M', 752, 9.5, 352, 'McLaren');
INSERT INTO public.vettura VALUES ('MP4-30', 702, 8.9, 335, 'McLaren');
INSERT INTO public.vettura VALUES ('MP4-23', 605, 9.8, 355, 'McLaren');
INSERT INTO public.vettura VALUES ('RB20', 798, 9.9, 348, 'Red Bull');
INSERT INTO public.vettura VALUES ('RB18', 798, 9.8, 346, 'Red Bull');
INSERT INTO public.vettura VALUES ('RB15', 743, 9.5, 342, 'Red Bull');
INSERT INTO public.vettura VALUES ('RB9', 642, 9.7, 340, 'Red Bull');
INSERT INTO public.vettura VALUES ('W15', 798, 9.7, 343, 'Mercedes');
INSERT INTO public.vettura VALUES ('W12', 752, 9.9, 353, 'Mercedes');
INSERT INTO public.vettura VALUES ('W08', 728, 9.6, 351, 'Mercedes');
INSERT INTO public.vettura VALUES ('W05', 691, 9.4, 340, 'Mercedes');
INSERT INTO public.vettura VALUES ('AMR24', 798, 9.6, 342, 'Aston Martin');
INSERT INTO public.vettura VALUES ('AMR22', 798, 9.4, 338, 'Aston Martin');
INSERT INTO public.vettura VALUES ('AMR21', 752, 9.3, 345, 'Aston Martin');
INSERT INTO public.vettura VALUES ('RP19', 743, 9.2, 340, 'Aston Martin');
INSERT INTO public.vettura VALUES ('A524', 798, 9.4, 341, 'Alpine');
INSERT INTO public.vettura VALUES ('A521', 752, 9.4, 347, 'Alpine');
INSERT INTO public.vettura VALUES ('R.S.17', 728, 9.1, 339, 'Alpine');
INSERT INTO public.vettura VALUES ('VF-24', 798, 9.5, 343, 'Haas');
INSERT INTO public.vettura VALUES ('VF-22', 798, 9.3, 339, 'Haas');
INSERT INTO public.vettura VALUES ('VF-20', 746, 9.1, 341, 'Haas');
INSERT INTO public.vettura VALUES ('VF-16', 702, 9, 338, 'Haas');
INSERT INTO public.vettura VALUES ('FW46', 798, 9.5, 345, 'Williams');
INSERT INTO public.vettura VALUES ('FW44', 798, 9.2, 344, 'Williams');
INSERT INTO public.vettura VALUES ('FW41', 733, 9, 346, 'Williams');
INSERT INTO public.vettura VALUES ('FW36', 691, 9.3, 350, 'Williams');
INSERT INTO public.vettura VALUES ('VCARB01', 798, 9.6, 342, 'RB');
INSERT INTO public.vettura VALUES ('AT03', 798, 9.4, 340, 'RB');
INSERT INTO public.vettura VALUES ('AT01', 746, 9.3, 343, 'RB');
INSERT INTO public.vettura VALUES ('STR14', 743, 9.2, 341, 'RB');
INSERT INTO public.vettura VALUES ('C44', 798, 9.4, 340, 'Sauber');
INSERT INTO public.vettura VALUES ('C42', 798, 9.3, 338, 'Sauber');
INSERT INTO public.vettura VALUES ('C39', 746, 9.1, 342, 'Sauber');
INSERT INTO public.vettura VALUES ('C32', 642, 9.4, 341, 'Sauber');


--
-- TOC entry 3346 (class 2606 OID 16453)
-- Name: campionato campionato_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campionato
    ADD CONSTRAINT campionato_pkey PRIMARY KEY (nome, anno);


--
-- TOC entry 3348 (class 2606 OID 16465)
-- Name: circuito circuito_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circuito
    ADD CONSTRAINT circuito_pkey PRIMARY KEY (nome);


--
-- TOC entry 3362 (class 2606 OID 16529)
-- Name: contratto contratto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contratto
    ADD CONSTRAINT contratto_pkey PRIMARY KEY (persona, scuderia, annoinizio);


--
-- TOC entry 3350 (class 2606 OID 16470)
-- Name: gara gara_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gara
    ADD CONSTRAINT gara_pkey PRIMARY KEY (data, circuito);


--
-- TOC entry 3368 (class 2606 OID 16576)
-- Name: giro giro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.giro
    ADD CONSTRAINT giro_pkey PRIMARY KEY (pilota, garadata, garacircuito, ngiro);


--
-- TOC entry 3364 (class 2606 OID 16545)
-- Name: partecipazione partecipazione_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_pkey PRIMARY KEY (pilota, vettura, garacircuito, garadata);


--
-- TOC entry 3366 (class 2606 OID 16547)
-- Name: partecipazione partecipazione_pospartenza_garacircuito_garadata_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_pospartenza_garacircuito_garadata_key UNIQUE (pospartenza, garacircuito, garadata);


--
-- TOC entry 3356 (class 2606 OID 16501)
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (cf);


--
-- TOC entry 3358 (class 2606 OID 16507)
-- Name: pilota pilota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pilota
    ADD CONSTRAINT pilota_pkey PRIMARY KEY (persona);


--
-- TOC entry 3344 (class 2606 OID 16445)
-- Name: regolamento regolamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regolamento
    ADD CONSTRAINT regolamento_pkey PRIMARY KEY (versione);


--
-- TOC entry 3370 (class 2606 OID 16593)
-- Name: risultato risultato_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risultato
    ADD CONSTRAINT risultato_pkey PRIMARY KEY (pilota, garadata, garacircuito);


--
-- TOC entry 3352 (class 2606 OID 16485)
-- Name: scuderia scuderia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scuderia
    ADD CONSTRAINT scuderia_pkey PRIMARY KEY (nome);


--
-- TOC entry 3360 (class 2606 OID 16517)
-- Name: tecnico tecnico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tecnico
    ADD CONSTRAINT tecnico_pkey PRIMARY KEY (persona);


--
-- TOC entry 3354 (class 2606 OID 16491)
-- Name: vettura vettura_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vettura
    ADD CONSTRAINT vettura_pkey PRIMARY KEY (modello);


--
-- TOC entry 3371 (class 2606 OID 16454)
-- Name: campionato campionato_regolamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campionato
    ADD CONSTRAINT campionato_regolamento_fkey FOREIGN KEY (regolamento) REFERENCES public.regolamento(versione) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3377 (class 2606 OID 16530)
-- Name: contratto contratto_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contratto
    ADD CONSTRAINT contratto_persona_fkey FOREIGN KEY (persona) REFERENCES public.persona(cf) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3378 (class 2606 OID 16535)
-- Name: contratto contratto_scuderia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contratto
    ADD CONSTRAINT contratto_scuderia_fkey FOREIGN KEY (scuderia) REFERENCES public.scuderia(nome) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3372 (class 2606 OID 16471)
-- Name: gara gara_campionatonome_campionatoanno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gara
    ADD CONSTRAINT gara_campionatonome_campionatoanno_fkey FOREIGN KEY (campionatonome, campionatoanno) REFERENCES public.campionato(nome, anno) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3373 (class 2606 OID 16476)
-- Name: gara gara_circuito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gara
    ADD CONSTRAINT gara_circuito_fkey FOREIGN KEY (circuito) REFERENCES public.circuito(nome) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3383 (class 2606 OID 16582)
-- Name: giro giro_garadata_garacircuito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.giro
    ADD CONSTRAINT giro_garadata_garacircuito_fkey FOREIGN KEY (garadata, garacircuito) REFERENCES public.gara(data, circuito) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3384 (class 2606 OID 16577)
-- Name: giro giro_pilota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.giro
    ADD CONSTRAINT giro_pilota_fkey FOREIGN KEY (pilota) REFERENCES public.pilota(persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3379 (class 2606 OID 16558)
-- Name: partecipazione partecipazione_garadata_garacircuito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_garadata_garacircuito_fkey FOREIGN KEY (garadata, garacircuito) REFERENCES public.gara(data, circuito) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3380 (class 2606 OID 16548)
-- Name: partecipazione partecipazione_pilota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_pilota_fkey FOREIGN KEY (pilota) REFERENCES public.pilota(persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3381 (class 2606 OID 16563)
-- Name: partecipazione partecipazione_tecnico_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_tecnico_fkey FOREIGN KEY (tecnico) REFERENCES public.tecnico(persona) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3382 (class 2606 OID 16553)
-- Name: partecipazione partecipazione_vettura_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partecipazione
    ADD CONSTRAINT partecipazione_vettura_fkey FOREIGN KEY (vettura) REFERENCES public.vettura(modello) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3375 (class 2606 OID 16508)
-- Name: pilota pilota_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pilota
    ADD CONSTRAINT pilota_persona_fkey FOREIGN KEY (persona) REFERENCES public.persona(cf) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3385 (class 2606 OID 16599)
-- Name: risultato risultato_garadata_garacircuito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risultato
    ADD CONSTRAINT risultato_garadata_garacircuito_fkey FOREIGN KEY (garadata, garacircuito) REFERENCES public.gara(data, circuito) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3386 (class 2606 OID 16594)
-- Name: risultato risultato_pilota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.risultato
    ADD CONSTRAINT risultato_pilota_fkey FOREIGN KEY (pilota) REFERENCES public.pilota(persona) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3376 (class 2606 OID 16518)
-- Name: tecnico tecnico_persona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tecnico
    ADD CONSTRAINT tecnico_persona_fkey FOREIGN KEY (persona) REFERENCES public.persona(cf) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3374 (class 2606 OID 16492)
-- Name: vettura vettura_scuderia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vettura
    ADD CONSTRAINT vettura_scuderia_fkey FOREIGN KEY (scuderia) REFERENCES public.scuderia(nome) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2026-05-29 22:08:06 CEST

--
-- PostgreSQL database dump complete
--

