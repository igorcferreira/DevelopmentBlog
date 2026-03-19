---
author: Igor Ferreira
title: Estruturando o Contexto do Claude para Desenvolvimento iOS
description: Como a estrutura de pastas .claude/ — agents, skills, workflows, memory e index — fornece ao Claude contexto estável e específico do projeto sem o overhead de servidores MCP.
date: 2026-03-19 00:00
tags: Claude, AI Tools, LLM, Agentic AI, Developer Workflow
published: true
language: pt
---

# Estruturando o Contexto do Claude para Desenvolvimento iOS

O MCP dá aos agentes LLM uma forma estruturada de acessar ferramentas externas, executar comandos e trazer contexto dinâmico. É poderoso, e tem o seu lugar em muitas configurações.

Mas vem com overhead. Você precisa de um servidor ou executável, uma camada de protocolo, inputs e outputs tipados, manutenção. Às vezes esse é o tradeoff certo. E às vezes você só quer que o Claude entenda como o seu projeto iOS funciona, sem precisar subir infraestrutura pra isso.

É aí que entra a estrutura de pastas `.claude/`.

## O Que É

A pasta `.claude/` é uma camada de conhecimento local do projeto. É uma coleção de arquivos markdown simples organizados em uma pequena árvore de diretórios. Sem servidor, sem protocolo, sem schema. O Claude lê esses arquivos como contexto em linguagem humana e os usa durante toda a sua sessão.

A estrutura fica assim:

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

Cada pasta tem uma responsabilidade específica. Vamos ver cada uma delas.

---

## agents/

A pasta `agents/` guarda definições para sub-agentes especializados. Cada arquivo descreve um papel focado: no que o agente se preocupa, como ele pensa e que tipo de output ele produz.

A ideia central é que um único prompt "faz tudo" raramente é o que você quer. Quando você está desenhando uma nova feature, você quer uma perspectiva arquitetural. Quando está investigando um crash, você quer algo afinado para retain cycles e bugs de concorrência. Quando está revisando um PR, você quer algo que conheça as convenções do time e aponte desvios.

Ao separar isso em arquivos de agente individuais, você pode invocar a perspectiva certa para a tarefa certa. O seu `ios-architect.md` pode ter uma cara assim:

```markdown
# Agente iOS Architect

Você é um arquiteto iOS sênior. Quando pedido para desenhar uma feature, seu trabalho é:
- Definir fronteiras de módulos e responsabilidades
- Escolher o padrão arquitetural correto (MVVM+Coordinator, TCA, etc.)
- Identificar dependências e como elas devem ser injetadas
- Sinalizar riscos de complexidade e sugerir mitigação
- Produzir um documento de design antes de qualquer código ser escrito

Não escreva código de implementação nessa fase. Foque na clareza do design.
```

E o seu `bug-hunter.md` tem uma personalidade completamente diferente: ele lê logs de crash, pensa sobre threading, verifica retain cycles e faz perguntas difíceis sobre estado assíncrono.

Essa separação mantém cada agente focado. Também facilita atualizar e iterar. Se seus padrões de revisão mudam, você atualiza o `ios-reviewer.md` e tudo downstream recebe automaticamente.

---

## skills/

A pasta `skills/` ensina o Claude a agir em seu nome e na sua máquina. Enquanto os agentes definem *quem* o Claude está interpretando em um dado contexto, as skills definem *como* ele deve executar tarefas específicas: quais ferramentas usar, como rodá-las e qual o formato esperado do output.

Pense em uma skill como uma receita para uma capacidade. Se você quer que o Claude rode seu conjunto de testes, dispare um workflow do GitHub Actions, ou use o `xcodebuild` para fazer um build limpo e analisar o output, você descreve esse processo em um arquivo de skill. O Claude lê isso e sabe exatamente o que fazer quando você pede.

Cada arquivo de skill cobre uma capacidade específica que o seu projeto usa:

`swift-coding-standards.md` ensina o Claude a escrever Swift do jeito que o seu projeto espera: regras de nomenclatura Swift 6, onde usar `Sendable`, como lidar com `@MainActor` e os padrões preferidos do time para concorrência. Quando gerar código, o Claude segue isso como instruções, não apenas sugestões.

`ios-architecture.md` descreve as regras que o Claude deve seguir ao criar ou posicionar código: o que pertence à camada de domínio versus a camada de apresentação, como os coordinators são estruturados, onde a injeção de dependência acontece e como são as fronteiras entre camadas.

`ui-components.md` diz ao Claude como construir e posicionar componentes SwiftUI neste projeto: quais já existem, como são estruturados e qual é o processo para adicionar um novo corretamente.

`data-layer.md` dá ao Claude o contexto que ele precisa para trabalhar com SwiftData corretamente: como os predicates são estruturados nessa codebase, como o modelo de armazenamento se parece e como o contexto em background é tratado.

`testing-strategy.md` descreve o processo de testes como um conjunto de passos que o Claude deve seguir: qual framework usar, como os testes são nomeados, a estrutura GIVEN-WHEN-THEN esperada e como o ViewInspector está configurado para testes de UI.

Skills são a diferença entre o Claude improvisar uma abordagem e o Claude seguir o processo que o seu time já descobriu que funciona. Elas também são reutilizáveis entre projetos. Um `swift-coding-standards.md` que você refina em um projeto pode seguir com você para o próximo.

---

## workflows/

