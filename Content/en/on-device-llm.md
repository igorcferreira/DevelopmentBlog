---
author: Igor Ferreira
title: Integrating your app functionality into on-device LLMs
description: A description of how Android and iOS enables you to provide your app functionality as MCP-alike tools to on-device LLMs
date: 2026-03-03 14:00
tags: iOS, Android, Gemini, Apple Intelligence
published: true
language: en
---

# Integrating your app functionality into on-device LLMs

On-device AI assistants are becoming first-class citizens on both iOS and Android. Apple Intelligence brings a suite of AI features deeply integrated into the system, while Google's Gemini assistant is increasingly capable of acting across apps on Android. Both platforms now ship with on-device language models that can understand user intent and take action, without a round-trip to the cloud.

That's exciting. But if you're building an app and want those assistants to interact with your features, there's an important constraint worth knowing upfront.

## Apple Intelligence and Gemini assistant

Apple Intelligence is Apple's on-device AI layer, introduced in iOS 18. It powers features like Writing Tools, smart summaries in Mail and Messages, and (most relevant here) a significantly more capable Siri that can understand natural language requests across the system and deep-link into apps.

On Android, Gemini acts as the assistant layer, with Google expanding its ability to understand on-screen context and orchestrate tasks across apps. Gemini can interact with apps in more than one way: AppFunctions is the structured, opt-in approach covered in this post, but Gemini also includes an agentic mode that drives apps through the accessibility API, without any integration work required from the developer. Both assistants are backed, at least in part, by models running locally on-device, giving them speed and privacy advantages over purely cloud-based approaches.

## MCP tools limitations

If you've been following the AI tooling ecosystem, you're probably familiar with the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/), a standard way to expose tools and data sources to LLMs, so they can call into external services during inference.

It's a great pattern. But on-device assistants on iOS and Android don't support injecting arbitrary MCP servers. The models running on these platforms operate in a sandboxed, controlled environment. You can't just point Siri or Gemini at your MCP endpoint and expect it to call your tools.

Instead, both platforms offer their own first-party mechanisms for exactly this purpose, and they work surprisingly well as a conceptual equivalent.

## AppIntent and AppFunctions

Apple's answer is **[AppIntents](https://developer.apple.com/documentation/appintents/appintent)**, a Swift framework introduced in iOS 16 that lets you expose discrete pieces of app functionality to the system. Siri, Shortcuts, Spotlight, and now Apple Intelligence all use AppIntents to understand what your app can do.

Android's answer, more recently, is **[AppFunctions](https://developer.android.com/ai/appfunctions)**, a Jetpack library that follows a similar philosophy: annotate your Kotlin functions, and the system (including Gemini) can discover and invoke them on the user's behalf. AppFunctions require Android 16 or higher, and are currently limited to a small set of supported devices, mainly from Google and Samsung.

Both approaches let you describe capabilities in a structured way that an LLM can reason about. Think of them as typed, discoverable tool definitions, serving the same role MCP tools play in a server-side AI setup.

Here's how a task management app might implement them side by side. The full sample project is available on GitHub, with the [Android code](https://github.com/igorcferreira/KotlinNativeStudies/tree/main/appfunctiondemo/composeApp/src/main/java/dev/igorcferreira/appfunctiondemo/functions) and the [iOS code](https://github.com/igorcferreira/KotlinNativeStudies/tree/main/appfunctiondemo/iosApp/iosApp/Intents) each in their own folder.

### Defining functions on Android

With AppFunctions, you create a class and annotate your methods with `@AppFunction`. The KDoc comment on each function becomes the description the system uses to understand when and how to call it:

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

Notice that `board` is typed as `String?` rather than a `Board` enum. We'll come back to that.

### Defining intents on iOS

AppIntents take a slightly different shape. Each capability is its own `struct` conforming to `AppIntent`, with parameters declared using the `@Parameter` property wrapper:

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

More boilerplate, but also more expressive. Each intent is self-contained and independently testable.

