# erinnerung/ — Geteilter Repo-Fortschritt (Team-OS)

Dies ist das **gemeinsame Gedächtnis** des Teams: der **allgemeine Repo-Fortschritt, den alle pflegen**.
`/start` **liest** es beim Sitzungsbeginn (damit jede:r mit demselben Stand startet — auch nach Tages-/
Personenwechsel), der Skill **`erinnerung-update`** **schreibt** am Session-Ende. Lesen und Schreiben sind
getrennt → konfliktarm.

## Struktur

| Pfad | Inhalt |
|---|---|
| `stand.md` | **Konsolidierter Gesamtüberblick**: woran wird gearbeitet, was ist als Nächstes dran, Blocker. Verdichtet der Architekt manuell aus dem Journal. |
| `journal/<YYYY-MM-DD>.md` | **Detail-Tagebuch pro Tag**: append-only Blöcke je Session/Dev. Das laufende Protokoll, aus dem `stand.md` verdichtet wird. |
| *(optional)* `entscheidungen.md` | Kurz-Spiegel wichtiger Tooling-Entscheidungen (Detail: `Entscheidungslog-Toolkit.md`). |
| *(optional)* `offene-fragen.md` | Offene Punkte, die noch jemand klären muss. |

## Regeln

- **Append-only:** Im Journal **nur unten anhängen** — nie bestehende Blöcke/Zeilen anderer ändern oder
  löschen. Das ist die Grundlage der Konfliktfreiheit (zwei Appends an verschiedenen Stellen → Git merged
  automatisch, kein Konflikt).
- **Ein Tages-Dokument:** pro Tag genau eine Datei `journal/<YYYY-MM-DD>.md`. Kein Ordner pro Rolle.
- **Rolle als Tag** im Block-Kopf: `tester | architekt | backend-db | backend-dev`.
- **Keine Secrets/Tokens.** **Keine personenbezogenen Bewertungen** über Teammitglieder.
- **Daten nicht erfinden:** Datum/Uhrzeit/Commit-Hash aus `git`/System ziehen (siehe Skill `erinnerung-update`).
- **Use-Case-/Produktstand gehört NICHT hierher**, sondern ins Arbeitsrepo `Alarmsystem-Dev`. Hier nur der
  **Arbeits-/Repo-Fortschritt** am Team-OS bzw. an der Entwicklung.

## Block-Schema (Journal)

```markdown
## [HH:MM] <Rolle: tester|architekt|backend-db|backend-dev> · <Name oder Branch>
- Was/Wo: <kurz, welches Modul/Feature>
- Commit/Push: <commit-id> "<message>"
- Nächster Schritt: <kurz>
```

## Git-Sonderregel

Erinnerungsdateien (`erinnerung/`) sind **Nicht-Code** und von der **inhaltlichen Code-Review-Pflicht
ausgenommen** — sie gehen ohne Review direkt rein (kurzes Konflikt-Fenster dank append-only). Details und
der Branch-Protection-Hinweis: `claude-sync.md` §7.

> Schreiben: Skill `erinnerung-update` · Lesen: `/start` · Workflow-Punkte: `claude-sync.md` §4 (WP0/WP8).
