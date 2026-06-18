---
name: update-docs
description: Dokumentation im G2-Backend synchron halten — API-Doku aus Routen/Schemas aktualisieren und das Entscheidungslogbuch konsolidieren. Nutze diesen Skill nach API-/Schema-Änderungen und bei Entscheidungs-Updates.
origin: ECC (update-docs), neu geschrieben für G2 — Use-Case
---

# update-docs — Doku an der Quelle synchron halten (G2)

Du hältst die Dokumentation mit dem Code konsistent — Doku ist ein **Pflichtdokument**, kein Beiwerk.
Antworte auf **Deutsch**.

## Wann aktivieren
Nach **API-/Schema-Änderung** (Routen, Pydantic-Modelle) und nach **Entscheidungen** (Logbuch).

## Ablauf
1. **API-Doku:** aus den FastAPI-Routen/Schemas ableiten (OpenAPI ist die Quelle). Prüfen, dass
   Endpoints, Felder, Status-Codes mit dem Code übereinstimmen. Contract-Änderungen sichtbar machen.
2. **Entscheidungslogbuch konsolidieren:** ADR-Rohstoff (`architecture-decision-records`) in das
   fortlaufende, deutsche Logbuch einarbeiten (Was/Warum/Alternativen).
3. **Konsistenz prüfen:** keine toten Verweise; Doku ↔ Code ↔ Anforderungen stimmig.

## Leitplanken
- **Source of Truth ist der Code/Contract** — Doku folgt dem Code, nicht umgekehrt.
- Use-Case-Doku → Code-Repo `Alarmsystem-Dev`; Tooling-Doku → dieses Repo.
- Nichts erfinden; bei Unklarheit gegen Anforderungen prüfen.

## Nicht tun
- Doku raten/erfinden. API-Änderungen ohne Doku-Update lassen. Entscheidungen unkonsolidiert lassen.

---
*Rohstoff: `architecture-decision-records`. Contract: `api-design`. Ablauf: `claude-sync.md` §4 (WP8).*
