# User Manual — Devteam-Vibecodes (Team-OS G2)

> **Ein Satz vorab:** Dieses Repository ist **kein Programm, das du startest**, sondern der **Werkzeugkasten**, mit dem das Backend-Team G2 KI-gestützt arbeitet. Es bringt deiner KI-CLI (Claude Code, Kimi Code oder Codex) bei, wie das Team arbeiten will — Schritt für Schritt, regelkonform und ohne dass jemand alles auswendig lernen muss.
> Toolkit-Version: **v1.6.0**

---

## In 60 Sekunden

| Wenn du … | Dann … |
|---|---|
| **neu im Team bist** | Klone das Repo und führe das Setup für deine KI-CLI aus (`setup.sh` für Claude, `setup-kimi.sh` für Kimi, `setup-codex.sh` für Codex). |
| **eine Sitzung startest** | Tippe `/uni:start` (Claude), `/skill:start` (Kimi) oder `/prompts:start` (Codex). Die KI lädt Stand, Regeln und Git-Status. |
| **eine Aufgabe erledigen willst** | Beschreibe sie oder rufe den passenden Skill auf — die KI führt dich Schritt für Schritt. |
| **fertig bist** | Tippe `save-session`, damit der nächste Mensch nahtlos weitermachen kann. |
| **unsicher bist** | Frage `ecc-guide`: „Welcher Skill passt jetzt?" |

> **Wichtig:** Dieses Toolkit ist der **Werkzeugkasten**. Der eigentliche Code liegt im separaten Repo `Alarmsystem-Dev`.

---

## 1. Was ist das hier — und was kannst du damit wirklich machen?

### 1.1 Das Repo selbst

`Devteam-vibecodes` ist das **Team-Betriebssystem** (Team-OS) für die Gruppe G2 im Hochschulprojekt „Vereisungserkennung am Flughafen ANR". Hier liegt **nicht der eigentliche Produktcode** — der lebt im separaten Repo `Alarmsystem-Dev`. Hier liegt alles, was die KI-Agenten brauchen, um im Produktrepo nach den Team-Regeln zu arbeiten:

- die gemeinsame **Spielregel-Datei** für alle Agenten,
- **fertige Arbeitsanleitungen** (Skills) für wiederkehrende Aufgaben,
- **Setup-Skripte**, mit denen jedes Teammitglied dieselbe Umgebung bekommt,
- **eine Kopplungs-Karte**, die verhindert, dass sich Dokumente gegenseitig widersprechen,
- und ein geteiltes **Gedächtnis**, damit nicht jede Sitzung bei Null anfängt.

### 1.2 Was bedeutet das konkret für dich?

Du kannst damit wirklich Folgendes tun — ohne Programmierkenntnisse:

| Du willst … | Das Team-OS macht daraus … |
|---|---|
| Das Projekt starten | Je nach KI-CLI ein Setup-Befehl: `setup.sh`/`setup.ps1` (Claude), `setup-kimi.sh`/`setup-kimi.ps1` (Kimi) oder `setup-codex.sh`/`setup-codex.ps1` (Codex). |
| Eine Aufgabe angehen | Du tippst `/uni:start` (Claude), `/skill:start` (Kimi) oder `/prompts:start` (Codex) — die KI lädt den aktuellen Projektstand. |
| Sicherstellen, dass alle gleich arbeiten | Jeder bekommt dieselben Regeln und Skills. Bei **Claude Code** und **Kimi Code** zusätzlich das automatische Sicherheits-Hook **Fact-Forcing-Gate**. Bei Codex gelten dieselben Regeln als Text-Anweisung. |
| Eine Sitzung beenden | `save-session` schreibt, was du gemacht hast, damit der Nächste nahtlos weitermacht. |
| Eigene Entscheidungen dokumentieren | `entscheidungslog` hilft dir, deine Begründung festzuhalten — relevant für die benotete Einzelleistung. |
| Einen Kolleg:innen-Change prüfen | `code-review` und `review-pr` führen dich Schritt für Schritt durch ein Review. |
| Automatisch an Regeln erinnert werden | Bei **Claude Code** und **Kimi Code** hält das **Fact-Forcing-Gate** kurz inne, bevor die KI etwas ändert, und fragt nach dem Warum. Bei Codex musst du die Regeln selbst bewusst anwenden. |

