---
name: architektur-tiefenaudit
description: Brutal tiefer, subagenten-basierter Vollstaendigkeits- und Logik-Audit des Backends — prueft, ob das fertige Endprodukt mit allen Features tatsaechlich vollstaendig, korrekt verdrahtet (Pfade/Dependencies) und logisch zielerfuellend im Code vorhanden ist. Architekt-Werkzeug, heavy/on-demand. Nutze diesen Skill vor einem Meilenstein/der Demo oder auf „/uni:architektur-tiefenaudit".
origin: G2-eigen (Systemarchitekt)
---

# architektur-tiefenaudit — Backend-Vollstaendigkeit & Prozesslogik tief pruefen (G2)

Du fuehrst einen **tiefen, mehrstufigen Audit des gesamten Backends** durch und beantwortest EINE Frage:
*„Ist fuer jedes Feature des Endprodukts alles im Code vorhanden — die Komponenten, korrekt verdrahtet
(Pfade/Dependencies), und erfuellt die interne Prozesslogik wirklich das Funktionsziel?"* Du **liest, tracest,
widerlegst und berichtest** — der Mensch (Systemarchitekt/Lucas) entscheidet und fixt. **Read-only.**
Antworte auf **Deutsch**.

## Abgrenzung (nicht verwechseln)
- `system-architektur-review` = leicht/haeufig, Code↔Doku-Sync + Doku nachziehen.
- `code-review`/`fastapi-review`/`python-review` = Qualitaet eines **Diffs**.
- `verification-loop`/`santa-loop` = adversariale Verifikation **einer konkreten Aenderung**.
- **DIESER Skill** = Gesamtprodukt: Feature → Komponenten vorhanden? → Pfade/Deps intakt? → Prozesslogik
  zielerfuellend? Tiefer und teurer als alle obigen — bewusst on-demand.

## Wann aktivieren
- Vor einem Meilenstein (M2/M3) oder der Live-Demo.
- Wenn du belastbar wissen willst, ob der T0-Slice / das Produkt wirklich durchlaeuft.
- Auf Anfrage „/uni:architektur-tiefenaudit".
- **NICHT** als Routine bei jedem Commit — viele Subagenten, kostenintensiv.

