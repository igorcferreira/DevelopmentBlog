---
author: Igor Ferreira
title: LLM Tools - Beyond MCP
description: MCP and Skills
date: 2026-02-05
tags: MCP, LLM, Claude, Codex
published: true
language: en
---

# LLM Tools - Beyond MCP

[Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) (#MCP) is a great way to add capabilities to your #LLM agents. But when working with #Claude or #Codex, it's not the only way to improve the knowledge and actions of your code assistant. In some cases, it may not be the preferred approach either.

MCP is a protocol that allows servers and executables to inject context into agents and list methods that can be called to perform actions based on the agent's behavior. Being a protocol, it comes with the need to create and maintain a layer that ensures your server/executable can be understood by the agents, especially regarding the inputs/outputs of the actions.

But sometimes you just want to teach the agent about what your computer is already capable of doing. Whether it's xcodebuild commands, usage of local CLI executables (like GitHub's gh), or simply how to send commands to other apps on the computer using AppleScript, the need to wrap those into a protocol orchestration may be "too much."

Thankfully, LLM agents have another way to understand context: human-readable text.

An initial project/folder context can be laid out using a CLAUDE.md/AGENTS.md file, but there's the risk of this file growing too large and making it hard to reuse these context instructions between multiple projects. To solve these issues, we have "Skills."

Skills are a text/folder structure that collects a series of human-readable instructions that can be passed to your agent, locally or globally, teaching the agent where to get information from, how to use other elements of your computer, or even providing a collection of scripts that the agent can use to better perform certain tasks.

I recently created a CLI tool to support my usage of GitHub Actions: [GHActionTrigger](https://github.com/igorcferreira/GHActionTrigger). This CLI tool helps with triggering GitHub Actions without needing a push/PR and also supports waiting for and analyzing existing runs/jobs. This could be done with the gh command line, but gh was missing some of these capabilities.

During the development process of an application, if you have GitHub as your main repo/CI, you may want to check failed jobs, pass them through LLM agents, and have the LLM agent support you in fixing/updating them. My solution for integrating the CLI tool: Skills.

By creating a `skills/ghaction.md` file, I can give context to the LLM agent. And through plugins, I can extend this functionality to all the projects on my machine.

All while keeping the integration as a human-readable document, without the need for complex/extensive MCP overlay.

Which is great. :)
