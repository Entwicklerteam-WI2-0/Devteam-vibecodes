# Seam-Sync — Fragenkatalog an G1 (Sensorik) & G3 (Frontend)

> **Zweck:** Vorbereitung des heutigen Teamleiter-/Architekten-Treffens. Klärt die **eine Naht
> (API + Datenmodell)**, die G2 verantwortet, gegen die beiden Nachbargruppen ab — so, dass unser
> Architekturplan (`Alarmsystem-Dev/02-Arbeitsdokumente/Backend-Konzept.md`,
> `Schwellenwerte.md`) **stabil und parallel** umsetzbar wird.
> **Haltung (contract-first, Team-Org §3.1):** Wir bringen den **Vertragsentwurf** mit (Datenmodell
> §4, Endpoints §2/§9) und fragen gezielt, **wo er bricht** — nicht „was wollt ihr?".
> **Prio:** 🔴 = Blocker (heute klären, sonst kann die Naht nicht eingefroren werden) · 🟡 = bald · ⚪ = nice-to-have.
> **Stand:** 2026-06-18 · Architekt G2: Vöhringer / Petzold. Source-of-Truth bleibt `Alarmsystem-Dev`.

---

## 0. Was wir ins Treffen mitbringen (damit es produktiv ist)

1. **Datenmodell-Entwurf** (`reading` / `assessment` / `alarm`, Backend-Konzept §4) als Diskussionsbasis.
2. **Endpoint-Liste** (`POST /readings`, `GET /assessment/current`, `GET /health`, … §2/§8).
3. **Ziel des Treffens:** beide Nähte so weit fixieren, dass wir das **T0-Schema heute/diese Woche
   einfrieren** und danach alle drei Gruppen **parallel** gegen denselben Vertrag bauen.
4. **Angebot an beide:** Wir stellen einen **Mock/Stub** bereit (G1 testet gegen unseren Ingest-Mock,
   G3 gegen Beispiel-Responses), damit niemand auf den fertigen Backend-Code warten muss.

**API-Konventionen, die wir als gesetzt mitbringen (contract-first — Vorschlag, kein Basar):**
**Versionspräfix `/api/v1/` auf allen Pfaden** (in den Tabellen der Kürze halber weggelassen) ·
Envelope `{data, error, meta}` · Felder `snake_case` · Zeit **UTC ISO 8601** ·
**Status-Codes semantisch**: `201` (reading angenommen) · `200` (GET) · `422` (invalide Messdaten) ·
`4xx/5xx` **immer mit Error-Envelope** `{error:{code,message,details}}` — **nie „200 + Fehlerflag"**.

---

## A. Fragen an **G1 — Sensorik** (Ingest-Naht: `POST /readings`)

Sichert ab: `reading`-Entität (Backend-Konzept §4), Eingangsgrößen & Kalibrierung (`Schwellenwerte.md §1, §3`),
Stale/Defekt-Erkennung (FA-04, NF-01).

