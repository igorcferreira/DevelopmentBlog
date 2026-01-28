---
author: Igor Ferreira
title: StateFlow em KMP e SwiftUI
description: Uma breve reflexão sobre o uso de StateFlow em KMP ao utilizar SwiftUI como frontend para iOS
date: 2026-01-26 12:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
language: pt
---

# StateFlow em KMP e SwiftUI

A maior vantagem do [Kotlin Multiplatform (KMP)](https://kotlinlang.org/docs/multiplatform.html) é a possibilidade de reutilizar a lógica de negócio entre plataformas,
como um framework/módulo separado, mantendo a UI implementada nas bibliotecas nativas
([SwiftUI](https://developer.apple.com/swiftui/) ou [Jetpack Compose](https://developer.android.com/compose)).

Dessa forma, todos os melhores recursos das bibliotecas de UI nativas podem ser utilizados para criar experiências nativas incríveis, sem a necessidade de
duplicar a lógica de negócio, que tende a ser a mesma entre plataformas.
Especialmente ao lidar com requisições/respostas de rede, validação de dados e mapeamento de modelos.

Para a maior parte da lógica de negócio, essa integração é fácil e fluida. Ainda mais considerando que o KMP traduz
coroutines do Kotlin em closures do Objective-C, corretamente estruturadas para serem automaticamente traduzidas em concorrência Swift,
tornando a integração com SwiftUI suave.

O principal problema que resta é: Manutenção de estado.

## Exemplo

Vamos usar um exemplo simples, apenas para avançar a discussão: Uma classe de operação que realiza uma requisição de rede.

Neste exercício de pensamento, a UI nativa passaria o label, que seria usado em uma operação de rede.
No início, estados simples precisariam ser tratados: Loading, Success e Error.

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

## Uso no Android

No Android, o uso dessa operação é bem simples:

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

O `DisposableEffect` nos permite chamar a operação na inserção da view e cancelá-la se/quando a view for removida da
hierarquia. O estado é totalmente controlado pela Operation e a UI reage a essa mudança de estado.

Isso segue os princípios de Clean Architecture de estado e eventos unidirecionais. A UI envia eventos para a
lógica de negócio e a lógica de negócio atualiza um estado. Essa mudança de estado notifica a UI, que reage e
se atualiza conforme necessário.

Lindo.

No iOS, as coisas não são tão fáceis.

## Uso no iOS

Sem modificar a `FooOperation` criada, o mais próximo que pode ser feito no iOS é:

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

E essa implementação tem bugs:

1. `FooOperation.perform()` é síncrono. Ele inicia o job, mas retorna imediatamente. Portanto, o iOS nunca recebe a atualização de estado final.
2. `operation.state.value`, quando traduzido para Swift, perde seu tipo. Então, o iOS é forçado a fazer cast dos tipos.
3. A leitura inicial de `operation.state.value` acontece antes da Operation iniciar, então tem um estado inválido/pausado.

Isso significa que a lógica de negócio real escrita na classe Operation nunca é usada pela UI.
O estado unidirecional é perdido.

Algumas mudanças podem ser feitas para minimizar os bugs, começando pela `FooOperation`:

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

Essa mudança expõe uma suspend fun `FooOperation.execute()`, que é traduzida em Objective-C como uma mensagem baseada em closure,
permitindo a criação de um wrapper de concorrência Swift. E a view SwiftUI pode ser atualizada para:

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

Ao ter acesso à conclusão da função suspend, o estado final da view agora está alinhado com o resultado
da Operation. Mas, bugs ainda estão presentes:

1. `operation.state.value` ainda perde a definição de tipo.
2. A leitura inicial de `operation.state.value` ainda está errada.
3. Como funções `suspend` são convertidas em closures do Objective-C, os limites do CoroutineScope são quebrados.
4. O tratamento de erros é perdido na tradução, forçando o código Swift a usar `try?` ou replicar o tratamento de erros na camada de UI.

E tudo isso fica ainda pior se houver mais estados intermediários na Operation. Por exemplo: Upload de arquivo;
Uma Operation de upload de arquivo pode precisar comprimir o arquivo, iniciar uma sessão de upload, fazer upload do arquivo,
e fechar a sessão no final.

Seria uma boa UX atualizar a UI para todos esses muitos estados intermediários da operação.
Idealmente, o código Swift precisa escutar as mudanças de estado no Flow.

O wrapper async/await apagaria os estados internos.

**Problemas no iOS:**

1. Sem type-safety nos valores de estado.
2. Desassociação do escopo de thread, que impede o código Kotlin de estar ciente de seus threads filhos.
3. Sem acesso às mudanças de estado intermediárias.
4. Tratamento de erros é perdido ou duplicado.

## Pensando em voz alta

Eu não tenho uma solução, por isso proponho este post como um exercício de pensamento.
Mas, eu fiz algo no meu projeto [MusicStreamSync](https://github.com/igorcferreira/MusicStreamSync) que me permitiu
reutilizar a lógica de negócio para gerenciamento de estado e ter a UI reagindo a essas mudanças de estado.

O que listarei abaixo não é a abstração mais bonita, mas é uma forma de nos permitir usar a implementação original da `FooOperation`
enquanto o código iOS escuta as mudanças no state flow.

Uma ferramenta vital para alcançar o objetivo de escutar mudanças de estado no iOS é o projeto [KMP-NativeCoroutines](https://github.com/rickclephas/KMP-NativeCoroutines).

Este plugin Kotlin (e Swift Package) melhora a tradução de `StateFlow` das coroutines Kotlin para Swift.

As 2 principais anotações que melhoram o caso de uso proposto são `@NativeCoroutinesState` e `@NativeCoroutineScope`

- **NativeCoroutinesState**: Expõe o valor do estado como um valor somente leitura type-safe e cria formas de escutar mudanças.
- **NativeCoroutineScope**: Define qual escopo deve ser usado ao criar as traduções async/await.

Os 4 problemas do iOS listados acima serão tratados como:

1. Sem type-safety -> NativeCoroutinesState
2. Desassociação do escopo de thread -> NativeCoroutineScope
3. Sem acesso ao estado intermediário -> NativeCoroutinesState
4. Tratamento de erros perdido ou duplicado -> NativeCoroutineScope

**FooOperation atualizada:**

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

**Código SwiftUI atualizado**

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

`@NativeCoroutinesState` nos permite escrever o método `FooView.observe()` acima. Agora, qualquer mudança de estado é propagada
para a camada de UI, permitindo que a UI reaja às mudanças de estado. Agora:

1. O estado é type-safe, através do acesso direto a `.state`.
2. O escopo de thread é definido através de `@NativeCoroutineScope`. Se o `Task.detached` for cancelado, o `asyncSequence` fecha e se o `Job` for cancelado, o `asyncSequence` termina.
3. Estados intermediários agora são propagados para a camada de UI.
4. O tratamento de erros está vinculado ao estado.

E a mudança de estado unidirecional agora está completa. Nos permitindo reutilizar a lógica de negócio de gerenciamento de estado. Ótimo.

## Abstração ViewModel

SwiftUI também tem a abstração ViewModel (VM), que isola o código de gerenciamento de estado fora da View em si,
tornando mais fácil testar, atualizar e reutilizar. Aplicar um VM nos permite limpar o código acima em algo como:

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

E o método `observe` pode ser abstraído usando Swift Extensions, em algo como:

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

## Nota Final

Como eu disse, este post é mais um exercício de pensamento do que uma proposta de solução. Mas, senti que valia a pena colocar em palavras.

Se você quiser me dar sua opinião, pode me encontrar no [Mastodon](https://mastodon.social/@igorcferreira) ou [BlueSky](https://bsky.app/profile/igorcferreira.bsky.social).