## Voraussetzung
- `uni:start` ausgefuehrt. Aktueller `main` lokal. Lesezugriff auf `04-Source-code/` + Requirements-Docs.
- Optional fuer die schwersten Laeufe: Workflow-Tool freigeschaltet (siehe „Orchestrierung").

## Ablauf

### Phase 0 — Feature-Inventar (das Soll, aus Source of Truth — nichts erfinden)
Leite die zu pruefenden Funktionen ab aus:
- **FA-01..12 / NF-01..11 / RB-01** aus `Usecase-quick.md`.
- **Contract-Endpoints** aus dem EINGEFRORENEN `docs/api/v1/openapi.yaml` / `API_FROZEN_v1.md` (`/v1/...`).
- **Bewertungs-Kaskade + beide Vorfaelle + Fail-safe** aus `Schwellenwerte.md`.
- **T0-Slice-Ziel:** Poller → Persistenz → Bewertung → `GET /v1/assessment/current`.
Ergebnis: nummerierte Liste F1..Fn, jede mit *erwarteten Komponenten* + *Funktionsziel*.

### Phase 1 — Tiefen-Trace (Fan-out, der harte Teil)
Pro Feature/Subsystem **ein Subagent, parallel**. Nutze den selten genutzten, aber starken
**`code-explorer`** (tracet Execution-Paths, mappt Schichten, dokumentiert Dependencies). Jeder Subagent prueft:
1. **Vorhandensein:** Welche Funktionen/Module/Dateien sollen das Feature erfuellen — existieren sie real?
2. **Verdrahtung:** imports, Call-Graph, Dependency-Injection, Modulgrenzen — fuehrt der Pfad wirklich von
   Eingang (Poller/Endpoint) bis Ziel (persistierte/ausgelieferte Bewertung)? Tote oder fehlende Pfade?
3. **Prozesslogik:** Erfuellt der tatsaechliche Kontrollfluss das Funktionsziel? Beispiele:
   - Erreicht ein Stale-Reading WIRKLICH den `unknown`-Pfad (nie GRUEN)?
   - Wird die Kaskade ROT→ORANGE→GELB→GRUEN in richtiger Reihenfolge, erster-Treffer-gewinnt ausgewertet?
   - Landet ein Alarm tatsaechlich am SSE-Stream `GET /v1/alarms/stream`?
Rueckgabe strukturiert: Feature | Komponenten vorhanden? | Pfad intakt? | Logik zielerfuellend? | Fund-/Lueckenstellen mit `datei:zeile`.

**Spezial-Linsen als eigene Subagenten (wo sinnvoll):**
- **`silent-failure-hunter`** auf die Fail-safe-Pfade (NF-01: bei Stale/Ausfall nie GRUEN — wirklich erzwungen oder still verschluckt?).
- **RB-01-Linse:** existiert IRGENDEIN Aktor-/Freigabe-/Sperr-Pfad? (grep auf `unlock|freigabe|sperr|execute` + Logik dahinter).
- **Contract-Treue:** bedient der Code jeden `/v1`-Endpoint wie im `openapi.yaml` (Methode, Pfad, Response-Shape, Status-Codes)?

### Phase 2 — Adversariale Gegenprobe
Fuer JEDE „vorhanden & funktioniert"-Behauptung aus Phase 1 ein **Skeptiker-Subagent**, der versucht sie zu
**widerlegen** (broken path, falsche Logik, Fail-safe-Loch, Contract-Drift). Default-Annahme: *widerlegt, bis
bewiesen*. Nur was die Gegenprobe ueberlebt, gilt als gruen.

### Phase 3 — Synthese & Verdikt (read-only, kein Code-Edit)
Report nach `erinnerung/architektur-tiefenaudit-<YYYY-MM-DD>.md`:
```markdown
## Architektur-Tiefenaudit — YYYY-MM-DD
### Vollstaendigkeits-Matrix
| Feature (F#) | Erwartete Komponenten | Vorhanden? | Pfad/Deps intakt? | Logik zielerfuellend? | Verdikt | Belege (datei:zeile) |
|---|---|---|---|---|---|---|
Verdikt-Legende: ✅ vorhanden+korrekt · ⚠️ vorhanden+kaputt · ❌ fehlt
### Pfad-/Dependency-Befunde
### Fail-safe (NF-01) & RB-01 — Integritaet
### Contract-Treue (/v1 vs. openapi.yaml)
### GESAMT-VERDIKT: Liefert das Backend das Produkt? (Ja / Teilweise / Nein) + Begruendung
### Priorisierte Luecken-Liste (was fehlt fuer ein funktionierendes Endprodukt)
```

## Orchestrierung (fuer die schwersten Laeufe)
- **Default:** parallele Agent-Fan-outs (`code-explorer` / `silent-failure-hunter`) wie oben.
- **Maximal:** das **Workflow-Tool** (deterministische Multi-Agent-Orchestrierung) — nur wenn ausdruecklich
  freigegeben (kostenintensiv). Pipeline: Feature-Liste → pro Feature `code-explorer`-Trace → adversariale
  Verify → Synthese.

## Checkliste / Outputs
- [ ] Feature-Inventar aus Source of Truth abgeleitet (nicht erfunden).
- [ ] Pro Feature ein Tiefen-Trace (Vorhandensein + Pfad + Logik) mit Belegen.
- [ ] Fail-safe-, RB-01- und Contract-Treue-Linsen gelaufen.
- [ ] Jede „gruen"-Behauptung adversarial gegengeprueft.
- [ ] Vollstaendigkeits-Matrix + Gesamt-Verdikt + priorisierte Luecken-Liste im Report.

## Befund-Schweregrade
- **CRITICAL:** Feature fehlt ganz · Fail-safe-Loch (GRUEN bei Stale moeglich) · Aktor-Pfad (RB-01-Bruch) · Contract gebrochen.
- **HIGH:** Komponente vorhanden, aber Pfad/Logik erfuellt das Funktionsziel nicht.
- **MEDIUM:** funktioniert, aber Luecke (fehlender Edge-Case/Test/Validierung).
- **LOW:** Kosmetik / Aufraeumen.

## Leitplanken
- **Read-only Audit:** keine Code-/Doc-Aenderung — nur Befunde + `datei:zeile`. Der Architekt entscheidet & fixt.
- **Evidence before assertions:** jede Aussage mit Beleg; keine Vermutung ohne Fundstelle.
- **Soll aus Source of Truth**, nicht erfunden (Requirements + eingefrorener Contract + `Schwellenwerte.md`).
- **Schwellen sind DUMMY** bis G1 — der Audit prueft Parametrierbarkeit, nicht die Zahlenwerte.
- 40 % bleibt reines Notengewicht — der Audit liefert Fakten, ersetzt keine menschliche Entscheidungsreflexion.

## Nicht tun
- Code/Docs automatisch aendern (das macht `system-architektur-review` mit Freigabe — dieser Skill prueft nur).
- „Sieht vorhanden aus" ohne Pfad-/Logik-Beweis als gruen werten.
- Den Audit als Routine bei jedem Commit fahren (zu teuer) — on-demand vor Meilenstein/Demo.
- Den eingefrorenen Contract als „Sollabweichung" umschreiben (nur melden; Aenderung braucht G1/G3-Re-Signoff).

---
*Gegenstueck: `uni:system-architektur-review` (Doku-Sync), `uni:fastapi-review`/`code-review` (Diff-Qualitaet),
`uni:verification-loop`/`santa-loop` (Aenderungs-Verifikation). Nach Anlegen: `coupling-map-sync` fuer
`Abhaengigkeiten.md`. Architekt-Werkzeug (Lucas).*