> **Kurz gesagt:** Dieses Repo verwandelt deine KI-CLI von einem allgemeinen Chat-Tool in einen **teamkonformen Arbeitsbegleiter**, der die Regeln des G2-Projekts kennt und einhält.

---

## 2. Die Komponenten einfach erklärt

### 2.1 `claude-sync.md` — die höchste Spielregel

**Was ist das?**  
Die zentrale Anweisungsdatei für alle KI-Agenten im Team. Sie gilt global, also in jedem Repo, sobald das Setup einmal gelaufen ist.

**Was steht drin?**  
- Wer das Team ist und welche Rollen es gibt (Backend-Entwickler:in, Reviewer:in/Test, Architekt).
- Der Arbeitsablauf in 9 Workflow-Punkten (WP0 bis WP8): von „Sitzung starten" bis „Sitzung beenden".
- Sicherheitsregeln, z. B. dass die Startbahn nie automatisch freigegeben werden darf (RB-01) und dass das System bei Ausfall oder veralteten Daten nie „GRÜN" anzeigen darf (Fail-safe).
- Sprache, Namenskonventionen und Genehmigungspflichten.

**Beispiel:**  
Wenn du in einer Session sagst: „Bau mir einen Endpoint, der die Startbahn freigibt", springt die KI sofort an und erklärt: Das ist laut `claude-sync.md` verboten — RB-01. Das passiert, weil die Regel in der globalen Anweisung verankert ist.

---

### 2.2 `AGENTS.md` — die Hausordnung für dieses Repo

**Was ist das?**  
Eine kürzere Anweisung, die ergänzt, wenn die KI **genau in diesem Tooling-Repo** arbeitet.

**Was steht drin?**  
- Tooling-Repo und Code-Repo dürfen nicht verwechselt werden.
- Werden zentrale Dinge geändert, muss die Kopplungs-Karte (`Abhaengigkeiten.md`) mitgezogen werden.
- Grundlegende Conventions: Deutsch, Feature-Branch → PR → Review, keine Secrets, keine erfundenen Use-Case-Fakten.

**Beispiel:**  
Du änderst den Namen eines Skills. `AGENTS.md` sagt der KI: Stopp — rufe vor dem Commit `uni:coupling-map` auf, sonst widersprechen sich später `README.md` und `Skill-Plan.md`.

---

### 2.3 `README.md` — die Einstiegsseite für Menschen

**Was ist das?**  
Die Haupt-Lese-Datei des Repos. Sie erklärt Menschen (nicht der KI), was hier passiert, wie man installiert und was wo liegt.

**Was steht drin?**  
- Schnellstart für Claude Code, Kimi Code und Codex CLI.
- Update-Mechanismus und Versionierung.
- Eine vollständige Repo-Struktur mit allen Ordnern.
- Die Liste aller 42 Skills, aufgeteilt nach Rollen.
- Regeln und der Bezug zum Code-Repo `Alarmsystem-Dev`.

**Beispiel:**  
Ein neues Teammitglied klont das Repo und öffnet `README.md`. Nach 10 Minuten weiß es: „Ich muss `setup.sh` laufen lassen, dann Claude neu starten und `/uni:start` tippen."

---

### 2.4 Setup-Skripte — `setup.sh` / `setup.ps1` / `setup-kimi.*` / `setup-codex.*`

**Was ist das?**  
Fertige Installationsprogramme für die drei unterstützten KI-CLIs. Sie verteilen die Team-Regeln und Skills an die richtigen Stellen auf deinem Rechner.

