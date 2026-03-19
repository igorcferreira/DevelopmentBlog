---
author: Igor Ferreira
title: Structuring Claude's Context for iOS Development
description: How the .claude/ folder structure — agents, skills, workflows, memory, and index — gives Claude stable, project-specific context without the overhead of MCP servers.
date: 2026-03-19 00:00
tags: Claude, AI Tools, LLM, Agentic AI, Developer Workflow
published: true
language: en
---

# Structuring Claude's Context for iOS Development

MCP gives LLM agents a structured way to access external tools, run commands, and pull in dynamic context. It's powerful, and it earns its place in a lot of setups.

But it comes with overhead. You need a server or executable, a protocol layer, typed inputs and outputs, maintenance. Sometimes that's the right tradeoff. And sometimes you just want Claude to understand how your iOS project works, without spinning up infrastructure to make it happen.

That's where the `.claude/` folder structure comes in.

## What It Is

The `.claude/` folder is a project-local knowledge layer. It's a collection of plain markdown files organized into a small directory tree. No server, no protocol, no schema. Claude reads these files as human-readable context and uses them throughout your session.

The structure looks like this:

```
.claude/
├── agents/
│   ├── ios-architect.md
│   ├── ios-reviewer.md
│   ├── bug-hunter.md
│   ├── refactor-specialist.md
│   └── ui-builder.md
│
├── skills/
│   ├── swift-coding-standards.md
│   ├── ios-architecture.md
│   ├── ui-components.md
│   ├── data-layer.md
│   └── testing-strategy.md
│
├── workflows/
│   ├── create-feature.md
│   ├── debug-issue.md
│   ├── review-pr.md
│   ├── refactor-module.md
│   └── build-ui-component.md
│
├── memory/
│   ├── decisions.md
│   ├── known-issues.md
│   └── session-notes.md
│
└── index.md
```

Each folder has a specific responsibility. Let's go through them.

---

## agents/

The `agents/` folder holds definitions for specialized sub-agents. Each file describes a focused role: what the agent cares about, how it thinks, and what kind of output it produces.

The key idea is that a single "do everything" prompt is rarely what you want. When you're designing a new feature, you want an architectural perspective. When you're chasing a crash, you want something tuned to retain cycles and concurrency bugs. When you're reviewing a PR, you want something that knows your team's conventions and will flag deviations.

By separating these into individual agent files, you can invoke the right perspective for the right task. Your `ios-architect.md` might look something like this:

```markdown
# iOS Architect Agent

You are a senior iOS architect. When asked to design a feature, your job is to:
- Define module boundaries and ownership
- Choose the right architectural pattern (MVVM+Coordinator, TCA, etc.)
- Identify dependencies and how they should be injected
- Flag complexity risks and suggest mitigation
- Produce a written design doc before any code is written

Do not write implementation code during this phase. Focus on clarity of design.
```

And your `bug-hunter.md` has a completely different personality: it reads crash logs, thinks about threading, checks for retain cycles, and asks hard questions about async state.

This separation keeps each agent sharp. It also makes it easier to update and iterate. If your review standards change, you update `ios-reviewer.md` and everything downstream picks that up automatically.

---

## skills/

The `skills/` folder teaches Claude how to act on your behalf and on your machine. Where agents define *who* Claude is playing in a given context, skills define *how* it should perform specific tasks: which tools to reach for, how to run them, and what the expected shape of the output is.

Think of a skill as a recipe for a capability. If you want Claude to run your test suite, trigger a GitHub Actions workflow, or use `xcodebuild` to do a clean build and parse the output, you describe that process in a skill file. Claude reads it and knows exactly what to do when you ask.

Each skill file covers a specific capability your project relies on:

`swift-coding-standards.md` teaches Claude how to write Swift the way your project expects it: Swift 6 naming rules, where to use `Sendable`, how to handle `@MainActor`, and the team's preferred patterns for concurrency. When generating code, Claude follows these as instructions, not just suggestions.

`ios-architecture.md` describes the rules Claude should follow when creating or placing code: what belongs in the domain layer versus the presentation layer, how coordinators are structured, where dependency injection happens, and what the boundaries between layers look like.

`ui-components.md` tells Claude how to build and place SwiftUI components in this project: which ones already exist, how they are structured, and what the process is for adding a new one correctly.

