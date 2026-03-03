---
author: Igor Ferreira
title: Integrando as funcionalidades do seu app com LLMs locais
description: Uma descrição de como Android e iOS permitem que você ofereça as funcionalidades do seu app como ferramentas equivalentes ao MCP para LLMs locais
date: 2026-03-03 14:00
tags: iOS, Android, Gemini, Apple Intelligence
published: true
language: pt_BR
---

# Integrando as funcionalidades do seu app com LLMs locais

Assistentes de IA locais estão se tornando cidadãos de primeira classe tanto no iOS quanto no Android. O Apple Intelligence traz um conjunto de funcionalidades de IA profundamente integradas ao sistema, enquanto o assistente Gemini do Google é cada vez mais capaz de executar ações entre apps no Android. Ambas as plataformas já vêm com modelos de linguagem rodando localmente, capazes de entender a intenção do usuário e agir, sem precisar de uma ida à nuvem.

É uma evolução empolgante. Mas se você está desenvolvendo um app e quer que esses assistentes interajam com as suas funcionalidades, há uma limitação importante que vale conhecer antes de começar.

## Apple Intelligence e o assistente Gemini

O Apple Intelligence é a camada de IA local da Apple, introduzida no iOS 18. Ela alimenta funcionalidades como Writing Tools, resumos inteligentes no Mail e Mensagens e, o mais relevante aqui, uma Siri significativamente mais capaz de entender requisições em linguagem natural em todo o sistema e navegar diretamente para os apps.

No Android, o Gemini atua como camada de assistente, com o Google expandindo sua capacidade de entender o contexto na tela e orquestrar tarefas entre apps. O Gemini pode interagir com apps de mais de uma forma: AppFunctions é a abordagem estruturada e opt-in abordada neste post, mas o Gemini também possui um modo agêntico que controla apps por meio da API de acessibilidade, sem exigir nenhum trabalho de integração do desenvolvedor. Ambos os assistentes são sustentados, ao menos em parte, por modelos rodando localmente no dispositivo, o que lhes confere vantagens de velocidade e privacidade em relação a abordagens puramente baseadas em nuvem.

## Limitações das ferramentas MCP

