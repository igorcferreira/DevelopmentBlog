---
author: Igor Ferreira
title: StateFlow on KMP and SwiftUI
description: A brief thought about the usage of StateFlow on KMP when using SwiftUI as frontend for iOS
date: 2026-01-26 12:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
---

# StateFlow on KMP and SwiftUI

The greatest feature with [Kotlin Multiplatform (KMP)](https://kotlinlang.org/docs/multiplatform.html) is the possibility to re-use the business logic between platforms, 
as a separate framework/module while keeping the UI implemented in the native libraries 
([SwiftUI](https://developer.apple.com/swiftui/) or [Jetpack Compose](https://developer.android.com/compose)).

This way, all the greatest features of the native UI libraries can be used to create amazing native UI/UX with no need to 
duplicate the business logic which tends to be the same between platforms. 
Especially when handling Network requests/responses, data validation and model mapping.

For most of the business logic, this integration is easy and smooth. Even more given that KMP translates Kotlin 
coroutines into Objective-C closures, correctly layered so it can be auto-translated into Swift concurrency, 
making the integration with SwiftUI smooth.

The main problem left is: State maintenance.

## Example

Let's use a simple example, just to move the debate: An operation class which performs a network request.

In this thought exercise, the native UI would pass the label, which would be used in a network operation.
At the start, simple states would need to be handled: Loading, Success and Error.

```kotlin
class FooOperation(
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
    private val networkOperation: suspend () -> String = { "Hello World!" }
) {
    sealed class State {
        object None: State()
        object Loading : State()
        data class Error(
            val message: String
        ) : State()
        data class Success(
            val greeting: String
        ) : State()
    }

    private val _state: MutableStateFlow&lt;State> = MutableStateFlow(State.None)
    val state: StateFlow&lt;State> get() = _state.asStateFlow()

    fun perform() = coroutineScope.launch {
        try {
            _state.update { State.Loading }
            //Simulate a network request
            val response = networkOperation()
            _state.update { State.Success(greeting = response) }
        } catch (e: Throwable) {
            _state.update { State.Error(e.message.orEmpty()) }
        }
    }
}
```

## Android usage

On Android, the usage of this operation is really simple:

```kotlin
@Composable
fun Foo(
    operation: FooOperation,
    modifier: Modifier = Modifier,
) {
    val state by operation.state.collectAsStateWithLifecycle()
    DisposableEffect(operation) {
        val job = operation.perform()
        onDispose { job.cancel() }
    }
    fun errorState() = state as FooOperation.State.Error
    fun successState() = state as FooOperation.State.Success

    Box(modifier = modifier) {
        when (state) {
            is FooOperation.State.None -> {
                Text("Starting")
            }

            is FooOperation.State.Loading -> {
                Text("Loading...")
            }

            is FooOperation.State.Error -> {
                Text("Error: ${errorState().message}")
            }

            is FooOperation.State.Success -> {
                Text("Success: ${successState().greeting}")
            }
        }
    }
}
```

The `DisposableEffect` allows us to call the operation on view placement and cancel it if/when the view is removed from
the hierarchy. The state is fully controlled by the Operation and the UI reacts to this state change.

This follows the principles of Clean Architecture of uni-directional state and events. The UI sends events into the 
business logic and the business logic updates a state. This state changes notifies the UI, which reacts to it and 
updates accordingly.

Beautiful.

On iOS, things are not so easy.

## iOS usage

Without modifying the created `FooOperation`, the closest that can be done on iOS is:

```swift
struct FooView: View {
    let operation: FooOperation
    @State var state: FooOperation.State

    init(operation: FooOperation) {
        self.operation = operation
        self._state = .init(initialValue: operation.state.value as! FooOperation.State)
    }

    var body: some View {
        Group {
            if (state is FooOperation.StateLoading) {
                Text("Loading...")
            } else if let error = state as? FooOperation.StateError {
                Text("Error: \(error.message)")
            } else if let success = state as? FooOperation.StateSuccess {
                Text("Success: \(success.greeting)")
            } else {
                Text("Starting")
            }
        }
        .padding()
        .task { await load() }
    }

    func load() async {
        self.state = operation.state.value as! FooOperation.State
        let job = operation.perform()
        self.state = operation.state.value as! FooOperation.State
    }
}
```

And this implementation has bugs:

1. `FooOperation.perform()` is synchronous. It starts the job, but it returns straight away. So, iOS never receives the final state update.
2. `operation.state.value`, when translated into Swift, loses its type. So, iOS is forced to cast the types.
3. The initial read of `operation.state.value` happens before the Operation starts, so it has an invalid/paused state.

This means the actual business logic written in the Operation class is never used by the UI.
The uni-directional state is lost.

Some changes can be done to minimise the bugs, starting with the `FooOperation`:

```kotlin
suspend fun execute() {
    try {
        _state.update { State.Loading }
        //Simulate a network request
        val response = networkOperation()
        _state.update { State.Success(greeting = response) }
    } catch (e: Throwable) {
        _state.update { State.Error(e.message.orEmpty()) }
    }
}

fun perform() = coroutineScope.launch {
    execute()
}
```

This change exposes a suspend fun `FooOperation.execute()`, which is translated into Objective-C as a closure based message,
allowing the creation of a swift concurrency wrapper. And the SwiftUI view can be updated into:

```swift
struct FooView: View {
    let operation: FooOperation
    @State var state: FooOperation.State

    init(operation: FooOperation) {
        self.operation = operation
        self._state = .init(initialValue: operation.state.value as! FooOperation.State)
    }

    var body: some View {
        Group {
            if (state is FooOperation.StateLoading) {
                Text("Loading...")
            } else if let error = state as? FooOperation.StateError {
                Text("Error: \(error.message)")
            } else if let success = state as? FooOperation.StateSuccess {
                Text("Success: \(success.greeting)")
            } else {
                Text("Starting")
            }
        }
        .padding()
        .task { await load() }
    }

    func load() async {
        self.state = operation.state.value as! FooOperation.State
        try? await operation.execute()
        self.state = operation.state.value as! FooOperation.State
    }
}
```

By having access to the suspend function completion, the final state of the view is now aligned with the result
of the Operation. But, bugs are still present:

1. `operation.state.value` still loses type definition.
2. The initial read of `operation.state.value` is still wrong.
3. Since `suspend` functions are converted into Objective-C closures, the CoroutineScope limits are broken.
4. Error handling is lost in translation, forcing the Swift code to use `try?` or replicate error handling in the UI layer.

And all of this gets even worse if there is more intermediate states in the Operation. For example: File upload;
A file upload Operation may need to compress the file, start an upload session, upload the file,
and close the session at the end.

It would be a good UX to update the UI for all these many intermediary states of the operation. 
Ideally, Swift code needs to listen to state changes in the Flow.

The async/await wrapper would erase the inner states.

**iOS issues:**

1. No type-safety in the state values.
2. Thread scope disassociation, which prevents Kotlin code from being aware of its threads children.
3. No access the intermediary state changes.
4. Error handling is lost or duplicated.

## Thinking out loud

I do not have a solution, that is why I propose this post a thought exercise. 
But, I did something in my [MusicStreamSync](https://github.com/igorcferreira/MusicStreamSync) project which allowed
me to re-use the business logic for state handling and having the UI reacting to these state changes.

What I'll list below is not the most beautiful abstraction, but it is a way to allow us to use the original `FooOperation` 
implementation while having the iOS code listening to changes in the state flow.

A vital tool in achieving the goal of listening to state changes in iOS is the [KMP-NativeCoroutines](https://github.com/rickclephas/KMP-NativeCoroutines) project.

This Kotlin plugin (and Swift Package) enhances the translation of `StateFlow` from Kotlin coroutines into Swift.

The 2 main annotations which improve the proposed use-case are `@NativeCoroutinesState` and `@NativeCoroutineScope`

- **NativeCoroutinesState**: Exposes the state value as a type-safe read-only value and creates ways to listen to changes.
- **NativeCoroutineScope**: Defines which scope must be used when creating the async/await translations.

The 4 iOS issues listed above will be handled as:

1. No type-safety -> NativeCoroutinesState
2. Thread scope disassociation -> NativeCoroutineScope
3. No access to the intermediary state -> NativeCoroutinesState
4. Error handling is lost or duplicated -> NativeCoroutineScope

**Updated FooOperation:**

```kotlin
class FooOperation(
    @NativeCoroutineScope
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
    private val networkOperation: suspend () -> String = { "Hello World!" }
) {
    sealed class State {
        object None: State()
        object Loading : State()
        data class Error(
            val message: String
        ) : State()
        data class Success(
            val greeting: String
        ) : State()
    }

    private val _state: MutableStateFlow&lt;State> = MutableStateFlow(State.None)
    @NativeCoroutinesState
    val state: StateFlow&lt;State> get() = _state.asStateFlow()

    fun perform() = coroutineScope.launch {
        try {
            _state.update { State.Loading }
            //Simulate a network request
            val response = networkOperation()
            _state.update { State.Success(greeting = response) }
        } catch (e: Throwable) {
            _state.update { State.Error(e.message.orEmpty()) }
        }
    }
}
```

**Updated SwiftUI code**

```swift
struct FooView: View {
    let operation: FooOperation
    @State var state: FooOperation.State

    init(operation: FooOperation) {
        self.operation = operation
        self._state = .init(initialValue: operation.state)
        self.observe()
    }

    var body: some View {
        Group {
            if (state is FooOperation.StateLoading) {
                Text("Loading...")
            } else if let error = state as? FooOperation.StateError {
                Text("Error: \(error.message)")
            } else if let success = state as? FooOperation.StateSuccess {
                Text("Success: \(success.greeting)")
            } else {
                Text("Starting")
            }
        }
        .padding()
        .task { await load() }
    }

    func observe() {
        Task.detached {
            let flow = await operation.stateFlow
            let sequence = asyncSequence(for: flow)
            for try await output in sequence {
                await update(state: output)
            }
        }
    }
    
    func update(state: FooOperation.State) {
        self.state = state
    }
    
    func load() async {
        operation.perform()
    }
}
```

`@NativeCoroutinesState` allows us to write the `FooView.observe()` method above. Now, any change of state is propagated 
into the UI layer, allowing the UI to react to state changes. Now:

1. State is type-safe, through the direct access to `.state`.
2. Thread scope is defined through `@NativeCoroutineScope`. If the `Task.detached` is cancelled, the `asyncSequence` closes and if the `Job` is cancelled, the `asyncSequence` terminates.
3. Intermediary states are now propagated into the UI layer.
4. Error handling is bound to the state.

And the uni-directional state change is now complete. Allowing us to re-use the state management business logic. Great.

## ViewModel abstraction

SwiftUI also has the ViewModel (VM) abstraction, which isolates the state management code out from the View itself, 
making it easier to test, update and re-use. Applying a VM allows us to clean up the code above into something like:

```swift
@Observable
class FooViewModel {
    private let operation: FooOperation
    var state: FooOperation.State
    
    init(operation: FooOperation) {
        self.operation = operation
        self.state = operation.state
    }
    
    func observe() {
        Task.detached {
            let flow = self.operation.stateFlow
            let sequence = asyncSequence(for: flow)
            for try await output in sequence {
                self.state = output
            }
        }
    }
    
    func start() {
        operation.perform()
    }
}

struct FooView: View {
    @State var vm: FooViewModel
    var state: FooOperation.State {
        vm.state
    }

    init(operation: FooOperation) {
        self.vm = .init(operation: operation)
    }

    var body: some View {
        Group {
            if (state is FooOperation.StateLoading) {
                Text("Loading...")
            } else if let error = state as? FooOperation.StateError {
                Text("Error: \(error.message)")
            } else if let success = state as? FooOperation.StateSuccess {
                Text("Success: \(success.greeting)")
            } else {
                Text("Starting")
            }
        }
        .padding()
        .task { vm.observe() }
    }
}
```

And the `observe` method can be abstracted using Swift Extensions, into something like:

```swift
extension Observable where Self: AnyObject {
    func collect&lt;Output, Failure: Error>(
        _ flow: @escaping NativeFlow&lt;Output, Failure, KotlinUnit>,
        into path: ReferenceWritableKeyPath&lt;Self, Output>
    ) {
        Task.detached { [weak self] in
            let sequence = asyncSequence(for: flow)
            for try await output in sequence {
                Task.detached { @MainActor in
                    self?[keyPath: path] = output
                }
            }
        }
    }
}

@Observable
class FooViewModel {
    private let operation: FooOperation
    var state: FooOperation.State

    init(operation: FooOperation) {
        self.operation = operation
        self.state = operation.state

        collect(operation.stateFlow, into: \.state)
    }

    func start() {
        operation.perform()
    }
}
```

## Final Note

As I said, this post is more a thought exercise than a solution proposal. But, I felt that it was worth to be put into words.

If you want to give me your opinion, you can find me on [Mastodon](https://mastodon.social/@igorcferreira) or [BlueSky](https://bsky.app/profile/igorcferreira.bsky.social).
