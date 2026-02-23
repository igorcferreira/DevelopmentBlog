---
author: Igor Ferreira
title: Usando Koin com Kotlin Multiplatform no iOS: Uma Abordagem com Bridge
description: Demonstração de uma proposta de como integration Koin em um project KMP
date: 2026-02-23 14:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
language: pt
---

# Usando Koin com Kotlin Multiplatform no iOS: Uma Abordagem com Bridge

## Introdução

Eu estava lendo um post do [Gui Rambo](https://mastodon.social/@_inside) onde ele demonstra o uso do [CloudKit para hospedagem de conteúdo e feature flags](https://rambo.codes/posts/2021-12-06-using-cloudkit-for-content-hosting-and-feature-flags). Nele, ele menciona:

> If you'd like to consume the same content that you're hosting on the public CloudKit database from an Android app or from a web app, you can. You can use the CloudKit Web Services API, which lets you do pretty much everything that can be done through the CloudKit framework over HTTP.

E isso me fez pensar: se o CloudKit tem uma API HTTP, ela pode ser usada como controle de feature flags em soluções Kotlin Multiplatform.

Montei um projeto de exemplo rápido para validar essa ideia, e funciona. Mas o processo também trouxe um segundo desafio à tona: uma arquitetura limpa tem muitas peças em movimento, como camadas de rede, mappers, repositórios e managers, e conectar tudo isso de forma organizada exige uma injeção de dependência sólida. Foi essa percepção que me trouxe até aqui.

---

## Injeção de Dependência no Kotlin Multiplatform

Gerenciamento de dependências é um dos pilares de uma base de código saudável e escalável. No ecossistema Android, contamos com ferramentas maduras como Hilt e [Koin](https://github.com/InsertKoinIO/koin) que resolvem isso bem. O Koin, em particular, se encaixa bem no Kotlin Multiplatform: é leve, feito para Kotlin, e simples de configurar em um módulo compartilhado.

No Android, usar o Koin é direto. Você o inicia na classe `Application` e injeta onde precisar usando `by inject()` ou `get()`, com `KoinComponent` e as funções de extensão do Kotlin funcionando naturalmente.

No iOS, a história é diferente. `KoinComponent` e funções de extensão do Kotlin não se traduzem bem pela bridge Swift/Obj-C, o que significa que você não pode depender dos mecanismos de injeção típicos do Koin no lado iOS. É necessário encontrar uma forma de expor os objetos injetados ao Swift sem depender de construções que ele não compreende.

---

## A Abordagem com Bridge

Uma forma de lidar com isso é introduzir uma classe `DIHelper` no módulo compartilhado. Sua função é inicializar o Koin e expor um `KoinBridge`, um objeto simples que o Swift consegue entender, que fornece acesso aos objetos gerenciados pelo Koin. Pense nele como uma janela controlada para o seu grafo de DI, criada especificamente para a camada Swift.

Veja como isso fica na prática:

**Compartilhado**

```kotlin
val networkModule = module {
    single&lt;Json> {
        //...
    }
    factory&lt;Logger> {
        //...
    }
    factory&lt;LogLevel> {
        //...
    }
    factory&lt;HttpClient> {
        //...
    }
    factory&lt;CloudKitFeatureRepository> {
        //...
    }
}

val domainModule = module {
    factory&lt;DomainMapper&lt;Map&lt;String, CloudKitIntField>, AppFeatures>> {
        //..
    }
    factory&lt;AppFeatureRepository> {
        //..
    }
    single&lt;AppFeatureManager> {
        //...
    }
}

class DIHelper {
    class KoinBridge: KoinComponent {
        val manager: AppFeatureManager
            get() = get&lt;AppFeatureManager>()
    }

    @OptIn(ExperimentalObjCRefinement::class)
    companion object {
        val MODULES = listOf(
            domainModule,
            networkModule,
        )

        @HiddenFromObjC
        fun initKoin() = startKoin {
            modules(MODULES)
        }

        fun buildBridge(): KoinBridge {
            initKoin()
            return KoinBridge()
        }
    }
}
```

No Android, você inicializa o Koin da forma habitual, com os extras específicos da plataforma, como o contexto Android:

**Android Application**

```kotlin
class Application: Application() {
    override fun onCreate() {
        super.onCreate()
        DIHelper.initKoin()
            .androidContext(applicationContext)
            .androidLogger()
    }
}
```

No iOS, ao invés de trabalhar contra a bridge, você chama `buildBridge()` e extrai diretamente o que precisa:

**iOS Application**

```swift
@main
struct iOSApp: App {
    let manager: AppFeatureManager = {
        let koin = DIHelper.companion.buildBridge()
        return koin.manager
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appFeatures: manager.state)
        }
    }
}
```

O Swift recebe um objeto limpo e fortemente tipado, sem extensões Kotlin ou `KoinComponent` envolvidos, apenas uma entrega direta e simples.

---

## Prós e Contras

Esse padrão é prático, mas vale entendê-lo bem antes de adotá-lo.

No lado positivo, sua configuração de DI fica em um único lugar, compartilhada entre as duas plataformas. A injeção permanece centralizada e controlada pelo Koin, a camada compartilhada continua testável de forma independente, e você tem um pool de objetos gerenciado sem precisar de nenhuma infraestrutura adicional.

Os principais pontos de atenção são que todo objeto que você queira expor ao Swift precisa ser declarado explicitamente no `KoinBridge`, e existe potencial de duplicação entre as propriedades do Bridge e as definições dos módulos, especialmente quando ViewModels entram em cena.

---

## Conclusão

O padrão `DIHelper` / `KoinBridge` é uma resposta pragmática a uma limitação real da bridge Swift. Ele mantém a injeção de dependência centralizada e a lógica compartilhada organizada, sem abrir mão da acessibilidade pelo lado iOS. Para um projeto onde você quer o Koin gerenciando o grafo de objetos em ambas as plataformas, é um ponto de partida razoável e válido.

Se você já abordou esse problema de outra forma ou encontrou maneiras de reduzir o boilerplate do Bridge, fique à vontade para compartilhar. Esse espaço continua evoluindo e há, certamente, outros padrões a explorar.