**Was machen sie?**  
- Legen die globale Anweisung ab (`claude-sync.md` → `~/.claude/team-os-g2.md`).
- Binden sie in die persönliche `CLAUDE.md` ein, ohne diese zu überschreiben.
- Kopieren alle Skills als `uni`-Plugin (Claude) oder native Skills (Kimi/Codex).
- Legen die globalen Commands `/setup` und `/update` an.

**Beispiel:**  
Du wechselst auf einen neuen Laptop. Je nach KI-CLI führst du das passende Setup-Skript aus — `bash setup.sh` für Claude, `bash setup-kimi.sh` für Kimi oder `bash setup-codex.sh` für Codex. Danach verhält sich deine KI-CLI genau wie bei allen anderen im Team.

---

### 2.5 Update-Skripte — `update.sh` / `update.ps1` und `uniplugin`

**Was ist das?**  
Hält das Team-OS auf dem neuesten Stand. `update.sh`/`update.ps1` holen die neueste Repo-Version und führen das Setup erneut aus.

**Was machen sie?**  
- `git pull` — neue Änderungen holen.
- Setup wiederholen — alle Skills und Regeln aktualisieren.
- Version alt → neu anzeigen.

**Optional:** `install-cli.sh` / `install-cli.ps1` installiert den globalen Terminal-Befehl `uniplugin`, sodass du aus jedem Ordner `uniplugin update` tippen kannst.

**Beispiel:**  
Lucas hat drei neue Skills hinzugefügt. Du tippst `uniplugin update` (oder `bash update.sh` im Repo). Danach startest du **Claude neu** — und hast die neuen Skills verfügbar. Nutzt du **Kimi oder Codex**, führst du nach dem Update zusätzlich das jeweilige `setup-kimi.*` bzw. `setup-codex.*` erneut aus.

---

### 2.6 Commands — `/uni:start`, `/setup`, `/update`

**Was ist das?**  
Slash-Commands sind Befehle, die du direkt im Chat eingibst. Sie starten vordefinierte Abläufe. Je nach KI-CLI heißen sie leicht anders:

| KI-CLI | Start | Setup | Update |
|---|---|---|---|
| **Claude Code** | `/uni:start` | `/setup` | `/update` |
| **Kimi Code** | `/skill:start` | `/skill:setup` | — (Update via `update.sh`/`update.ps1`) |
| **Codex CLI** | `/prompts:start` | `/prompts:setup` | — (Update via `update.sh`/`update.ps1`) |

> **Hinweis:** `uni:` ist der Plugin-Namespace in Claude Code. Kimi nutzt `/skill:`, Codex nutzt `/prompts:`. Dahinter steckt derselbe Inhalt.

**Beispiel:**  
Du öffnest Claude Code am Morgen und tippst `/uni:start`. Die KI sagt dir: „Wir sind auf Branch `feat/alert-threshold`, der letzte Stand ist X, als Nächstes fehlt noch der Fail-safe-Test."

---

### 2.7 Skills — die eigentlichen Arbeitsanleitungen

**Was ist das?**  
Unter `.claude/skills/` liegen 42 fertige Anleitungen für konkrete Arbeitssituationen. Jede Anleitung heißt `SKILL.md` und erklärt der KI, wie sie bei einer bestimmten Aufgabe vorgehen soll.

**Wer ruft sie auf?**  
Du kannst sie namentlich aufrufen (z. B. `uni:tdd-workflow` in Claude, `/skill:tdd-workflow` in Kimi, `/prompts:tdd-workflow` in Codex). Wenn du nicht weißt, welcher Skill passt, fragst du `ecc-guide`: „Welcher Skill passt zu meiner Aufgabe?"

**Beispiele aus dem Alltag:**

| Skill | Wann du ihn brauchst | Beispiel |
|---|---|---|
| `uni:tdd-workflow` | Du sollst eine Funktion bauen, die Vereisung bewertet. | Die KI sagt dir: „Schreib zuerst den Test, dann die kleinste Implementierung, dann räumen wir auf." |
| `uni:quality-gate` | Bevor du etwas committest. | Die KI prüft Formatierung, Lint und Secrets. |
| `uni:code-review` | Du willst deine eigene Änderung nochmal prüfen. | Die KI liest deinen Diff und zeigt dir mögliche Probleme. |
| `uni:review-pr` | Du prüfst einen Pull Request. | Die KI führt dich durch die DoD-Checks und bereitet ein Review vor. |
| `uni:entscheidungslog` | Du hast eine Entscheidung getroffen. | Die KI hilft dir, Optionen, Begründung und verworfene Alternativen festzuhalten. |

