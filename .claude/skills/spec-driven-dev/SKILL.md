---
name: spec-driven-dev
description: Spec-driven development methodology that transforms feature requests into structured documentation before coding. Use when users want to (1) plan a new software project or feature, (2) create requirements/design/tasks documentation, (3) follow a structured development workflow, (4) break down complex features into trackable tasks. Triggers include phrases like "let's plan this properly", "spec-driven", "create requirements", "design document", "task breakdown", "before we start coding".
metadata:
  origin: community
---

# Spec-Driven Development

Transform high-level goals into structured, traceable documentation before writing code.

## Workflow Overview

```
Feature Request → Requirements → Design → Tasks → Implementation
                     ↓              ↓        ↓
              requirements.md  design.md  tasks.md
```

## Three-Phase Process

### Phase 1: Requirements Analysis
Convert goals into user stories with EARS acceptance criteria.

**Output**: `requirements.md`
- Product overview (vision, constraints, target users)
- User stories grouped by Epic
- Acceptance criteria using EARS notation
- Non-functional requirements
- Out of scope items

### Phase 2: Technical Design
Create architecture based on approved requirements.

**Output**: `design.md`
- System architecture diagram
- Technology stack decisions
- Data models and schemas
- API specifications
- Component designs
- Security and deployment considerations

### Phase 3: Task Implementation
Generate ordered, dependency-aware tasks linked to requirements.

**Output**: `tasks.md`
- Tasks grouped by phase
- Each task linked to requirement IDs
- Time estimates
- Status tracking (🔴🟡🟢🔵)
- Critical path identification
- Dependency mapping

## EARS Notation Reference

| Type | Pattern | Example |
|------|---------|---------|
| Ubiquitous | The system SHALL... | The system SHALL encrypt all data at rest |
| Event-Driven | WHEN [trigger], THEN... | WHEN user clicks Save, THEN system SHALL persist data |
| State-Driven | WHILE [state], the system SHALL... | WHILE in offline mode, the system SHALL queue requests |
| Optional | IF [condition], THEN... | IF user has premium, THEN system SHALL enable feature X |
| Unwanted | IF [condition], THEN... SHALL NOT | IF input invalid, THEN system SHALL NOT proceed |

## Execution Guidelines

1. **Start with requirements** - Never skip to design without clear requirements
2. **Validate before proceeding** - Get user confirmation at each phase
3. **Link everything** - Tasks → Requirements → User Stories
4. **Keep documents separate** - Don't merge into single monolithic PRD
5. **Iterate** - Documents evolve as understanding deepens

## Templates

Detailed templates for each document:
- `references/requirements-template.md` - Full requirements structure
- `references/design-template.md` - Architecture and API patterns
- `references/tasks-template.md` - Task breakdown format

## Quick Start

When user requests a new feature/project:

1. Ask clarifying questions about scope and constraints
2. Read `references/requirements-template.md`
3. Draft requirements.md with user stories
4. Review with user, iterate
5. Read `references/design-template.md`
6. Draft design.md with architecture
7. Review with user, iterate
8. Read `references/tasks-template.md`
9. Generate tasks.md with ordered implementation plan
10. Begin implementation phase by phase. When work at the phase level is completed, make sure to verify that all tasks for that item have been perfectly executed and test them
