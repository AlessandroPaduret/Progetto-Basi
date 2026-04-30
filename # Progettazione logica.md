# Progettazione logica

# se si vuole si puo legare con una (1,N) anche infrazione e intervento

> da ristrutturare
> 

gli attributi possono avere dei simboli e rappresentano:

1. ° = descrizione aggiuntiva dell’attributo
2. * =il valore ammette valore nullo
3. ‘ = sulle entita va a identificare le relazione n,n che diventano entita

- Veicolo [padre] (**id_veicolo**, modello, targa°, brand, tipo_veicolo, anno produzione)
    1. la targa non è chiave solo perche le Auto_Gara, (monoposto in F1) non hanno una targa civile e quindi risulterebbe con una **primary key** con valore **NULL**
- Auto_Gara [figlio] (squadra)
    - Auto_Gara.squadra → Scuderia.Nome
    1. se si vuole si puo avere qua l’ultimo rilevamento di ogni auto
- Mezzo_Soccorso[figlio] (categoria°, attrezzatura_medica, is_impegnato°)
    1. categoria = (ambulanza, medical car, safety car, antincendio)
    2. is_impegnato = esiste solo come attributo ridondante
- Componente (**Numero_Seriale**, Tipo, Stato_Usura, Veicolo)
    - Componente.Veicolo → Auto_Gara.id_veicolo
- Scuderia (**nome**, sede)
- Box (**id_box**, squadra, grandezza)
    - Box.squadra →Scuderia.Nome
- Pilota (**CF**, Nome, Cognome, Nazionalita, Squadra)
    - Pilota.Squadra = Scuderia.Nome
- Licenza (**Codice**, Pilota, data_scadenza)
    - Licenza.Pilota → Pilota.CF
- Sessione(**Id_Sessione**, Stato°, Nome, Tipo°, Data, Ora_Inizio)
    1. Stato = da fare il check (Bozza[non abbastanza steward], Approvata[n steward ok], Conclusa)
        a. La gara non si puo concludere se ci sono valutazioni ancora indefinite
    2. Tipo = Il tipo di gara (Qualifica Gara, FP1)
- Rilevamento (**Id_Rilevamento**, Tempo, Sessione, Settore°)
    1. Settore (es. Traguardo, Settore 1, Settore , Speed Trap)
    - Rilevamento.Sessione → Sessione.Id_Sessione)
- Infrazione (**Id_Infraz**, Tipo_Violazione, Time_Stamp, Sessione, Pilota)
    - Infrazione.Sessione → Sessione.Id_Sessione
    - Infrazione.Pilota → Pilota.CF
    1. Le infrazioni non si possono piu inserire una volta che una gara è conclusa
- Steward (**Id_Steward**, Nome, Cognome, Qualifica)
- Valuta’ (**Steward, Infrazione**, Voto_Espresso°*)
    1. Voto_Espresso = puo assumere valori (Approvato, Respinto, Null se non è ancora stato deciso)
    - Valuta.Steward → Steward.Id_Steward
    - Valuta.Infrazione → Infrazione.Id_Infraz
- Composizione’ (**Steward, Sessione**, Ruolo°)
    1. Il ruolo puo essere un membro o il presidente
        a. Il presidente rompe le patte nelle votazioni
- Partecipa’ (**Sessione, Pilota**, Posizione_Arrivo*)
    - Partecipa.Sessione → Sessione.Id_Sessione
    - Partecipa.Pilota → Pilota.CF
    1. Se si vuole si puo mettere qua l’attributo ridondante n_giri che viene aggiornato ogni volta che si fa un giro
        a. caso di DQ non basta la posizione di arrivo ma devo andare a vedere chi a fatto piu giri tra quelli sualificati e ordinarli per quelli
- Marshal (**Id_Marshal**, Nome, Cognome, Postazione_Predefinita)
- Dislocazione’ (**Veicolo, Sessione**, Punto_Mappa°)
    - questa entita è solo per dire chi è presente alla sessione
        - se si vuole si puo fare un trigger per far si che la gara non posso essere “Approved” finche non ci sono n veicoli o determinati tipi di veicoli
    1. Punto mappa (es. Curva 4)
    - Dislocazione.Sessione → Sessione.Id_Sessione
    - Dislocazione.Veicolo → Mezzo_Soccorso.Id_Veicolo
- Intervento’ ( **Veicolo, Sessione, Ora_Inizio**, Ora_FIne*, Motivo_Intervento)
    - Intervento.Veicolo → Mezzo_Soccorso.Id_Veicolo
    - Intervento.Sessione → Sessione_Id_Sessione