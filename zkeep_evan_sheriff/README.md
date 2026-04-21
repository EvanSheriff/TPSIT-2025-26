# ZKeep

**Sviluppatore:** Evan Sheriff
 
---

## Descrizione

ZKeep è un'applicazione Flutter ispirata a Google Keep. Permette di creare più note, ognuna delle quali contiene una lista di promemoria (todo). Le note sono visualizzate in una griglia di card colorate nella schermata principale; toccando una card si accede al dettaglio della nota dove è possibile gestire i promemoria. I dati vengono salvati localmente tramite un database SQLite.
 
---

## Scelte di sviluppo

- **Due tabelle nel database (`notes` e `todos`)** — le note e i todo sono entità distinte legate da una relazione uno-a-molti. La tabella `todos` ha una chiave esterna `note_id` che referenzia `notes(id)`.

- **`ON DELETE CASCADE` sulla chiave esterna** — eliminando una nota, tutti i suoi todo vengono eliminati automaticamente dal database, senza dover gestire la cosa manualmente nel codice.

- **Colore salvato come intero ARGB** — il colore di ogni nota viene salvato nel DB come un intero (es. `0xFFFFFF99`). È la rappresentazione nativa di Flutter per i colori, quindi non serve nessuna conversione aggiuntiva.

- **Anteprima limitata a 3 todo per card** — nelle card della griglia vengono mostrati al massimo 3 todo. Se ce ne sono di più, viene indicato il numero di quelli non visualizzati (es. "+ altri 4"). Questo evita che le card abbiano altezze irregolari e mantiene la griglia ordinata.

- **Navigazione con `Navigator.push`** — il dettaglio della nota si apre come una nuova schermata. Al ritorno, la home ricarica i dati dal database per riflettere eventuali modifiche ai todo.

- **Stato locale con `setState`** — la gestione dello stato è locale a ogni schermata tramite `setState`. Non è stato utilizzato `Provider` (presente nel `pubspec.yaml`) perché le due schermate sono indipendenti e non necessitano di uno stato condiviso.

- **Struttura del codice in 4 file** — il codice è diviso in `model.dart` (classi dati), `helper.dart` (accesso al DB), `widgets.dart` (componenti UI riutilizzabili) e `main.dart` (schermate e logica). Questa separazione rende il codice più leggibile e manutenibile.
