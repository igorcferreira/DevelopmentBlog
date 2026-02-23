---
author: Igor Ferreira
title: Kotlin Multiplatform: Resolvendo Conflitos de Versão do Java no Build Phase do Xcode
description: Uma pequena alteração para corrigir o uso de Java ao rodar iOS builds no KMP
date: 2026-02-23 12:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
language: pt
---

# Kotlin Multiplatform: Resolvendo Conflitos de Versão do Java no Build Phase do Xcode

Se você trabalha com Kotlin Multiplatform há algum tempo, é provável que tenha mais de um SDK do Java instalado na sua máquina. Desenvolvimento Android, Spring Framework, ferramentas de linha de comando -- cada um tem suas próprias preferências de versão, e gerenciar isso faz parte do trabalho.

Na maior parte do tempo, o seu shell profile resolve isso sem problemas. Mas existe um lugar onde essa configuração falha silenciosamente: o Build Phase do Xcode.

## Por que o Xcode não enxerga a sua configuração do Java

Quando o template do KMP configura o target iOS, ele adiciona um script no Build Phase que chama `embedAndSignAppleFrameworkForXcode` no projeto Gradle compartilhado. O problema é que o Xcode executa esse script em um ambiente bash isolado, que não carrega o seu `.zshrc`, `.bash_profile`, nem qualquer outro arquivo onde você configurou o seu toolchain do Java. Em vez de usar a versão que você definiu, o Gradle pega qualquer versão do Java que estiver no topo do path do sistema. Se essa versão for o Java 25 e o seu projeto exigir o Java 21, o build falha.

## A solução

Antes da correção, o script padrão do Build Phase tem esta aparência:

```shell
if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then
  echo "Skipping Gradle build task invocation due to OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED environment variable set to \"YES\""
  exit 0
fi
cd "$SRCROOT/.."
./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

A solução é definir o `JAVA_HOME` inline, com escopo restrito àquela invocação do Gradle, usando o utilitário `java_home` do próprio macOS:

```shell
if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then
  echo "Skipping Gradle build task invocation due to OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED environment variable set to \"YES\""
  exit 0
fi
cd "$SRCROOT/.."
JAVA_HOME="$(/usr/libexec/java_home -v21)" ./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

O comando `/usr/libexec/java_home -v21` resolve o caminho completo para a instalação do Java 21. Definindo inline, a variável afeta apenas aquele comando específico, sem interferir no restante do ambiente de build.

Ajuste o número da versão conforme o que o seu projeto exige. Se não tiver certeza de quais versões estão disponíveis na sua máquina, execute `/usr/libexec/java_home -V` (V maiúsculo) para listar todas elas.

## Vale lembrar

Este é um arquivo de template, o que significa que ele pode ser regenerado caso você execute novamente o setup do projeto KMP. Vale registrar essa alteração em algum lugar no projeto -- um comentário no próprio script já resolve -- para não ser pego de surpresa depois de uma atualização.

---

Simples, direto, e espero que útil para quem esbarrar no mesmo problema.
