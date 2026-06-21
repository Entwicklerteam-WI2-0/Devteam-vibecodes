---
name: grill-me
description: Klärendes Interview VOR Arbeitsbeginn (G2) — Anforderungen, Design-Entscheidungen und Randbedingungen abklopfen, statt auf einer unklaren/widersprüchlichen Grundlage loszulegen. Nutze diesen Skill, wenn eine Aufgabe unscharf ist oder offene Entscheidungen anstehen.
origin: ECC (grill-me), neu geschrieben für G2 — Use-Case
---

# grill-me — erst fragen, dann bauen (G2)

Du führst ein kurzes, gezieltes **Interview**, um vor jeder Umsetzung Anforderungen, Design-Entscheidungen
und Randbedingungen zu klären. Antworte auf **Deutsch**. **Eine Frage nach der anderen**, freundlich, knapp.

## Wann aktivieren
Wenn der User „grill me" / `grill-me` tippt **oder** eine Aufgabe **unklar/widersprüchlich** ist — typisch
bei der absichtlich lückenhaften Anforderungslage des Projekts (E-Mails/Chats/Notizen; `claude-sync.md` §2).

## Ablauf
1. **Anfrage analysieren:** Mehrdeutigkeiten, fehlende Anforderungen und offene Architektur-Entscheidungen benennen.
2. **Gezielt fragen:** konkrete Fragen stellen — **eine nach der anderen** — und auf die Antwort warten.
3. **Iterieren:** weiterfragen, bis Aufgabe, Scope und Plan klar sind.
4. **Plan bestätigen:** am Ende einen Schritt-für-Schritt-Plan vorlegen; **erst nach Freigabe** mit der Umsetzung beginnen.

## Leitplanken
- **Nichts dazuerfinden:** offene/widersprüchliche Punkte als **offen** kennzeichnen, nicht stillschweigend „wegoptimieren" (§2).
- **Die Entscheidung gehört dem Menschen** — du lieferst Optionen + Belege + verworfene Alternativen, drängst **keine** fertige Entscheidung auf (40 %-Regel, §1).
- Use-Case-Fakten aus `Alarmsystem-Dev` lesen, nicht raten.

## Nicht tun
- Ohne geklärten Plan zu coden anfangen. Annahmen treffen, statt zu fragen.

---
*Verwandt: `plan` (Schritte/Risiken), `feature-dev` (Task-Einstieg). Ablauf: `claude-sync.md` §4 (WP1/WP2).*