`data-layer.md` gives Claude the context it needs to work with SwiftData correctly: how predicates are structured in this codebase, what the storage model looks like, and how background context is handled.

`testing-strategy.md` describes the testing process as a set of steps Claude should follow: which framework to use, how tests are named, the GIVEN-WHEN-THEN structure expected, and how ViewInspector is set up for UI tests.

Skills are the difference between Claude improvising an approach and Claude following the process your team has already figured out. They're also reusable across projects. A `swift-coding-standards.md` you refine on one project can travel with you to the next.

---

## workflows/

The `workflows/` folder provides step-by-step playbooks for the things your team does repeatedly. Instead of relying on Claude to improvise a process each time, you define the process once and Claude follows it.

This matters because consistent process leads to consistent output. If every new feature follows the same creation workflow, your codebase stays coherent even as it grows. If every PR follows the same review workflow, things don't slip through.

A typical `create-feature.md` might look like this:

```markdown
# Create Feature Workflow

When asked to create a new feature, follow these steps in order:

1. Read the index.md to understand which modules will be affected
2. Invoke the ios-architect agent to produce a design document
3. Wait for design approval before writing any code
4. Use the ios-architecture skill to verify the implementation plan matches architecture rules
5. Create the feature files following the module structure defined in the design doc
6. Write tests following the testing-strategy skill
7. Run a final check using the ios-reviewer agent before presenting the output
```

This kind of structured workflow means you spend less time telling Claude how to approach a task and more time actually reviewing the work it produces.

Other workflows in this folder might cover debugging a crash, reviewing a pull request, safely refactoring a module, or building a new SwiftUI component from scratch.

---

## memory/

The `memory/` folder is where the project's long-term context lives across sessions. Claude has no memory between conversations by default, so anything worth carrying forward has to be written down explicitly. This folder is where that happens.

The files here are not instructions for how to act, and they're not a map of the codebase. They're a record of what has happened and what was decided: architectural choices and the reasoning behind them, known issues that haven't been fixed yet, notes from previous sessions that are still relevant.

A `decisions.md` file might capture why you chose MVVM+Coordinator over TCA, or why a particular module was kept separate rather than merged. A `known-issues.md` might list a threading edge case that's been reproduced but not yet resolved. A `session-notes.md` might record that a refactor was started in the last session and which files were already touched.

Without something like this, every session starts cold. Claude will ask questions you've already answered, or make suggestions that contradict decisions already made. The `memory/` folder bridges sessions and keeps the project's accumulated context available.

These files are meant to be updated. When a decision is made, write it down. When an issue is fixed, remove it. Treat it less like an archive and more like a living notebook for the project.

---

## index.md

The `index.md` file is the codebase map. It gives Claude a high-level understanding of what exists, where it lives, and how the pieces connect.

Without this, Claude has to figure out the structure from whatever files happen to be in context. With it, Claude can orient quickly and make better decisions about where new code should go, which modules own which responsibilities, and which parts of the codebase might be affected by a change.

A useful `index.md` covers:

- Top-level module structure and what each module is responsible for
- Key types, protocols, and components, with file paths
- Dependency graph: which modules depend on which
- Architecture layers and what belongs in each
- Important conventions or constraints worth knowing upfront

This file gets updated as the project evolves. It's not documentation for humans, it's navigation for Claude. Keep it honest and keep it current.

---

## Why Not Just Use MCP?

MCP is the right tool when you need dynamic context, when you want to call external APIs, run system commands, or interact with tools that change over time. It earns its weight when that flexibility is genuinely needed.

The `.claude/` structure is the right tool when your context is mostly static: your architecture, your conventions, your workflows, your codebase map. These don't change on every invocation. They're stable knowledge that should be available in every session, and markdown files are a perfectly good way to store and share stable knowledge.

The two approaches are not in competition. A project can use both: MCP servers for dynamic tool use, and `.claude/` files for project context. But if you reach for MCP by default because it seems like the "proper" integration, it's worth asking whether a few markdown files would do the same job more simply.

---

## Getting Started

You don't need to build out the full structure on day one. Start with `index.md` and one skill file. Once those feel useful, add a workflow. Then define an agent for the task you do most often.

The structure is lightweight enough that you'll see value quickly, and flexible enough that it grows with your project.

If you're working on an iOS project with Claude and you haven't set up a `.claude/` folder yet, this is a good week to try it.

