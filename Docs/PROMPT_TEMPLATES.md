# 📜 Kuma AI Session Handover & Prompt Templates

This document provides high-precision, token-efficient **English Prompt Templates** designed for seamless session handovers, task executions, code audits, and refactoring requests for Kuma.

---

## 🚀 1. Template Prompt: Cold Start Session Handover (Copy & Paste)

Use this template whenever opening a **new AI Chat Session** to instantly load context without token waste:

```markdown
Hi! We are continuing the development of Kuma (Native macOS App).

Please read and strictly comply with our core master blueprints:
1. `.agents/AGENTS.md` (Engineering Governance & Swift 6 Rules)
2. `Docs/UX_SPECIFICATION.md` (Navigation & UX Standards)
3. `Docs/ROADMAP.md` (Task Tracker Progress)

We are currently at Docs/ROADMAP.md task: [SPECIFY TASK NUMBER, e.g. Task 3.1].

Follow our Execution Workflow:
1. Create an `implementation_plan.md` artifact detailing scope, sub-folders, & technical approach.
2. Wait for user review & explicit approval on the plan before writing source code.
3. Write clean, Swift 6 compliant code adhering strictly to `.agents/AGENTS.md`.

Ready? Let me know once you have reviewed the blueprints!
```

---

## 🔍 2. Template Prompt: Code Audit & Edge-Case Review (Post-Task Audit)

Use this template in a **new AI session** to audit recently completed roadmap tasks without listing individual file paths:

```markdown
Hi! I need a strict Code & Edge-Case Audit for the files generated in the recently completed roadmap task.

Task Target: Docs/ROADMAP.md [SPECIFY TASK NUMBER & NAME, e.g. Task 3.1 DatabaseManager]

Instructions for AI Agent:
1. **Auto-Discover Changed Files**: Inspect `git status` or read `Docs/ROADMAP.md` to identify all files created/modified for this target task.
2. **Completeness Check**: Verify files against `.agents/AGENTS.md` and `Docs/ERD.md` (check for missing cases, unhandled errors, or missing domain properties).
3. **Swift 6 Concurrency & Type Safety**: Audit for `Sendable` conformance, `@MainActor` boundaries, and data race safety.
4. **Proactive Refactoring Suggestions & Action Plan**: Propose high-precision fixes or improvements FIRST, and ask for user confirmation before applying code changes!
5. **Complete Git Commands (At the Very End)**: At the very end of your response, provide the exact ready-to-copy shell commands including specific `git add [file-paths]` and Conventional `git commit -m "..."` summarizing the task changes.

Please provide your findings & refactoring suggestions first!
```

---

## 🛠️ 3. Template Prompt: Execute Next Roadmap Task

Use this template when requesting the next specific roadmap task within an active session:

```markdown
Let's proceed to the next item on Docs/ROADMAP.md:
Task [TASK NUMBER]: [TASK NAME]

Please generate the `implementation_plan.md` artifact for this task first. Detail the targeted sub-folder paths, architectural approach, and verification steps. Wait for my approval before modifying or writing code!

If this task requires logic from legacy Kuma V3 (`/Explore/Kuma/`), follow the Legacy Porting Protocol:
- Inspect V3 for core business logic & shell scripts only.
- Proactively suggest modernized alternatives if any legacy anti-patterns are found.
```

---

## 🔄 4. Template Prompt: Dynamic Rule or Feature Adaptation

Use this template if you introduce a new feature idea or update a rule mid-development:

```markdown
We have a new requirement / rule adjustment for Kuma:
[DESCRIBE REQUIREMENT, e.g. "Use custom orange status color for warming-up state"].

Please:
1. Update the relevant `.agents/skills/*.md` or `Docs/UX_SPECIFICATION.md` first.
2. Update the `Docs/ROADMAP.md` task checklist if a new sub-task is created.
3. Refactor existing code cleanly without breaking completed modules.
```

---

## 📋 5. Template Prompt: Xcode Bug Fixing & Troubleshooting

Use this template if you encounter Xcode build or runtime errors:

```markdown
We encountered an Xcode build / runtime error:
[PASTE STACK TRACE OR LOG HERE]

Please analyze the root cause based on log evidence and fix the implementation while ensuring 100% compliance with `.agents/AGENTS.md`.
```

---

### 💡 Why English Templates are Superior:
- **10-15% Higher LLM Accuracy**: Technical terms match vector embeddings directly.
- **20-30% Token Savings**: English tokenizer consumes fewer tokens per word.
- **Zero Ambiguity**: Clear, deterministic software engineering terminology.