> **Für Nicht-Techies:** Stell dir Skills wie **Checklisten in einem Flugzeugcockpit** vor. Auch erfahrene Piloten gehen sie durch, damit nichts vergessen wird.

---

### 2.8 Rollenkonzept — wer macht was?

Das Team-OS unterscheidet zwischen **wählbaren Rollen** für Teammitglieder und der festen Rolle des Architekten.

**Wählbar beim ersten Start:**

| Abteilung / Rolle | Aufgabe | Typische Skills |
|---|---|---|
| **Backend-Entwickler:in (Dev)** | Baut die eigentliche Funktionalität im Code-Repo. | `tdd-workflow`, `fastapi-patterns`, `quality-gate`, `pr` |
| **Backend-Datenbank-Engineer** | Spezialrolle innerhalb der Backend-Abteilung für Datenbank-/Persistenz-Themen. | `tdd-workflow`, `python-patterns`, `quality-gate` |
| **Reviewer:in / Tester:in** | Prüft Änderungen anderer und führt Live-Tests durch. | `code-tour`, `review-pr`, `test-coverage`, `verification-loop` |

**Feste Teamrolle (nicht wählbar):**

| Rolle | Aufgabe | Typische Skills |
|---|---|---|
| **Systemarchitekt (Lucas)** | Verantwortet Contract/Naht, Tooling, Genehmigungen, kritischen Pfad. | `spec-driven-dev`, `blueprint-spec`, `citypaul-planning`, `mp-codebase-design`, `save-session` |

> **Hinweis:** Live-Test-Skills wie `run` und `verify` sind besonders wichtig für Reviewer, können aber grundsätzlich auch von Backend-Entwickler:innen genutzt werden.

**Beispiel:**  
Wenn du als Backend-Dev `/uni:start` tippst, schlägt die KI dir den nächsten Implementierungsschritt vor. Wenn du als Reviewer startest, fragt sie stattdessen: „Soll ich den offenen PR durchgehen?"

---

### 2.9 Hooks — automatische Sicherheitsbremsen

**Was ist das?**  
Kleine Programme, die bestimmte Aktionen der KI kurz unterbrechen und prüfen, bevor sie passieren.

**Was läuft aktuell?**  
Das **Fact-Forcing-Gate** ist aktiv — **in Claude Code und Kimi Code**. Es verlangt, dass du kurz erklärst, welche Fakten für eine Aktion gelten, bevor die KI das erste Bash-Kommando ausführt oder die erste Datei bearbeitet. Bei **Codex CLI** gibt es diese automatische Bremse technisch (noch) nicht; dort musst du die Regeln selbst bewusst anwenden.

**Was ist geplant?**  
- **RB-01-Guard:** blockt automatisch Routen, die die Startbahn freigeben/sperren.
- **Secret-Scan:** verhindert, dass Passwörter oder Tokens committet werden (vor Commit und bei Tool-Nutzung).
- **OpenAPI-Schema-Diff:** meldet ungewollte Änderungen an der API-Schnittstelle.
- **Size-Guard:** prüft, dass Dateien und Funktionen nicht zu groß werden.
- **German-Check:** stellt sicher, dass Artefakte auf Deutsch bleiben.
- **Format-Lint-Gate:** stellt sicher, dass Code formatiert und lint-frei ist.
- **Test-Gate:** stellt sicher, dass Tests grün sind, bevor etwas weitergeht.

**Beispiel — normaler Befehl:**  
Du sagst der KI: „Zeige mir die Dateien im Ordner." Das Gate hält beim ersten Bash-Befehl der Session kurz an und fragt nach einer Begründung. Sobald du sie gibst, läuft der Befehl durch.

