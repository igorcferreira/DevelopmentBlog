---
author: Igor Ferreira
title: Ferramentas LLM - Além do MCP
description: MCP e Skills
date: 2026-02-05
tags: MCP, LLM, Claude, Codex
published: true
language: pt
---

# Ferramentas LLM - Além do MCP

O [Model Context Protocol](https://modelcontextprotocol.io/docs/getting-started/intro) (#MCP) é uma ótima maneira de adicionar capacidades aos seus agentes #LLM. Mas ao trabalhar com #Claude ou #Codex, não é a única forma de melhorar o conhecimento e as ações do seu assistente de código. Em alguns casos, pode não ser a abordagem preferida.

MCP é um protocolo que permite que servidores e executáveis injetem contexto em agentes e listem métodos que podem ser chamados para executar ações com base no comportamento do agente. Sendo um protocolo, ele vem com a necessidade de criar e manter uma camada que garanta que seu servidor/executável possa ser compreendido pelos agentes, especialmente em relação às entradas/saídas das ações.

Mas às vezes você só quer ensinar o agente sobre o que seu computador já é capaz de fazer. Seja comandos xcodebuild, uso de executáveis CLI locais (como o gh do GitHub), ou simplesmente como enviar comandos para outros apps no computador usando AppleScript, a necessidade de envolver isso em uma orquestração de protocolo pode ser "demais".

Felizmente, agentes LLM têm outra maneira de entender contexto: texto legível por humanos.

Um contexto inicial de projeto/pasta pode ser definido usando um arquivo CLAUDE.md/AGENTS.md, mas há o risco deste arquivo crescer demais e dificultar a reutilização dessas instruções de contexto entre múltiplos projetos. Para resolver esses problemas, temos as "Skills".

Skills são uma estrutura de texto/pasta que coleta uma série de instruções legíveis por humanos que podem ser passadas ao seu agente, local ou globalmente, ensinando o agente de onde obter informações, como usar outros elementos do seu computador, ou até mesmo fornecendo uma coleção de scripts que o agente pode usar para executar melhor certas tarefas.

Recentemente criei uma ferramenta CLI para apoiar meu uso do GitHub Actions: [GHActionTrigger](https://github.com/igorcferreira/GHActionTrigger). Esta ferramenta CLI ajuda a disparar GitHub Actions sem necessidade de push/PR e também suporta esperar e analisar runs/jobs existentes. Isso poderia ser feito com a linha de comando gh, mas o gh estava faltando algumas dessas capacidades.

Durante o processo de desenvolvimento de uma aplicação, se você tem o GitHub como seu principal repo/CI, você pode querer verificar jobs que falharam, passá-los por agentes LLM, e fazer o agente LLM te apoiar na correção/atualização deles. Minha solução para integrar a ferramenta CLI: Skills.

Ao criar um arquivo `skills/ghaction.md`, posso dar contexto ao agente LLM. E através de plugins, posso estender essa funcionalidade para todos os projetos na minha máquina.

Tudo isso mantendo a integração como um documento legível por humanos, sem a necessidade de uma camada complexa/extensa de MCP.

O que é ótimo. :)