## Data input limitations and rules

Here's where the two platforms diverge in an interesting way.

On iOS, the `Board` parameter above is typed as a `Board` enum, a Swift enum that conforms to `AppEnum`. This means Siri knows the exact set of valid values at compile time, can present them as a picker, and can validate input before ever calling `perform()`. You get type safety all the way through.

```swift
enum Board: String, Sendable, AppEnum, Codable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Board")
    static var caseDisplayRepresentations: [Board: DisplayRepresentation] = [
        .general: DisplayRepresentation(title: "General")
    ]

    case general
}
```

On Android, AppFunctions don't currently support enums as parameter types. The `board` parameter has to be a `String`, and it's the function's responsibility to validate and convert it:

```kotlin
@Throws(AppFunctionInvalidArgumentException::class)
fun String.toBoard(): Board = Board.entries.firstOrNull {
    this.equals(it.name, ignoreCase = true)
} ?: throw AppFunctionInvalidArgumentException(
    "The board must be one of ${Board.entries.joinToString(", ") { it.capitalize() }}"
)
```

It works, but it pushes validation to runtime rather than compile time, and the valid options need to be communicated through the KDoc description rather than the type system. Apple's approach is more ergonomic here.

The same structural gap appears with `Task` itself. On iOS, `Task` conforms to `AppEntity`, a protocol that makes it a first-class object the system can query, reference by ID, and display in Shortcuts UI. On Android, `Task` is just a plain data class passed through the function signature.

Apple also goes a step further with response presentation. An AppIntent can return not just a value, but a custom UI shown in a sheet by conforming its return type to `ShowsSnippetIntent`. The following example is taken from Apple's article [Displaying static and interactive snippets](https://developer.apple.com/documentation/appintents/displaying-static-and-interactive-snippets):

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

This lets you present a tailored view alongside the assistant's response, rather than relying on a plain text summary. AppFunctions on Android currently have no equivalent for this, with responses limited to the return value of the function itself.

## Integrating Siri

One more step is required on iOS that has no direct equivalent on Android: you need to tell Siri how to invoke your intents through natural language. This is done by conforming a type to `AppShortcutsProvider` and declaring the trigger phrases:

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

The `\(\.$board)` interpolation is particularly nice. It tells Siri that this slot in the phrase corresponds to the `board` parameter, and Siri will handle disambiguation automatically.

Android's AppFunctions don't require this kind of explicit phrase registration. The system and Gemini infer invocation from the KDoc descriptions and function signatures at runtime, which is less ceremonial but also gives you less control over the exact phrasing users can use.

## Testing and debugging

The developer experience differs quite a bit when it comes to testing your integrations.

On iOS, the Shortcuts app doubles as a testing tool. Your AppIntents show up there automatically once the app is installed, and you can run any intent manually with full control over each parameter. This makes iteration fast: you don't need to craft specific voice phrases or wait for Siri to pick up your changes, you can just open Shortcuts, find the intent, fill in the parameters, and run it.

On Android, there's no equivalent sandbox. Testing an AppFunction means going through Gemini directly, which requires phrasing a natural language request in a way that leads the assistant to identify and invoke the right function. That introduces a layer of unpredictability into the feedback loop, since a function not being called might mean it's broken, or it might just mean Gemini didn't select it for that particular prompt. This makes debugging harder and slower compared to iOS.

---

Both platforms are moving toward letting your app be a first-class participant in AI-assisted workflows, without requiring you to stand up a server or implement MCP. AppIntents and AppFunctions are different in their APIs and philosophy, but they share the same core idea: describe what your app can do, and let the system figure out when to call it.

Apple's approach is more mature, with a richer type system, UI response support, and broad device availability. AppFunctions is newer and more constrained for now, both in the features it supports and the devices it runs on. That said, it's a compelling foundation. As AI agents become a more common interface for users on Android, the API will likely evolve to close those gaps, and it's worth getting familiar with it early.
