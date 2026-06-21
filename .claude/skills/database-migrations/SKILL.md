---
name: database-migrations
description: Datenbank-Migrationen im G2-Backend — NUR bei begründetem Stack-Wechsel (SQLite → Postgres/MySQL, ab T2+). Im T0-SQLite-Standard genügt CREATE TABLE; dieser Skill ist NICHT Teil des Standard-Sets. Nutze ihn erst, wenn ein ORM/Migrations-Toolchain eingeführt wird.
origin: ECC (database-migrations), neu geschrieben für G2 — Use-Case (situativ, T2+)
---

# database-migrations — nur bei Stack-Wechsel (G2)

> **Wichtig:** Im T0-Standard läuft G2 auf **SQLite**; das Schema wird per `CREATE TABLE` /
> `Backend-Konzept §7` initialisiert — **keine** Migrations-Toolchain nötig. Dieser Skill greift
> **erst** bei begründetem Wechsel zu Postgres/MySQL + ORM (T2+). Vorher: **nicht** verwenden.

Du planst sichere Schema-Migrationen, falls/sobald ein Migrations-Toolchain eingeführt wird. Antworte
auf **Deutsch**.

## Wann aktivieren
Erst nach **dokumentierter Entscheidung** für Stack-Wechsel auf Postgres/MySQL + ORM/Migrationstool.

## Prinzipien (falls relevant)
- **Vorwärts + rückwärts:** jede Migration mit Rollback-Pfad; nie destruktiv ohne Backup.
- **Additiv zuerst:** Spalten/Tabellen hinzufügen vor Umbenennen/Löschen (Zero-Downtime-Denke).
- **Datenmigration getrennt** von Schemaänderung; idempotent, getestet auf Kopie.
- **Versioniert + reproduzierbar:** Migrationen im Repo, in Reihenfolge, im Team abgestimmt.
- **Werte/Logik** weiterhin aus `Schwellenwerte.md` — Migration ändert Struktur, nicht Fachlogik.

## Nicht tun
- Migrations-Komplexität ohne Stack-Wechsel einführen (YAGNI). Destruktive Migration ohne Backup/Rollback.

---
*Entscheidung zuerst dokumentieren (`entscheidungslog`). Persistenz-Pattern: `Backend-Konzept` (`Alarmsystem-Dev`).*