Se você acompanha o ecossistema de ferramentas de IA, provavelmente já conhece o [Model Context Protocol (MCP)](https://modelcontextprotocol.io/), um padrão para expor ferramentas e fontes de dados a LLMs, permitindo que eles chamem serviços externos durante a inferência.

É um ótimo padrão. Mas os assistentes locais no iOS e Android não suportam a injeção de servidores MCP arbitrários. Os modelos nessas plataformas operam em um ambiente controlado e com sandbox. Não é possível simplesmente apontar a Siri ou o Gemini para o seu endpoint MCP e esperar que eles chamem as suas ferramentas.

Em vez disso, ambas as plataformas oferecem seus próprios mecanismos nativos para exatamente esse propósito, e eles funcionam surpreendentemente bem como equivalentes conceituais.

## AppIntent e AppFunctions

A resposta da Apple é o **[AppIntents](https://developer.apple.com/documentation/appintents/appintent)**, um framework Swift introduzido no iOS 16 que permite expor partes discretas da funcionalidade do app ao sistema. Siri, Atalhos, Spotlight e agora o Apple Intelligence usam AppIntents para entender o que o seu app pode fazer.

A resposta do Android, mais recentemente, são as **[AppFunctions](https://developer.android.com/ai/appfunctions)**, uma biblioteca Jetpack que segue uma filosofia semelhante: anote suas funções Kotlin e o sistema (incluindo o Gemini) poderá descobri-las e invocá-las em nome do usuário. AppFunctions exigem Android 16 ou superior e, atualmente, são limitadas a um pequeno conjunto de dispositivos compatíveis, principalmente do Google e da Samsung.

Ambas as abordagens permitem descrever capacidades de forma estruturada que um LLM consegue interpretar. Pense nelas como definições de ferramentas tipadas e descobríveis, cumprindo o mesmo papel que as ferramentas MCP desempenham em uma configuração de IA no servidor.

Veja como um app de gerenciamento de tarefas pode implementá-las lado a lado. O projeto de exemplo completo está disponível no GitHub, com o [código Android](https://github.com/igorcferreira/KotlinNativeStudies/tree/main/appfunctiondemo/composeApp/src/main/java/dev/igorcferreira/appfunctiondemo/functions) e o [código iOS](https://github.com/igorcferreira/KotlinNativeStudies/tree/main/appfunctiondemo/iosApp/iosApp/Intents) cada um em sua própria pasta.

### Definindo funções no Android

Com AppFunctions, você cria uma classe e anota seus métodos com `@AppFunction`. O comentário KDoc de cada função se torna a descrição que o sistema usa para entender quando e como chamá-la:

```kotlin
class TaskFunctions : KoinComponent {
    private val repository: TaskRepository by inject()

    /**
     * List all the current tasks which are present in the general board.
     *
     * @param appFunctionContext    The context in which the AppFunction is executed
     *
     * @return The list of [Task] objects currently saved
     */
    @AppFunction(isDescribedByKdoc = true)
    suspend fun listTasks(
        appFunctionContext: AppFunctionContext
    ): List&lt;Task> = repository.getAll()

    /**
     * Adds a new task to the general board.
     *
     * @param appFunctionContext    The context in which the AppFunction is executed
     * @param title                 The task title. This will be the text shown to the user in the general list of tasks
     * @param description           The optional description of the task. The user will be able to see this text when entering in the task details
     * @param board                 The board where the task will be assigned to. Defaults to "General"
     *
     * @return The created [Task]
     */
    @AppFunction(isDescribedByKdoc = true)
    suspend fun createTask(
        appFunctionContext: AppFunctionContext,
        title: String,
        description: String? = null,
        board: String? = null,
    ): Task = repository.createTask(title, description, board?.toBoard() ?: Board.GENERAL)
}
```

Note que `board` é tipado como `String?` em vez de um enum `Board`. Voltaremos a isso em breve.

### Definindo intents no iOS

AppIntents têm uma forma um pouco diferente. Cada capacidade é sua própria `struct` em conformidade com `AppIntent`, com parâmetros declarados usando o property wrapper `@Parameter`:

```swift
struct CreateTaskIntent: Sendable, AppIntent {
    static var title: LocalizedStringResource = "Create a new task"
    let repository: TaskRepository = DependencyBag.make()

    @Parameter(
        title: "Title",
        description: "The task title. This will be the text shown to the user in the general list of tasks"
    )
    var title: String

    @Parameter(
        title: "Description",
        description: "The optional description of the task. The user will be able to see this text when entering in the task details"
    )
    var description: String?

    @Parameter(
        title: "Board",
        description: "The board where the task will be assigned to. Defaults to \"General\"",
        default: Board.general
    )
    var board: Board

    func perform() async throws -> some ReturnsValue&lt;Task> {
        await .result(value: repository.createTask(title: title, description: description, board: board))
    }
}
```

Mais boilerplate, mas também mais expressivo. Cada intent é autocontido e testável de forma independente.

## Limitações e regras de entrada de dados

É aqui que as duas plataformas divergem de uma forma interessante.

No iOS, o parâmetro `Board` acima é tipado como um enum `Board`, um enum Swift em conformidade com `AppEnum`. Isso significa que a Siri conhece o conjunto exato de valores válidos em tempo de compilação, pode apresentá-los como um seletor e validar a entrada antes de chamar `perform()`. Você tem segurança de tipos do início ao fim.

```swift
enum Board: String, Sendable, AppEnum, Codable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Board")
    static var caseDisplayRepresentations: [Board: DisplayRepresentation] = [
        .general: DisplayRepresentation(title: "General")
    ]

    case general
}
```

No Android, AppFunctions não suportam enums como tipos de parâmetro atualmente. O parâmetro `board` precisa ser uma `String`, e é responsabilidade da função validar e convertê-lo:

```kotlin
@Throws(AppFunctionInvalidArgumentException::class)
fun String.toBoard(): Board = Board.entries.firstOrNull {
    this.equals(it.name, ignoreCase = true)
} ?: throw AppFunctionInvalidArgumentException(
    "The board must be one of ${Board.entries.joinToString(", ") { it.capitalize() }}"
)
```

Funciona, mas empurra a validação para o tempo de execução em vez do tempo de compilação, e as opções válidas precisam ser comunicadas pela descrição KDoc em vez do sistema de tipos. A abordagem da Apple é mais ergonômica aqui.

A mesma lacuna estrutural aparece com o próprio `Task`. No iOS, `Task` é conforme ao protocolo `AppEntity`, tornando-o um objeto de primeira classe que o sistema pode consultar, referenciar por ID e exibir na interface de Atalhos. No Android, `Task` é apenas uma data class simples passada pela assinatura da função.

A Apple vai ainda mais longe na apresentação de respostas. Um AppIntent pode retornar não apenas um valor, mas uma interface personalizada exibida em uma sheet ao conformar seu tipo de retorno com `ShowsSnippetIntent`. O exemplo a seguir foi extraído do artigo da Apple [Displaying static and interactive snippets](https://developer.apple.com/documentation/appintents/displaying-static-and-interactive-snippets):

```swift
struct ClosestLandmarkIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Closest Landmark"
    @Dependency var modelData: ModelData

    func perform() async throws -> some ReturnsValue&lt;LandmarkEntity> & ShowsSnippetIntent {
        let landmark = await self.findClosestLandmark()
        return .result(
            value: landmark,
            snippetIntent: LandmarkSnippetIntent(landmark: landmark)
        )
    }
}
```

Isso permite apresentar uma interface personalizada junto à resposta do assistente, em vez de depender de um resumo em texto simples. AppFunctions no Android atualmente não têm equivalente para isso, com respostas limitadas ao valor de retorno da própria função.

## Integrando com a Siri

Um passo adicional é necessário no iOS sem equivalente direto no Android: você precisa informar à Siri como invocar seus intents por linguagem natural. Isso é feito conformando um tipo com `AppShortcutsProvider` e declarando as frases de ativação:

```swift
struct AppIntentProvider: AppShortcutsProvider, Sendable {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create a new task on \(.applicationName)",
                "Add a new task into the \(\.$board) board on \(.applicationName)"
            ],
            shortTitle: "Create a new task",
            systemImageName: "paperplane.fill"
        )
        AppShortcut(
            intent: ListTasksOnBoardIntent(),
            phrases: [
                "List the tasks on \(\.$board) on \(.applicationName)",
                "Find all tasks on \(.applicationName)'s \(\.$board)"
            ],
            shortTitle: "List Tasks on Board",
            systemImageName: "paperplane.fill"
        )
    }
}
```

A interpolação `\(\.$board)` é particularmente elegante. Ela informa à Siri que esse espaço na frase corresponde ao parâmetro `board`, e a Siri cuidará da desambiguação automaticamente.

AppFunctions no Android não exigem esse tipo de registro explícito de frases. O sistema e o Gemini inferem a invocação a partir das descrições KDoc e das assinaturas das funções em tempo de execução, o que é menos cerimonioso, mas também lhe dá menos controle sobre as frases exatas que os usuários podem usar.

## Testes e depuração

A experiência do desenvolvedor é bastante diferente quando se trata de testar as integrações.

No iOS, o app Atalhos funciona como ferramenta de testes. Seus AppIntents aparecem lá automaticamente assim que o app é instalado, e você pode executar qualquer intent manualmente com controle total sobre cada parâmetro. Isso torna a iteração rápida: não é necessário elaborar frases de voz específicas ou esperar que a Siri reconheça suas alterações. Basta abrir Atalhos, encontrar o intent, preencher os parâmetros e executar.

No Android, não há uma sandbox equivalente. Testar uma AppFunction significa passar pelo Gemini diretamente, o que exige formular uma requisição em linguagem natural de uma forma que leve o assistente a identificar e invocar a função correta. Isso introduz uma camada de imprevisibilidade no ciclo de feedback, já que uma função não ser chamada pode significar que está quebrada, ou simplesmente que o Gemini não a selecionou para aquele prompt específico. Isso torna a depuração mais difícil e lenta em comparação ao iOS.

---

Ambas as plataformas caminham para tornar o seu app um participante de primeira classe em fluxos de trabalho assistidos por IA, sem exigir que você suba um servidor ou implemente MCP. AppIntents e AppFunctions são diferentes em suas APIs e filosofias, mas compartilham a mesma ideia central: descreva o que o seu app pode fazer e deixe o sistema descobrir quando chamá-lo.

A abordagem da Apple é mais madura, com um sistema de tipos mais rico, suporte a respostas com interface e ampla disponibilidade de dispositivos. AppFunctions é mais recente e mais limitado por enquanto, tanto nos recursos que suporta quanto nos dispositivos em que funciona. Dito isso, é uma base promissora. À medida que agentes de IA se tornam uma interface mais comum para usuários no Android, a API provavelmente evoluirá para fechar essas lacunas, e vale a pena se familiarizar com ela desde já.
