# Entscheidungslog — Einheitlicher Agenten-Stack (Team-OS G2)

> **Zweck:** Nachvollziehbare Dokumentation der Toolkit-/Tooling-Entscheidungen für das Team-OS in
> diesem Repo (`Devteam-vibecodes`). **Nicht** die Produktarchitektur — die steht im
> `Alarmsystem-Dev/02-Arbeitsdokumente/Entscheidungslog-Lucas-Systemarchitektur.md` (dort gespiegelt als E-24…E-27).
> **Erstellt / letzte Bearbeitung:** 2026-06-17 · **Stand:** 2026-06-17 · **Autor:** Vöhringer, Lucas (Systemarchitekt) · **Status:** Beschlossen
> **Bezug:** `CLAUDE.md` §6/§8 · `Skill-Plan.md` · `gemeinsam/Skills.md` · `abteilung-*/Skills.md`

---

## Kontext / Problem

Das G2-Backend-Team (7 Personen, ~2. Semester) braucht einen einheitlichen, lokal laufenden
Agenten-Stack für regelkonforme Arbeit im Code-Repo `Alarmsystem-Dev`. Drei offene Entscheidungen
(`CLAUDE.md` §8) blockierten die Detailplanung: (1) einheitliches Tool, (2) Stack, (3) LLM-Lizenz/Kosten.

**Randbedingungen des Architekten:** „wrapper = model provider" (kein Mischen von Harness und
Fremdmodell, außer Spezialfälle wie OpenRouter); **kein API-Billing, nur Abos**; niemand kann zur
Zahlung gezwungen werden.

## Entscheidung

1. **Harness: Claude Code** — einheitlich für alle Rollen; gemeinsame `.claude/`-Config (Skills/Hooks) ins Repo.
2. **Fuel: Claude-Abo** (Pro = Standard, Max optional für Heavy-User). Modellstrategie:
   **Sonnet 4.6 = Default-Workhorse**, **Opus 4.8 für harte Tasks** (Multi-File, Architektur, zähes Debugging),
   **Haiku 4.5** für leichte Review-/Testarbeit.
3. **Umgebung: VS Code + integriertes Terminal + Claude Code** — eine Umgebung für alle Rollen.
4. **Sanktionierte Ausnahmen (Fallback, kein Parallelstandard):**
   - a) Teammitglieder mit *vorhandenem* ChatGPT-Plus → Codex CLI erlaubt; Enforcement via portierter `.claude/hooks/`.
   - b) Shared-Kimi-Allegretto (Lucas' Account, 2× Reserve) als Null-Kosten-Netz für die **Testerinnen** (leichter Verbrauch).
5. **Hedge:** Hooks als standalone Shell-Skripte in `.claude/hooks/` → portabel auf Codex (reine Config-Übersetzung) → Entscheidung reversibel.

## Begründung (beleg-gestützt, Stand 2026-06-17)

- **Qualität ist bei ~2.-Sem.-Niveau entscheidend:** Anfänger erkennen subtile Modellfehler nicht →
  Qualität schützt mehr als Kontingent; zahlt direkt auf die **40 %-Einzelleistung** (Verständnis/Review) ein.
  Belege (SWE-bench Verified): Opus 4.8 **88,6 %** vs. GPT-5.5 **82,6 %**; Kimi K2.7 bricht auf langen/harten
  Tasks ein (50 % @1–4 h, 33 % @>4 h). Sonnet 4.6 liegt nur ~1 Punkt hinter Opus bei Bruchteil von Kosten/Latenz → idealer Default.
- **Toolkit-Kohärenz:** Das kuratierte ECC-Toolkit (Skills/Hooks/Agents/`.claude/`) ist Claude-Code-nativ;
  die „Standards-per-Hook"-Säule (PostToolUse format/lint, PreToolUse-Block, Stop-Gate) ist hier am reifsten.
  Command-Hooks portieren auf Codex; für **Kimi Hook-Parität inzwischen belegt** (offizielle Doku
  `customization/hooks`, abgerufen 2026-06-22: `PreToolUse` blockbar, deny via stdout-JSON, Claude-kompatible
  Payload) → Fact-Forcing-Gate per `~/.kimi-code/config.toml` deployed (seit v1.6.0). Für Codex weiter kein Tool-Hook-Enforcement.
- **Kosten realistisch klein:** 3-Wochen-Projekt = 1 Abo-Monat. Eigen-Investment ≈ €20–72
  → Optimierung auf Qualität/Kohärenz statt €17-vs-€20.
- **wrapper=model + kein API:** erfüllt (alle Abos, kein Token-Billing im Normalbetrieb).

## Betrachtete Alternativen (und warum verworfen)

| Alternative | Warum verworfen |
|---|---|
| **Codex CLI + ChatGPT als Standard** | Billig-Einstieg (Go ~€8) untauglich („lightweight/limited", mit Werbung); verlässliches Codex erst ab Plus ≈ €22 inkl. DE-MwSt = **Preisparität** mit Claude Pro, aber ohne ECC-Toolkit. → nur Fallback. |
| **Kimi Code als Standard** | Bestes Kontingent/€ (Moderato ~$19/≈€17), aber Qualitätsabfall auf harten Tasks (schlecht für Lernende), keine vollständige Hook-Parität (seit v1.6.0 Fact-Forcing-Gate via `config.toml`; Phase-2-Hooks fehlen weiter), CN-Provider. → nur Fallback-Netz. |
| **Gemini Pro** | Trotz vorhandenem Zugang: schwächstes Coding, 4. Ökosystem, füllt keine Deckungslücke. |
| **API statt Abo** | Per Randbedingung ausgeschlossen („lohnt nie mehr als Abos"). |

## Konsequenzen / Risiken

- **Fragmentierung:** bis zu 2 Ausnahme-Ökosysteme (1× Codex, 1–2× Kimi). Akzeptabel als dokumentierter
  Fallback; portable Hooks erhalten die Enforcement.
- **Koordinationsrisiko Dev 4** (unzuverlässig, keine Rückmeldung) → Rollout **nicht** von ihm abhängig
  machen; Buddy/Pairing. Bleibt auf Claude Pro (generierungslastige Arbeit braucht Qualität + Hooks).
- **Kimi-Account-Sharing:** ToS prüfen (Consumer-Abos verbieten Sharing oft); 2×-Reserve trägt nur leichte Nutzer.


## Offene Punkte / Review-Trigger

- **Dev 2:** ChatGPT **Go** oder **Plus**? Go → Claude Pro empfehlen (Go-Codex zu dünn); Plus → Codex-Split ok.
- **Fable 5 / Mythos 5:** seit **12.06.2026** weltweit ausgesetzt (US-Exportkontroll-Direktive wegen
  Safety-Classifier-Jailbreak; zielte auf *foreign nationals* = dieses Team). Kein Rückkehrtermin.
  **Nicht** auf Rückkehr planen; Opus 4.8 bleibt Top-verfügbares Modell. Bei Wiederfreigabe als „Hard-Task"-Tier neu bewerten.
- **Frische:** Preise/Limits/Modellstände driften monatlich — vor Rollout Plus-EUR-Preis & Kimi-Abo-Reinheit gegenprüfen.

## Quellen

- SWE-bench Pro / Verified Leaderboards (morphllm, marc0.dev)
- Claude Code Pricing & Limits (morphllm)
- Codex Pricing (OpenAI Developers), ChatGPT-Go-EU-Verfügbarkeit (glbgpt, Search Engine Journal)
- Kimi Pricing-Tiers (kimik2ai)
- Fable-5/Mythos-5-Suspension (InfoQ 2026-06, Snyk)
