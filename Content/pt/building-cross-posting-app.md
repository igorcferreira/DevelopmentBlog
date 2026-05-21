---
author: Igor Ferreira
title: Estou Construindo um App de Cross-Posting
description: O problema, a ideia e os desafios de construir o PostPortuguese
date: 2026-05-21
tags: PostPortuguese, iOS, Mastodon, Bluesky, Threads, cross-post
published: true
language: pt
---

# Estou Construindo um App de Cross-Posting

Me vi fazendo algo que parecia ridículo: copiar e colar o mesmo post em três apps diferentes, um após o outro.

Mastodon. Bluesky. Threads.

Três plataformas. O mesmo conteúdo. Três vezes o esforço. E em algum momento entre o segundo e o terceiro paste, pensei: alguém deveria resolver isso. E depois pensei: por que não eu?

Então aqui estamos.

---

## O problema

Estou no fediverso há um tempo e gosto genuinamente de estar por lá. Mas a realidade é que nem todo mundo que conheço está no Mastodon. Alguns estão no Bluesky. Alguns não saíram do Threads (ou do Instagram, ou seja lá como a Meta estiver chamando as coisas hoje em dia). E se eu quiser estar presente em todos eles, preciso postar em todo lugar, o que é tedioso.

Eu sei que existem algumas ferramentas por aí que lidam com isso. Já tentei algumas.

Queria algo que parecesse nativo às plataformas, não uma solução de mínimo denominador comum que remove tudo o que é interessante. Cada uma dessas plataformas tem sua própria personalidade. O Bluesky tem seu modelo de threads. O Mastodon tem avisos de conteúdo e configurações de idioma. O Threads é sua própria coisa. Uma boa ferramenta de cross-posting deveria saber tudo isso e lidar com isso discretamente em segundo plano.

---

## O que estou imaginando

No núcleo, o PostPortuguese é simples: você escreve seu post uma vez, clica em enviar, e ele vai para todo lugar. Mas os detalhes importam.

É o que estou pensando:

**Posts de texto com suporte a idiomas.** Este parece pequeno, mas acho que é importante. Se você está escrevendo em português (sim, o nome é uma pista), ou francês, ou japonês, a plataforma deveria saber disso. Mastodon e Bluesky permitem marcar o idioma de um post, e isso ajuda na descoberta em linhas do tempo locais. Quero suportar isso corretamente.

**Posts com imagens e textos alternativos.** Acessibilidade não é um detalhe. Se você está compartilhando fotos, deveria poder escrever o texto alternativo uma vez e tê-lo enviado para todas as plataformas que o suportam. Sem desculpas para pular isso.

**Threads.** Não o app da Meta, quero dizer posts encadeados. Pensamentos longos divididos em uma cadeia de posts ligados. As três plataformas suportam isso de alguma forma, e o app deveria lidar com a ligação e o sequenciamento automaticamente em todas elas.

**Histórico de posts.** Depois de postar, você deveria poder olhar para trás e ver o que compartilhou, e ir diretamente a qualquer plataforma para ver como está indo. Curtidas, respostas, boosts, esse tipo de coisa. O app não vai substituir os apps nativos, mas deveria facilitar chegar lá.

---

## Desafios

Honestamente? Há alguns.

A situação das APIs entre três plataformas não é trivial. A API do Mastodon é bem documentada e relativamente direta. O Bluesky usa o AT Protocol, que é mais recente e tem suas próprias peculiaridades. O Threads tem uma API com a cara da Meta que ainda não explorei completamente. Fazer os três se comportarem de forma consistente sob uma interface requer um pensamento cuidadoso.

Autenticação é outro. Entrar em três contas diferentes, lidar com tokens, renovar sessões... não é um trabalho glamouroso, mas é o tipo de coisa que, se feita mal, faz o app inteiro parecer instável.

E depois há a questão do tratamento de falhas. O que acontece se uma plataforma está fora do ar e as outras funcionam? Como comunicar isso claramente sem fazer a experiência parecer quebrada? E como lidar com os diferentes limites de caracteres entre as plataformas?

---

## E então?

Comecei a colocar algumas peças no lugar. E planejo postar mais sobre a jornada conforme ela evolui. Este app pode chegar à loja em breve (assim que descobrir algumas coisas). Mas... vamos ver.
