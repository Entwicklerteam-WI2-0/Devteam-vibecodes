---
name: security-review
description: Sicherheits-Review — Ingest-Validierung, Audit, RB-01 (kein Aktor), keine Secrets. Nutze diesen Skill als Selbst-Review vor dem PR oder als Reviewer-Werkzeug.
origin: ECC (security-review), neu geschrieben für G2 — Python/FastAPI + Use-Case
---

# security-review — sicherheitskritische Stellen prüfen (G2)

Du reviewst Code auf sicherheitskritische Aspekte. Antworte auf **Deutsch**.

## Checkliste
1. **RB-01 — kein Aktor:** Keine Routen/Funktionen mit `release`, `freigabe`, `sperr`, `aktor`, `control`.
2. **Input-Validierung:** Alle externen Eingaben über Pydantic/Validatoren; keine SQL-Injection.
3. **Secrets:** Keine API-Keys/Tokens/Passwörter im Code; Platzhalter + Env-Vars.
4. **Audit:** Sicherheitsrelevante Aktionen geloggt?
5. **Fail-safe (NF-01):** Bei Ausfall/Stale nie GRÜN.
6. **Berechtigungen:** Keine ungeschützten Endpoints, die Zustand verändern.

## Nicht tun
- Sicherheitsbedenken als „zu streng" abtun.
- RB-01-Verstöße nur vermerken, nicht blockieren.

---
*Allgemeiner Review: `code-review`. Regeln: `claude-sync.md` §7.*
