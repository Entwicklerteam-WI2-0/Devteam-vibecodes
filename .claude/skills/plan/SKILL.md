---
name: plan
description: Vor kritischen/großen Tasks im G2-Backend zuerst planen — Anforderung in Schritte zerlegen, Risiken und betroffene Module benennen, Contract-first. Nutze diesen Skill bei Contract-Arbeit, der Bewertungslogik und allem Sicherheitsrelevanten, BEVOR Code entsteht.
origin: ECC (plan), neu geschrieben für G2 — Use-Case
---

# plan — erst denken, dann bauen (G2-Backend)

Du erstellst mit dem Entwickler einen kurzen, konkreten Plan, **bevor** Code entsteht. Antworte auf
**Deutsch**. Für Einsteiger:innen: knapp, nummeriert, nachvollziehbar — kein Roman.

## Wann aktivieren
**Kritische/große** Tasks: Contract/Naht (P1), **Vereisungs-Bewertungslogik** (P2.4), alles
Sicherheitsrelevante. Kleine Tasks brauchen keinen Plan → direkt in `tdd-workflow`.

## Ablauf
1. **Anforderung restate.** In 1–2 Sätzen: Was genau ist zu tun? Welche **Anforderungs-ID / Phase**?
   Fakten aus `Alarmsystem-Dev` (`Usecase`, `Backend-Konzept`, `Schwellenwerte.md`) — nicht raten.
2. **Schritte.** Zerlege in 3–7 konkrete, prüfbare Schritte (jeder ein klares Ergebnis).
3. **Betroffene Module.** Welche (`ingest · model · assessment · storage · api · config · forecast`)?
   Schicht-/Contract-Grenzen beachten.
4. **Risiken & Edge Cases.** Besonders: Fail-safe (Stale/Ausfall), Grenzwerte der Bewertung, RB-01.
5. **Teststrategie.** Welche Tests zuerst (RED)? Welche Pflichtfälle (Vorfall A/B, Fail-safe)?

## Leitplanken
- **Contract-first:** nie breit gegen eine nicht eingefrorene Naht planen.
- **WAIT auf Bestätigung** bei großen Plänen, bevor breit implementiert wird.

## Nicht tun
- Bei kritischen Tasks ohne Plan losbauen. Annahmen als Fakten behandeln (kennzeichnen + klären).

---
*Danach: `tdd-workflow`. API-Naht: `api-design`. Regeln: `claude-sync.md` §4 (WP2). Fakten: `Alarmsystem-Dev`.*