| # | Frage (inkl. unserem Default-Vorschlag) | Sichert ab | Prio |
|---|---|---|---|
| G1-1 | **Liefert ihr echte Oberflächentemperatur `T_s`** (nicht nur Lufttemperatur)? Sie ist unsere **primäre** Entscheidungsgröße — ohne sie kollabiert die ganze 4-Stufen-Logik (genau der Fehler des Altsystems). | FA-01, Schwellenw. §0/§2 | 🔴 |
| G1-2 | **Welche Messgrößen genau** kommen pro Datensatz? Unser Soll: `surface_temp_c`, `air_temp_c`, `humidity_pct`, `pressure_hpa`, `precip_type`, `ice_indicator`. **`dew_point_c` berechnen wir selbst** (Magnus) — ihr müsst es **nicht** liefern. Welche davon fehlen real? | FA-01/02, §4, Schwellenw. §1 | 🔴 |
| G1-3 | **Niederschlagsart** — liefert ihr einen **Typ** (`kein/regen/gefrierend/schnee/graupel`) oder nur ja/nein? „**Gefrierend**" ist unser einziges direktes **ROT**-Kriterium; ohne Typ verlieren wir es. Vorschlag: Enum + separates `precip_detected:bool`. | Schwellenw. §2/§4 (ROT) | 🔴 |
| G1-4 | **Genauigkeit `T_s` um 0 °C:** Schafft ihr **±0,3 °C (Eispunkt-Kalibrierung)**? Unsere Entscheidungsgrenze liegt exakt bei 0 °C — gröbere Genauigkeit zwingt uns zu breiterer Hysterese/Unsicherheitsband. Falls nicht: welche Genauigkeit ist realistisch? | NF-04, Schwellenw. §3/§5 | 🔴 |
| G1-5 | **Transport & Richtung:** Bestätigt ihr **HTTP-POST** und dass **ihr aktiv an unsere URL pusht** (wir sind Empfänger)? T0 = HTTP, MQTT erst bei Skalierung. Ein Datensatz pro POST oder Batch? | §6, FA-09 | 🔴 |
| G1-5b | **Ingest-Fehlerverhalten & Retry:** Wie sollen wir auf **unplausible/defekte** Messdaten antworten — **annehmen + intern „defekt" markieren** (Vorschlag, fail-safe-konform) oder per **`422`** ablehnen? **Retryt** ihr bei `5xx`/Timeout? Falls ja: sollen wir über `sensor_id + ts` **deduplizieren** (Retransmits verfälschen sonst Zeitreihe/Prognose)? | FA-04, NF-01 | 🟡 |
| G1-6 | **Mess-/Sendeintervall:** Wir planen **≤ 60 s** und werten alles > **180 s (3×)** als „stale → nie GRÜN". Haltet ihr ≤ 60 s? Konstant oder schwankend? | Schwellenw. §3 (stale), NF-02 | 🔴 |
| G1-7 | **Zeitstempel:** Setzt **ihr** `ts` je Messung (Vorschlag **UTC, ISO 8601**) oder sollen **wir** `received_at` setzen? Sind eure Uhren synchron (NTP)? Falsche Zeit zerstört Stale-Erkennung und Prognose. | §4, FA-03/04 | 🔴 |
| G1-8 | **Real vs. Simulation:** Echte Hardware, simuliert oder gemischt? Setzt ihr das `source`-Feld (`real`/`sim`)? Wir brauchen das für Tests und Audit-Trail. | §4 (`source`), Testdaten | 🟡 |
| G1-9 | **Sensor-Health:** Schickt ihr einen **Status/Defekt-Flag** mit, oder erkennen **wir** Defekte rein backendseitig (Flatline / Sprung > 5 °C/min / NaN / Timeout)? Default: wir erkennen selbst — aber ein Flag von euch wäre robuster. | FA-04, Schwellenw. §3 | 🟡 |
| G1-10 | **Fehlende Werte:** Wie liefert ihr eine **nicht verfügbare** Messgröße — Feld weglassen, `null`, oder Sentinel? Vorschlag: **`null`** (kein `-999`). Davon hängt unsere Plausibilisierung ab. | FA-04 | 🟡 |
| G1-11 | **Multi-Sensor (NF-11):** Ein Sensor oder mehrere/redundant? Wie sieht euer **`sensor_id`**-Schema aus? Wir modellieren von Anfang an mehrere, müssen die ID-Konvention aber kennen. | NF-11, §4 | 🟡 |
| G1-12 | **Ingest-Auth:** Soll `POST /readings` in T0 **offen** sein (lokales Netz) oder braucht ihr schon einen **API-Key/Token**? Vorschlag: T0 offen, Auth in T3 (NF-07). | NF-07, RB | ⚪ |
| G1-13 | **Einheiten fix:** Bestätigt: Temperatur **°C**, Feuchte **% RH**, Druck **hPa**? Keine °F/Kelvin/Pa-Überraschungen. | §4, Schwellenw. §1 | ⚪ |

---

