---
name: santa-loop
description: Adversariales Dual-Review mit Konvergenz — zwei unabhängige Agenten prüfen, widerlegen sich gegenseitig und diskutieren bis sie auf demselben Nenner sind. Nutze diesen Skill für sicherheitskritische oder wichtige Artefakte im G2-Backend vor der Freigabe.
origin: ECC (santa-loop / santa-method), neu geschrieben für G2 — Use-Case
---

# santa-loop — zwei müssen auf demselben Nenner landen

Du führst ein **adversariales Dual-Review** durch: zwei unabhängige Prüfer untersuchen dasselbe Objekt, versuchen es zu widerlegen, diskutieren ihre Befunde miteinander und landen auf einem gemeinsamen Nenner. Erst dann gibst du eine Freigabe-Empfehlung ab.

Antworte auf **Deutsch**.

## Wann aktivieren

- Sicherheitskritischer Pfad: **Vereisungs-Bewertungslogik**, Alarm-Auslösung, Fail-safe/Stale-Erkennung.
- Wichtige Nahtstellen: API-Contract, Datenmodell, eingefrorene Schnittstellen.
- Dokumentation oder Entscheidungen vor Merge/Abgabe, wenn Qualität und Nachvollziehbarkeit kritisch sind.

## Voraussetzung

Bevor du Subagenten startest, kläre mit dem User (oder aus den Skill-Argumenten):

1. **Review-Objekt:** Datei, PR, Branch, Commit-Range, Funktion, Dokument — was genau soll geprüft werden?
2. **Fokus:** Bewertungslogik? API-Naht? RB-01/Fail-safe? Dokumentation? Sonstiges?
3. **Maßgebliche Quellen:** Wo liegt die Source of Truth? (z. B. `Schwellenwerte.md`, `Backend-Konzept.md`, `claude-sync.md`, `AGENTS.md`, Projekt-Repo)

Lies das Review-Objekt und die angegebenen Quellen selbst vollständig, bevor du die Subagenten startest. Erfinde keine Fakten.

## Ablauf

### Schritt 1 — Zwei unabhängige Prüfungen parallel starten

Starte **zwei Subagenten gleichzeitig**. Sie dürfen voneinander **nicht** wissen, dass ein zweiter Prüfer läuft.

**Subagent 1 — Prüfer A (Korrektheit):**

```
Du bist Prüfer A im santa-loop-Review.
Review-Objekt: [OBJEKT]
Fokus: [FOKUS]
Maßgebliche Quellen: [QUELLEN]

Deine Aufgabe: Prüfe das Review-Objekt auf Korrektheit, Vollständigkeit und Konsistenz gegen die Quellen.
Liste konkrete Befunde mit:
- Schweregrad: CRITICAL / HIGH / MEDIUM / LOW
- Ort im Review-Objekt (Zeile, Funktion, Abschnitt)
- Beleg aus den Quellen
- Konkreter Korrekturvorschlag

Antworte auf Deutsch. Versuche, das Objekt zu widerlegen, aber sei fair.
```

**Subagent 2 — Prüfer B (Adversarial):**

```
Du bist Prüfer B im santa-loop-Review.
Review-Objekt: [OBJEKT]
Fokus: [FOKUS]
Maßgebliche Quellen: [QUELLEN]

Deine Aufgabe: Versuche aktiv, das Review-Objekt zu widerlegen.
Suche gezielt nach:
- versteckten Fehlern, Randfällen, off-by-one-Grenzwerten
- fehlenden Feldern, Stale-Daten, Sensor-Defekten
- Sicherheitslücken (RB-01, Secrets, SQL-Injection, Fehler-Leaks)
- unklaren Annahmen, fehlendem Fail-safe, falscher Rollen-Zuordnung
- Widersprüchen zwischen Review-Objekt und Quellen

Liste konkrete Befunde mit:
- Schweregrad: CRITICAL / HIGH / MEDIUM / LOW
- Ort im Review-Objekt
- Beleg / Begründung
- Konkreter Korrekturvorschlag

Antworte auf Deutsch. Dein Job ist es, das Objekt zu brechen.
```

### Schritt 2 — Konvergenz-Moderator

Nachdem beide Prüfer zurückgemeldet haben, starte einen **dritten Subagenten** mit beiden Befund-Listen:

```
Du bist der Konvergenz-Moderator im santa-loop-Review.

Befunde von Prüfer A (Korrektheit):
[BEFUNDE_A]

Befunde von Prüfer B (Adversarial):
[BEFUNDE_B]

Deine Aufgabe:
1. Identifiziere Befunde, die von A und B übereinstimmen (gleicher Ort / gleiche Problematik).
2. Identifiziere widersprüchliche Befunde oder Befunde, die nur einer der beiden gemeldet hat.
3. Formuliere für jeden strittigen Punkt eine klärende Frage oder Entscheidung.
4. Entscheide, welche Befunde im finalen Report bestehen bleiben und welche zurückgewiesen werden.

Antworte auf Deutsch. Befunde nur zurückweisen, wenn sie belegbar falsch oder irrelevant sind.
```

**Falls Widersprüche bestehen:** Starte eine weitere Runde. Fordere Prüfer A und/oder Prüfer B auf, sich zu den strittigen Punkten zu äußern. Wiederhole das, bis beide bei allen Befunden auf demselben Nenner sind oder klar ist, dass ein Punkt offen bleibt. Maximal **3 Runden**.

### Schritt 3 — Finaler Report an den User

Präsentiere dem User ein übersichtliches Ergebnis:

```markdown
# santa-loop Review: [OBJEKT]

## Freigabe-Empfehlung
✅ freigabereif / ❌ nicht freigabereif
(Begründung in 1–2 Sätzen)

## Gemeinsame Befunde (von A und B bestätigt)
| # | Schweregrad | Ort | Befund | Korrekturvorschlag |
|---|---|---|---|---|
| 1 | ... | ... | ... | ... |

## Befunde nur von einem Prüfer (noch diskutiert)
| # | Schweregrad | Von | Ort | Befund | Korrekturvorschlag |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

## Offene Punkte / Rückfragen an dich
- ...

## Nächste Schritte
1. ...
2. ...
```

## Haltung

- **Default skeptisch:** Im Zweifel nicht freigeben.
- **Safety-Bias:** Lieber ein Fehlalarm als eine verpasste Vereisung.
- **Belegbasiert:** Jede „okay"-Aussage mit grünem Test, Command-Output oder konkretem Quellenbeleg untermauern.
- **Mensch verantwortet:** Der Agent liefert den Report — der Mensch entscheidet über Freigabe, Merge oder Abgabe.

## Nicht tun

- Mit nur einer Prüfung freigeben.
- Die adversariale Prüfung als Formalie abhaken.
- Sicherheitszweifel oder offene Punkte ignorieren.
- Subagenten gegenseitig ihre Ergebnisse zeigen, bevor beide fertig sind.

---
*Verifikation: `verification-loop`. Tests: `tdd-workflow`/`test-coverage`. Regeln: `claude-sync.md` §7.*
*Toolkit-Version: v1.5.1 · Stand: 2026-06-21*
