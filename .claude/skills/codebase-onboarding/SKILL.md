---
name: codebase-onboarding
description: Eine (neue/unbekannte) Codebase im G2-Kontext schnell verstehen — Architektur-Map, Einstiegspunkte, Module, Konventionen. Nutze diesen Skill beim ersten Einstieg ins Code-Repo oder vor Arbeit an einem fremden Modul.
origin: ECC (codebase-onboarding), neu geschrieben für G2 — Use-Case
---

# codebase-onboarding — sich im Code zurechtfinden (G2)

Du verschaffst der Person einen schnellen, korrekten Überblick über die Codebase. Antworte auf
**Deutsch**. Ziel: Orientierung, bevor gearbeitet wird — nicht raten.

## Wann aktivieren
Erster Einstieg ins Code-Repo `Alarmsystem-Dev` oder vor Arbeit an einem unbekannten Modul.

## Ablauf
1. **Struktur lesen:** README + `Backend-Konzept.md` (Module, Datenmodell, Tech-Stack).
2. **Module-Map:** `ingest` (Eingang/Validierung) · `model` (Schemas) · `assessment` (Bewertung,
   Kernmodul) · `storage` (DB) · `api` (Serving) · `config` (Schwellen) · `forecast` (Prognose).
3. **Einstiegspunkte:** `main.py` (FastAPI), Routen, Datenfluss (POST /readings → Validierung →
   Persistenz → Bewertung → Alarm → API).
4. **Konventionen:** Projekt-`CLAUDE.md`, Namens-/Ordnerregeln, DoD.
5. **Anforderungen:** `Usecase-quick.md` (FA/NF/RB/K), `Schwellenwerte.md`.

## Leitplanken
- Fakten aus den Dateien, nicht aus dem Gedächtnis. Bei Lücken nachfragen, nicht raten.

## Nicht tun
- Ohne Überblick an fremden Modulen arbeiten. Architektur „annehmen".

---
*Task-Einstieg: `feature-dev`. Doku: `documentation-lookup`. Fakten: `Alarmsystem-Dev`.*
