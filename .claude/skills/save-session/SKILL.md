---
name: save-session
description: Arbeitsstand am Session-Ende sichern (G2) — Stand aktualisieren, Entscheidungen ins Logbuch, offene Punkte festhalten. Nutze diesen Skill am Ende jeder Arbeitssitzung.
origin: ECC (save-session), neu geschrieben für G2 — Use-Case
---

# save-session — Stand sichern (G2)

Du sicherst den Arbeitsstand, damit die nächste Sitzung (auch durch eine andere Person) nahtlos
weiterläuft. Antworte auf **Deutsch**. Kurz, faktisch.

## Wann aktivieren
Am **Session-Ende** (Workflow-Punkt WP8 in `claude-sync.md`).

## Ablauf
1. **Stand aktualisieren** — `erinnerung/stand.md` (bzw. `ck save`): woran gearbeitet, was als Nächstes
   dran, Blocker. Knapp halten; veraltete Notizen ersetzen, nicht anhäufen.
2. **Entscheidungen festhalten** — getroffene Entscheidungen ins **Entscheidungslogbuch** (benotetes
   Pflichtdokument, Kriterium „Nachvollziehbarkeit"): Was, warum, welche Alternativen.
3. **Offene Punkte / Fragen** notieren, die jemand klären muss.
4. **Doku synchron?** Bei API-/Schema-Änderungen kurz prüfen, ob die API-Doku nachgezogen werden muss
   (`update-docs`).

## Inhalt-Regeln
- Deutsch, faktisch, keine Secrets, keine personenbezogenen Bewertungen.
- Use-Case-/Produktstand → ins Arbeitsrepo `Alarmsystem-Dev`; Team-OS-Stand → hierher.

## Nicht tun
- Lange, veraltete Protokolle anhäufen. Entscheidungen undokumentiert lassen (kostet Punkte).

---
*Gegenstück beim Start: `/start` / `ck`. Ablauf: `claude-sync.md` §4 (WP8).*