**Beispiel — destruktiver Befehl:**  
Du sagst: „Lösche den Ordner `data/backup`." Bei `rm -rf` oder `git push --force` verlangt das Gate **konkrete Fakten**: welche Dateien betroffen sind, wie ein Rollback aussieht und das wörtliche Zitat deiner Anweisung. Es gibt dafür **keinen Escape-Hatch** — erst wenn du denselben Befehl wiederholst, wird er durchgelassen.

---

### 2.10 `erinnerung/` — das geteilte Team-Gedächtnis

**Was ist das?**  
Ein Ordner, in dem der aktuelle Projektstand und Tagesprotokolle gespeichert werden. Er wird vom Start-Command (`/uni:start` in Claude) gelesen und von `save-session` beschrieben.

**Bestandteile:**

| Datei/Ordner | Zweck |
|---|---|
| `stand.md` | Konsolidierter Überblick: woran arbeitet das Team gerade, was ist als Nächstes dran? |
| `journal/<Datum>.md` | Tägliche, append-only Protokolleinträge — wer hat was gemacht. |

**Beispiel:**  
Du kommst nach dem Wochenende zurück, tippst `/uni:start` (Claude) bzw. `/skill:start` (Kimi) bzw. `/prompts:start` (Codex) und liest: „Freitag hat Maria den Fail-safe-Test eingebaut. Offen: Review durch Max. Nächster Schritt: PR freigeben." Du kannst sofort weitermachen.

---

### 2.11 `Entscheidungslog-Lucas/` — warum wurde was entschieden?

**Was ist das?**  
Hier werden wichtige Tooling-Entscheidungen dokumentiert — mit Kontext, Begründung, Alternativen und Konsequenzen.

**Warum ist das wichtig?**  
Im Projekt fließen individuelle Entscheidungen in die Note ein (sogenannte 40-%-Einzelleistung). Wer etwas entscheidet, muss nachvollziehbar begründen können.

**Beispiel:**  
Die Datei `Entscheidungslog-Toolkit.md` erklärt, warum Claude Code als Standard-Harness gewählt wurde und warum Kimi/Codex nur als Fallback dienen. Wenn jemand fragt „Warum nicht einfach ChatGPT?", findest du hier die belegte Antwort.

---

### 2.12 `Abhaengigkeiten.md` — die Kopplungs-Karte

**Was ist das?**  
Eine Tabelle, die auflistet, welche Dateien voneinander abhängen. Sie verhindert, dass eine Änderung an einer Stelle vergessene Folgeänderungen an anderer Stelle nach sich zieht.

**Wie funktioniert das?**  
Wer einen zentralen Fakt ändert (z. B. einen neuen Skill, einen neuen Workflow-Punkt, eine neue Versionsnummer), ruft `uni:coupling-map` auf. Dieser Skill liest `Abhaengigkeiten.md` und aktualisiert alle betroffenen Spiegel.

**Beispiel:**  
Ein Skill wird umbenannt. Ohne Kopplungs-Karte müsstest du `README.md`, `Skill-Plan.md`, `Skillanleitung.md` und mehrere Abteilungs-Dateien von Hand anpassen. Mit `Abhaengigkeiten.md` weiß `uni:coupling-map` genau, wo überall nachgezogen werden muss.

---

### 2.13 `Skill-Plan.md` und `Skillanleitung.md`

**Was ist das?**  
- `Skill-Plan.md` ist der **Master-Plan**: Welche Skills gibt es, warum wurden sie ausgewählt, welche Rollen nutzen sie, und welche Skills wurden bewusst **nicht** aufgenommen.
- `Skillanleitung.md` zeigt die Skills **in Aktion** — anhand zweier realistischer Szenarien (Backend-Dev und Reviewer).

**Beispiel:**  
Du fragst dich: „Welchen Skill brauche ich, wenn ich einen PR reviewen soll?" In `Skillanleitung.md` findest du Szenario B: `uni:start` → `code-tour` → `review-pr` → `run` + `verify` → `save-session`.

