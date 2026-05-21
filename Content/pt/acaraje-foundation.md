---
author: Igor Ferreira
title: Acarajé, a Base do PostPortuguese
description: Como uma bandeja, uma baiana e uma comida de rua da Bahia viraram a arquitetura de um framework de cross-posting
date: 2026-05-22
tags: PostPortuguese, iOS, Mastodon, Bluesky, Threads, arquitetura, Swift, framework
published: true
language: pt
image: /images/acaraje-architecture.png
---

# Acarajé, a Base do PostPortuguese

No [primeiro post](/pt/building-cross-posting-app/), falei sobre o problema: copiar o mesmo texto em três aplicativos diferentes, um depois do outro, é cansativo e tinha que existir uma forma melhor. Agora quero falar sobre a estrutura que fui montando para resolver isso, um pacote Swift chamado **Acaraje**, desenvolvido em conjunto com o [Diogo](https://mastodon.social/@diogot).

O nome não é por acaso. Acarajé é um prato tradicional da Bahia, feito de feijão-fradinho amassado e frito no azeite de dendê. É vendido nas ruas pelas baianas, que carregam os ingredientes e utensílios num tabuleiro. A operação toda é pequena e autossuficiente: uma pessoa, um tabuleiro, tudo o que precisa para servir a todo mundo que passar.

Essa pareceu a metáfora certa para o que eu estava construindo.

---

## A ideia central

O objetivo do Acaraje é oferecer uma interface única e consistente para publicar em múltiplas plataformas sociais, sem deixar de permitir que cada plataforma se comporte do jeito que precisa.

Essa é a tensão no centro do problema. O Mastodon é federado, ou seja, você se conecta a um servidor específico, não a uma autoridade central única. O Bluesky usa o AT Protocol, com seu próprio fluxo de OAuth e suas próprias particularidades. O Threads é um produto da Meta com uma API no estilo Meta. Eles são genuinamente diferentes. Uma boa abstração não pode fingir que são iguais, mas também não deve obrigar quem usa a se preocupar com essas diferenças.

A forma como o Acaraje lida com isso é através de três camadas: os **protocolos Tabuleiro**, as **implementações de plataforma**, e a **Baiana** que une tudo.

---

## Tabuleiro: descrevendo o que uma plataforma consegue fazer

Um `Tabuleiro` é um protocolo. Na forma mais básica, ele apenas diz: "esse negócio conhece algumas contas e consegue fazer logout delas."

```swift
public protocol Tabuleiro: Sendable {
    func fetchAccounts() -> [any Account]
    func logout(account: any Account) async throws
}
```

Esse é o piso. A partir daí, uma plataforma pode optar por capacidades adicionais conformando protocolos mais específicos.

**Autenticação** vem em dois formatos, porque nem todas as plataformas funcionam do mesmo jeito. Plataformas centralizadas como o Bluesky têm um único endpoint de login:

```swift
public protocol AuthenticatableTabuleiro: Tabuleiro {
    func authenticate() async throws -> any Account
}
```

Plataformas federadas como o Mastodon precisam saber a qual servidor você está se conectando:

```swift
public protocol FederatedTabuleiro: Tabuleiro {
    func authenticate(instance: URL) async throws -> any Account
}
```

**Publicação** também é dividida por tipo de conteúdo. Posts de texto, posts com uma imagem, posts com múltiplas imagens, posts de vídeo: cada um é seu próprio protocolo. Uma plataforma só conforma o que ela de fato suporta.

```swift
public protocol TextTabuleiro: Tabuleiro {
    var maxTextLength: Int { get }
    func validateText(_ text: String) -> TextValidationResult
    func post(text: String, language: Locale?, quotePolicy: QuotePolicy?, replyTo: (any Post)?, accounts: [any Account]?) async throws -> [any Post]
}

public protocol MultipleImageTabuleiro: Tabuleiro {
    var imageLimit: Int { get }
    func post(images: [ImageAttachment], text: String?, language: Locale?, quotePolicy: QuotePolicy?, replyTo: (any Post)?, accounts: [any Account]?) async throws -> [any Post]
}
```

Isso importa para uma plataforma como o Instagram, que é só de imagens. Ela conformaria `AuthenticatableTabuleiro` e `ImageTabuleiro`, mas não `TextTabuleiro`. O resto do sistema não precisa saber nem se importar com isso. Ele só verifica o que a plataforma consegue fazer e usa o que está disponível.

---

## Implementações de plataforma: os Tabuleiros

`MastodonTabuleiro` e `BlueskyTabuleiro` são as implementações concretas. O trabalho deles é pegar os protocolos abstratos e mapeá-los para as chamadas de API reais de cada plataforma.

`MastodonTabuleiro` conforma `FederatedTabuleiro`, porque você precisa escolher um servidor Mastodon. Ele também conforma `TextTabuleiro`, `ImageTabuleiro` e `MultipleImageTabuleiro`, porque o Mastodon suporta tudo isso. O `maxTextLength` vem da configuração do servidor, tipicamente 500 caracteres.

`BlueskyTabuleiro` conforma `AuthenticatableTabuleiro`, já que o Bluesky é centralizado. Por baixo dos panos, ele usa um cliente AT Protocol de baixo nível num módulo separado, o `BlueskyAPI`, que cuida do fluxo OAuth, tokens DPoP, chamadas XRPC e renovação de token. Nada disso vaza para a interface de tabuleiro de nível mais alto.

Essa separação é intencional. A complexidade específica de cada plataforma vive dentro do tabuleiro. Quem usa o framework só vê os protocolos.

---

## Baiana: a que serve todo mundo

A `Baiana` é a coordenadora. Você passa uma lista de tabuleiros para ela, e ela sabe como delegar as chamadas para os certos.

```swift
public final class Baiana: Sendable {
    public let tabuleiros: [any Tabuleiro]

    public init(tabuleiros: [any Tabuleiro]) {
        self.tabuleiros = tabuleiros
    }
}
```

Quando você pede para a Baiana publicar um texto, ela percorre os tabuleiros procurando qualquer um que conforme `TextTabuleiro`, e então chama todos eles de forma concorrente usando um `TaskGroup`. O mesmo vale para imagens, threads e qualquer outra coisa. Se um tabuleiro não suporta o tipo de conteúdo solicitado, ele simplesmente é ignorado.

```swift
func post(text: String, language: Locale?, ...) async throws -> [any Post] {
    let textTabuleiros = tabuleiros.compactMap { $0 as? TextTabuleiro }
    return try await withThrowingTaskGroup(of: [any Post].self) { group in
        for tabuleiro in textTabuleiros {
            group.addTask {
                try await tabuleiro.post(text: text, ...)
            }
        }
        // coleta e retorna os resultados
    }
}
```

Threads (o tipo encadeado e sequencial, não o app da Meta) são tratados de forma parecida, mas com um passo adicional de rastreamento. A Baiana mantém o registro do último post de cada plataforma e o passa como `replyTo` para o próximo item da corrente. Cada plataforma tem sua própria cadeia de respostas, mantida de forma independente.

O resultado é que quem usa o framework escreve algo assim:

```swift
let baiana = Baiana(tabuleiros: [mastodonTabuleiro, blueskyTabuleiro])
let posts = try await baiana.post(text: "Olá, mundo", language: .current, accounts: nil)
```

E as duas plataformas recebem o post. Sem loop manual. Sem ramificação por plataforma.

---

## O que fica onde

![Diagrama de arquitetura do Acaraje mostrando as quatro camadas: Baiana, protocolos Tabuleiro, implementações de plataforma e o app PostPortuguese](/images/acaraje-architecture.png)

Um resumo da estrutura do pacote, porque os limites entre as camadas importam:

- **`Acaraje`**: define os protocolos e os modelos de dados. Nenhuma lógica específica de plataforma vive aqui.
- **`AcarajeKeychain`**: helpers de Keychain compartilhados, usados pelas implementações de tabuleiro para armazenar credenciais.
- **`MastodonTabuleiro`**: implementação do Mastodon, construída em cima do TootSDK.
- **`BlueskyAPI`**: cliente AT Protocol de baixo nível. OAuth, DPoP, XRPC. Separado do tabuleiro para que possa ser usado de forma independente se necessário.
- **`BlueskyTabuleiro`**: implementação do Bluesky, usando o `BlueskyAPI`.

O app fica em cima das mesmas bibliotecas `MastodonTabuleiro` e `BlueskyTabuleiro`. Os tabuleiros expõem alguns extras específicos do app, como um método `authenticateWithWebView` para o Mastodon que conduz o login através de `ASWebAuthenticationSession`, mas os protocolos centrais não mudam.

---

## Por que essa estrutura ajuda

O principal benefício desse design em camadas é que adicionar uma nova plataforma não mexe em nada que já existe. Você escreve um novo tabuleiro, o faz conformar os protocolos que fazem sentido para aquela plataforma, e entrega para a `Baiana`. Todo o resto continua funcionando.

Isso também torna os testes mais limpos. Você pode escrever um tabuleiro mock que conforma `TextTabuleiro` e retorna posts falsos sem tocar em nenhum código de rede. A `Baiana` não sabe nem se importa que está falando com um mock.

E significa que o app e o framework compartilham as mesmas bibliotecas centrais, com cada camada adicionando apenas o que é específico do seu ambiente, como o funcionamento do armazenamento de credenciais ou o redirecionamento do OAuth.

---

O nome Acaraje é o certo para isso. Tem um tabuleiro, uma Baiana, muitas coisas que ela pode servir. O prato é feito de poucos ingredientes combinados com cuidado, e o resultado é algo que funciona em muitos lugares.