## B. Fragen an **G3 — Frontend / UI** (Serving-Naht: `GET …` + Quittierung)

Sichert ab: `assessment`/`alarm`-Entitäten (§4), Serving-Endpoints (§2/§8), Anzeige-Anforderungen
(FA-05/06/07/08, NF-08), **Fail-safe-Darstellung** (NF-01).

| # | Frage (inkl. unserem Default-Vorschlag) | Sichert ab | Prio |
|---|---|---|---|
| G3-1 | **Statusmodell-Match:** Wir liefern 4 Stufen `green/yellow/orange/red`. Passt das zu eurer Ampel? **Kritisch:** Bei Ausfall/Stale liefern wir **nicht GRÜN**, sondern einen Zustand **„unbekannt/stale"** — rendert ihr den als **eigene** Anzeige (nicht als grün/ok)? Sonst ist die Fail-safe-Kette gebrochen. | NF-01, FA-07, Schwellenw. §2 | 🔴 |
| G3-2 | **Pull oder Push:** Vorschlag **Polling** `GET /assessment/current` alle **~5–10 s** (Daten ändern sich nur ≤ 60 s). Reicht euch das, oder braucht ihr **SSE/WebSocket** für sofortige Alarme? | NF-02 (Latenz < 5 s), FA-08 | 🔴 |
| G3-3 | **Quittierung (FA-10):** Der Mensch quittiert Alarme — **Schreibzugriff vom Frontend**. Baut ihr das? Vorschlag: **`POST /alarms/{id}/acknowledgements`** (append-only, passt 1:1 zum `acknowledgement`-Entity §4 → mehrere Quittierungen/Alarm möglich; Antwort `201`) mit `operator` + `note`. Welche Felder braucht ihr? | FA-10, RB-01, §4 | 🔴 |
| G3-4 | **Response-Format:** Vorschlag **JSON**, Felder **`snake_case`**, einheitlicher Envelope `{data, error, meta}`, Zeit **UTC ISO 8601** (ihr lokalisiert). Einverstanden, oder braucht ihr `camelCase`? | FA-09, API-Design | 🔴 |
| G3-5 | **Was zeigt ihr genau an?** Wir liefern `risk_level`, `driving_factor` (auslösende Größe) und `explanation`. Wollt ihr **Klartext von uns** oder **Codes**, die ihr selbst übersetzt (Lokalisierung/Wording bei euch)? | FA-05 (Nachvollziehbarkeit) | 🟡 |
| G3-6 | **Prognose (FA-06):** Separater Endpoint **`GET /forecast`** (30-min-Trend) — braucht ihr den in T0 oder später (T3)? Und: Wollt ihr eine **Konfidenz/Unsicherheit** mit angezeigt bekommen (Prognose ist unsicherer als Ist-Wert)? | FA-06, K2 | 🟡 |
| G3-7 | **Sensor-/Datenstatus granular (FA-07):** Wollt ihr **pro Messgröße/Sensor** sehen, welcher Wert frisch/stale/defekt ist, oder reicht ein **globaler** Datenstatus? Bestimmt, wie detailliert unser Response wird. | FA-07, FA-04 | 🟡 |
| G3-8 | **Alarm-Anzeige:** Wir liefern `severity` + `state(active/acknowledged)`. NF-08 fordert **2 Sinne (optisch + akustisch)** — macht ihr den **akustischen** Teil? Braucht ihr eine **Alarm-Historie** (`GET /alarms`)? | FA-08, NF-08 | 🟡 |
| G3-9 | **Historie:** Braucht ihr `GET /readings?from=…&to=…` / `GET /assessments?…` für Verlaufsgrafiken? Bei 60-s-Takt sind das **~1.440 Punkte/Tag/Sensor** — wollt ihr **server-seitiges Downsampling** (z. B. `?interval=5m`) statt aller Rohpunkte? **Pagination** (Offset reicht für T0) + Zeitfenster/Auflösung? | FA-03/07 | 🟡 |
| G3-10 | **Schwellen-Konfig-UI (FA-11):** Baut **ihr** die Oberfläche zum Ändern der Schwellen (dann brauchen wir `GET/PUT /thresholds`), oder bleibt Config in T0 backend-/dateiseitig? | FA-11, NF-05 | 🟡 |
| G3-11 | **Deployment/Netz (AE-01):** Läuft das Frontend **lokal auf derselben Maschine** wie das Backend oder getrennt? Bestimmt **Base-URL & CORS**. Vorschlag T0: lokal, gleiche Maschine. | AE-01, NF-07 | 🟡 |
| G3-12 | **Fehlerdarstellung:** Wir nutzen **HTTP-Status + Error-Envelope**. Wie wollt ihr **„Backend nicht erreichbar"** dem Operator zeigen? (Auch das darf **nicht** wie „alles grün" aussehen.) | NF-01, NF-08 | 🟡 |