---

### 2.14 `tests/` — die Qualitätsprüfung des Team-OS

**Was ist das?**  
Automatisierte Tests, die prüfen, ob das Team-OS selbst korrekt funktioniert.

**Was wird geprüft?**  
- Ob das Setup-Skript die Hooks korrekt installiert.
- Ob das Fact-Forcing-Gate wie erwartet blockt und durchlässt.

**Beispiel:**  
Lucas ändert das Setup-Skript. Bevor das Update an alle geht, laufen die Tests und zeigen: „Ja, die neue Version installiert das Gate noch korrekt." Dadurch wird verhindert, dass ein fehlerhaftes Update alle lahmlegt.

---

### 2.15 `VERSION` und Git-Tags

**Was ist das?**  
`VERSION` enthält die aktuelle Version des Toolkits (z. B. `1.5.1`). Git-Tags wie `v1.6.0` markieren Releases.

**Warum ist das nützlich?**  
Wenn bei einem Teammitglied etwas komisch läuft, kannst du schnell vergleichen: „Bei dir steht noch v1.5.0, aber aktuell ist v1.6.0 — bitte einmal `/update` laufen lassen."

**Beispiel:**  
Jemand meldet: „Der Skill fehlt bei mir." Die erste Frage lautet: „Welche VERSION zeigt `uniplugin version`?" Damit lässt sich viel eingrenzen.

---

### 2.16 `CLAUDE.md` — die projektbasierte Ergänzung

**Was ist das?**  
Neben `claude-sync.md` gibt es im Repo-Root auch eine `CLAUDE.md`. Während `claude-sync.md` die **globale** Anweisung für alle Agenten ist, gilt `CLAUDE.md` speziell für Arbeiten **in diesem Tooling-Repo**.

**Was steht drin?**  
- Erinnerung daran, dass hier kein Produktcode liegt.
- Die Pflicht, bei Tooling-Änderungen die Kopplungs-Karte (`Abhaengigkeiten.md`) mitzuziehen.
- Grundlegende Conventions: Deutsch, Branch → PR → Review, keine Secrets.

**Beispiel:**  
Du arbeitest an einem neuen Skill. `CLAUDE.md` sagt dir: Vergiss nicht, `uni:coupling-map` aufzurufen, sonst stimmen später `README.md` und `Skill-Plan.md` nicht mehr überein.

---

### 2.17 `.github/workflows/` — automatische Helfer auf GitHub

**Was ist das?**  
Automatisierte Abläufe, die auf GitHub laufen, wenn bestimmte Ereignisse eintreten (z. B. ein neuer Kommentar oder ein Pull Request).

**Was machen sie?**  
- `claude.yml` reagiert auf Issue-/PR-Kommentare mit einem `@claude`-Trigger.
- `claude-code-review.yml` löst automatische PR-Reviews aus.

**Beispiel:**  
Jemand schreibt in einem PR `@claude review this`. Der GitHub-Workflow startet und unterstützt das Review.

> **Für Nicht-Techies:** Stell dir das wie einen ** automatischen Assistenten** vor, der auf bestimmte Schlüsselwörter reagiert und dann eine Aufgabe erledigt.

---

### 2.18 `Seam-Sync-Fragenkatalog.md` — die Nahtstellen-Checkliste

**Was ist das?**  
Eine Checkliste mit Fragen für die Schnittstellen (Nahtstellen) zwischen den Gruppen G1 (Sensorik), G2 (Backend) und G3 (Frontend).

**Wann braucht man das?**  
Wann immer zwei Gruppen gemeinsam definieren müssen, wie Daten oder Befehle ausgetauscht werden — z. B. welche Sensordaten G1 an G2 liefert oder welche API G2 für G3 bereitstellt.

**Beispiel:**  
G3 möchte eine Anzeige für den Vereisungsstatus. Der Fragenkatalog hilft, klärende Fragen zu formulieren: „Welche Daten liefert der Backend-Endpoint?", „Wie oft werden sie aktualisiert?", „Was passiert bei Stale-Daten?"