A pasta `workflows/` fornece playbooks passo-a-passo para as coisas que o seu time faz repetidamente. Em vez de depender que o Claude improvise um processo a cada vez, você define o processo uma vez e o Claude o segue.

Isso importa porque processo consistente leva a output consistente. Se toda nova feature segue o mesmo workflow de criação, sua codebase se mantém coerente mesmo conforme cresce. Se todo PR segue o mesmo workflow de revisão, nada escapa.

Um `create-feature.md` típico pode parecer com isso:

```markdown
# Workflow de Criação de Feature

Quando solicitado a criar uma nova feature, siga esses passos em ordem:

1. Leia o index.md para entender quais módulos serão afetados
2. Invoque o agente ios-architect para produzir um documento de design
3. Aguarde a aprovação do design antes de escrever qualquer código
4. Use a skill ios-architecture para verificar que o plano de implementação segue as regras de arquitetura
5. Crie os arquivos da feature seguindo a estrutura de módulo definida no documento de design
6. Escreva testes seguindo a skill testing-strategy
7. Execute uma verificação final usando o agente ios-reviewer antes de apresentar o output
```

Esse tipo de workflow estruturado significa que você gasta menos tempo dizendo ao Claude como abordar uma tarefa e mais tempo revisando o trabalho que ele produz.

Outros workflows nessa pasta podem cobrir debug de um crash, revisão de pull request, refatoração segura de um módulo ou construção de um novo componente SwiftUI do zero.

---

## memory/

A pasta `memory/` é onde fica o contexto de longo prazo do projeto entre sessões. Por padrão, o Claude não tem memória entre conversas, então qualquer coisa que vale carregar para a próxima sessão precisa ser escrita explicitamente. Essa pasta é onde isso acontece.

Os arquivos aqui não são instruções de como agir, e também não são um mapa da codebase. São um registro do que aconteceu e do que foi decidido: escolhas arquiteturais e o raciocínio por trás delas, problemas conhecidos que ainda não foram corrigidos, notas de sessões anteriores que ainda são relevantes.

Um arquivo `decisions.md` pode registrar por que você escolheu MVVM+Coordinator em vez de TCA, ou por que um determinado módulo foi mantido separado em vez de mesclado. Um `known-issues.md` pode listar um edge case de threading que foi reproduzido mas ainda não resolvido. Um `session-notes.md` pode registrar que uma refatoração foi iniciada na última sessão e quais arquivos já foram modificados.

Sem algo assim, cada sessão começa do zero. O Claude vai fazer perguntas que você já respondeu, ou dar sugestões que contradizem decisões já tomadas. A pasta `memory/` cria uma ponte entre sessões e mantém o contexto acumulado do projeto disponível.

Esses arquivos são feitos para serem atualizados. Quando uma decisão é tomada, escreva. Quando um problema é resolvido, remova. Trate menos como um arquivo histórico e mais como um caderno de notas vivo do projeto.

---

## index.md

O arquivo `index.md` é o mapa da codebase. Ele dá ao Claude um entendimento de alto nível do que existe, onde está e como as peças se conectam.

Sem isso, o Claude tem que descobrir a estrutura a partir dos arquivos que aparecem no contexto. Com ele, o Claude pode se orientar rapidamente e tomar decisões melhores sobre onde novo código deve ir, quais módulos possuem quais responsabilidades e quais partes da codebase podem ser afetadas por uma mudança.

Um `index.md` útil cobre:

- Estrutura de módulos de alto nível e o que cada módulo é responsável por
- Tipos, protocolos e componentes chave, com caminhos de arquivo
- Grafo de dependências: quais módulos dependem de quais
- Camadas de arquitetura e o que pertence a cada uma
- Convenções ou restrições importantes que vale saber desde o início

Esse arquivo é atualizado conforme o projeto evolui. Não é documentação para humanos, é navegação para o Claude. Mantenha-o honesto e atualizado.

---

## Por Que Não Usar Só MCP?

MCP é a ferramenta certa quando você precisa de contexto dinâmico, quando quer chamar APIs externas, executar comandos de sistema ou interagir com ferramentas que mudam com o tempo. Ele vale o peso quando essa flexibilidade é genuinamente necessária.

A estrutura `.claude/` é a ferramenta certa quando seu contexto é majoritariamente estático: sua arquitetura, suas convenções, seus workflows, seu mapa da codebase. Essas coisas não mudam a cada invocação. São conhecimento estável que deve estar disponível em toda sessão, e arquivos markdown são uma forma perfeitamente boa de armazenar e compartilhar conhecimento estável.

As duas abordagens não estão em competição. Um projeto pode usar ambas: servidores MCP para uso dinâmico de ferramentas e arquivos `.claude/` para contexto de projeto. Mas se você vai para o MCP por padrão porque parece a integração "correta", vale perguntar se alguns arquivos markdown fariam o mesmo trabalho de forma mais simples.

---

## Como Começar

Você não precisa construir toda a estrutura no primeiro dia. Comece com o `index.md` e um arquivo de skill. Quando esses parecerem úteis, adicione um workflow. Depois defina um agente para a tarefa que você faz com mais frequência.

A estrutura é leve o suficiente para que você veja valor rapidamente, e flexível o suficiente para crescer com o seu projeto.

Se você está trabalhando em um projeto iOS com o Claude e ainda não configurou uma pasta `.claude/`, essa é uma boa semana para tentar.