---

## C. Querschnitt / organisatorisch (Teamleiter-Ebene — betrifft beide Nähte)

| # | Frage / zu klärender Punkt | Warum | Prio |
|---|---|---|---|
| Q-1 | **Wann frieren wir das T0-Schema ein?** Ziel: heute Grundzüge fixieren, diese Woche **eingefrorener Contract**. Danach erst breite Implementierung (contract-first, Team-Org §3.1, kritischer Pfad §6). | Spätes Schema blockiert G1 **und** G3 gleichzeitig | 🔴 |
| Q-2 | **OpenAPI-Spec als Single Source of Truth** — wir (G2) pflegen sie, **beide Gruppen zeichnen gegen**. Änderungen laufen nur darüber (wir sichern den eingefrorenen Contract per Schema-Diff ab). Einverstanden? | verhindert Naht-Drift | 🔴 |
| Q-3 | **Fester Ansprechpartner („Vermittler") + ein Kanal je Gruppe** für Naht-Fragen. Wer ist es bei G1 / G3? | schnelle Klärung statt Komitee | 🔴 |
| Q-4 | **Mock/Stub-Bereitstellung:** Wir liefern beiden einen Mock (Ingest-Endpoint für G1, Beispiel-Responses für G3) → **parallel arbeiten ohne Warten**. Ab wann braucht ihr ihn? | entkoppelt die drei Teams | 🟡 |
| Q-5 | **Naht-Versionierung & Change-Kommunikation:** Wie kündigen wir Schema-Änderungen an (Changelog/Version im Spec)? | Stabilität über 3 Wochen | 🟡 |
| Q-6 | **Lokal vs. Cloud (AE-01) gemeinsam:** beeinflusst URLs/CORS/Netz beider Nähte. T0-Vorschlag: alles **lokal**. Bestätigen oder offen lassen? | offene Architekturentscheidung, betrifft alle | 🟡 |

---

## D. Unsere „roten Linien" (proaktiv mitteilen, nicht verhandelbar)

Damit die Nachbargruppen unsere Architektur-Grenzen kennen:

1. **RB-01 — kein Aktor:** Unsere API liefert **nur Bewertung/Anzeige**, **niemals** einen Freigabe-/
   Sperr-/Steuerbefehl an die Bahn. G3 baut **keinen** „Bahn freigeben"-Button gegen uns — der Mensch
   entscheidet außerhalb des Systems. (RB-01)
2. **Fail-safe (NF-01):** Bei Stale/Ausfall geht das System **nie auf GRÜN**. G1 und G3 müssen das
   mittragen (G1: Sensor-Health; G3: „unbekannt"-Darstellung).
3. **`T_s` ist Pflicht:** Ohne belastbare Oberflächentemperatur ist die Kernbewertung nicht
   abnahmefähig (beide dokumentierten Vorfälle hängen daran).

---

*Vorbereitet von G2 (Backend & Entscheidungslogik) für den Seam-Sync. Antworten gehören anschließend
ins Entscheidungslogbuch + in die API-Spezifikation (`Alarmsystem-Dev`).*