---

## 3. Dein typischer erster Tag

1. **Repo klonen** und in den Ordner wechseln.
2. **Setup für deine KI-CLI ausführen**:
   - **Claude Code:** `bash setup.sh` (Mac/Linux) oder `powershell -ExecutionPolicy Bypass -File .\setup.ps1` (Windows).
   - **Kimi Code:** `bash setup-kimi.sh` (Mac/Linux) oder `powershell -ExecutionPolicy Bypass -File .\setup-kimi.ps1` (Windows).
   - **Codex CLI:** `bash setup-codex.sh` (Mac/Linux) oder `powershell -ExecutionPolicy Bypass -File .\setup-codex.ps1` (Windows).
3. **Claude Code / Kimi / Codex neu starten.**
4. Den Start-Command tippen: `/uni:start` (Claude), `/skill:start` (Kimi) oder `/prompts:start` (Codex).
5. Beim ersten Mal deine **Abteilung wählen**:
   - Backend-Entwicklung → dann **Dev** oder **Database-Engineer**.
   - Reviewer/Test.
6. Die KI schlägt dir vor, was als Nächstes zu tun ist.

> **Tipp:** Für eine noch kürzere Version dieser Anleitung siehe `ONBOARDING.md`.

---

## 4. Wichtige Grundregeln auf einen Blick

- **Sprache:** Alle Artefakte sind auf Deutsch.
- **Git:** Nie direkt auf `main` pushen — immer Feature-Branch → Pull Request → Review.
- **Genehmigung:** Push, PR, Merge und gefährliche Git-Befehle nur mit Freigabe von Lucas.
- **Use-Case-Fakten:** Schwellenwerte und Anforderungen kommen aus `Alarmsystem-Dev`, nicht aus dem Kopf der KI.
- **Sicherheit:** Das System darf die Startbahn nie automatisch steuern und bei Problemen nie „GRÜN" anzeigen.
- **Dokumentation synchron halten:** Wer zentrale Fakten ändert, ruft `uni:coupling-map` auf.

---

## Glossar für Nicht-Techies

| Begriff | Einfache Erklärung |
|---|---|
| **Repo** (Repository) | Ein gemeinsamer Ablageort für Dateien, meist mit Versionsverwaltung — vergleichbar mit einem geteilten Ordner, der protokolliert, wer wann was geändert hat. |
| **KI-CLI** | Ein Programm, mit dem du im Terminal oder Editor mit einer KI sprichst (z. B. Claude Code, Kimi Code, Codex CLI). |
| **Skill** | Eine fertige Anleitung für die KI, wie sie bei einer bestimmten Aufgabe vorgehen soll. |
| **Command** | Ein Befehl, den du mit `/` eingibst, um einen vordefinierten Ablauf zu starten. |
| **Commit** | Ein Schnappschuss deiner Änderungen, den du im Repo speicherst. |
| **Pull Request (PR)** | Ein Vorschlag, deine Änderungen in den Hauptzweig des Projekts zu übernehmen, den andere vorher prüfen. |
| **Branch** | Ein paralleler Arbeitszweig im Repo, an dem du etwas Neues ausprobieren kannst, ohne den Hauptstand zu gefährden. |
| **Endpoint** | Eine Adresse in einem Programm, über die andere Programme Daten anfragen oder senden können. |
| **Diff** | Die Darstellung der Unterschiede zwischen zwei Versionen einer Datei. |
| **Hook** | Ein kleines Programm, das vor oder nach einer Aktion automatisch prüft, ob etwas erlaubt ist. |
| **Stale-Daten** | Veraltete oder nicht mehr aktuelle Daten. |
| **Contract / Naht** | Die vereinbarte Schnittstelle zwischen zwei Systemen oder Gruppen. |

---

*Gepflegt im Repo `Devteam-vibecodes` · Toolkit-Version: v1.6.0 · Stand: 2026-06-21*
