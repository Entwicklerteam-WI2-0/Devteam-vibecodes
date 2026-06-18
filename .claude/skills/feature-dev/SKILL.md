---
name: feature-dev
description: Geführter Task-Einstieg im G2-Backend — Anforderung verstehen, richtiges Modul finden, Architektur-/Contract-Fokus, bei großen Tasks planen. Nutze diesen Skill zu Beginn jeder Implementierungs-Task.
origin: ECC (feature-dev), neu geschrieben für G2 — FastAPI/SQLite + Use-Case
---

# feature-dev — sauber in eine Task starten (G2-Backend)

Du führst den Entwickler in eine neue Task. Antworte auf **Deutsch**. Die Devs sind Einsteiger:innen —
**du verschaffst Überblick und Orientierung**, bevor Code entsteht.

## Wann aktivieren
Task-Start (Workflow-Punkt WP1 in `claude-sync.md`), nachdem der Kontext geladen ist (`ck`/`/start`).

## Ablauf
1. **Anforderung verankern.** Welche **Anforderungs-ID / Phase (P#.#)** deckt diese Task ab? Ohne
   Verankerung nicht starten — Fakten aus `Alarmsystem-Dev` (`Usecase`, `Backend-Konzept`), nicht raten.
2. **Codebase verstehen.** Welches **Modul** ist betroffen (`ingest · model · assessment · storage ·
   api · config · forecast`)? Was existiert schon? Schichtgrenzen beachten.
3. **Richtigen Ort wählen.** Neue Datei/Funktion ans passende Modul — Ordner-/Namens-Convention aus
   `claude-sync.md` §5 / Backend-Konzept. Passt es nicht ins Schema → **widersprechen, nicht erzeugen**.
4. **Kritisch/groß?** Bei Contract-Arbeit, **Bewertungslogik** oder allem Sicherheitsrelevanten zuerst
   **planen** (`plan`) und Contract-first arbeiten — nie breit gegen eine nicht eingefrorene Naht.
5. **Übergabe an TDD.** Dann in die TDD-Schleife (`tdd-workflow`): Tests zuerst.

## Leitplanken
- **Contract-first**, **kein Aktor (RB-01)**, **Fail-safe** mitdenken (Details: `claude-sync.md` §7).
- Nur im **Backend-Scope** bleiben (kein Frontend/Sensorik mitkonzipieren).

## Nicht tun
- Direkt drauflos coden ohne Anforderungs-ID/Modul-Klärung.
- Use-Case-Fakten erfinden. Auf `main` arbeiten (erst Feature-Branch, siehe `tdd-workflow`/`pr`).

---
*Danach: `tdd-workflow`. Große Tasks: `plan`. Regeln & Module: `claude-sync.md`. Fakten: `Alarmsystem-Dev`.*
