---
author: Igor Ferreira
title: Using Koin with Kotlin Multiplatform on iOS: A Bridge Approach
description: Showcase of a proposed approach to handle Koin injection in KMP
date: 2026-02-23 14:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
language: en
---

# Using Koin with Kotlin Multiplatform on iOS: A Bridge Approach

## Introduction

I was reading a post made by [Gui Rambo](https://mastodon.social/@_inside) where he demonstrates the usage of [CloudKit for content hosting and feature flags](https://rambo.codes/posts/2021-12-06-using-cloudkit-for-content-hosting-and-feature-flags). In there, he mentions:

> If you'd like to consume the same content that you're hosting on the public CloudKit database from an Android app or from a web app, you can. You can use the CloudKit Web Services API, which lets you do pretty much everything that can be done through the CloudKit framework over HTTP.

And this triggered something in my mind: if CloudKit has an HTTP API, it can be used as a feature flag control in Kotlin Multiplatform solutions.

I put together a quick sample project to validate that idea, and it works. But building it also surfaced a second challenge: a clean architecture has many moving parts, like networking, mappers, repositories, and managers, and wiring them all together cleanly requires solid dependency injection. That realization is what led me here.

---

## Dependency Injection in Kotlin Multiplatform

Dependency management is a cornerstone of a healthy and scalable codebase. In the Android ecosystem, we have mature tools like Hilt and [Koin](https://github.com/InsertKoinIO/koin) that handle this well. Koin in particular is a solid fit for Kotlin Multiplatform: it is lightweight, Kotlin-first, and straightforward to set up in a shared module.

On Android, consuming Koin is seamless. You start it in your `Application` class and inject wherever you need using `by inject()` or `get()`, with `KoinComponent` and Kotlin extension functions working naturally.

On iOS, it is a different story. `KoinComponent` and Kotlin extension functions do not translate cleanly through the Swift/Obj-C bridge, which means you cannot rely on Koin's typical injection mechanisms from the iOS side. You need a way to expose your injected objects to Swift without relying on constructs it does not understand.

---

## A Bridge Approach

One way to handle this is to introduce a `DIHelper` class in your shared module. Its job is to initialize Koin and expose a `KoinBridge`, a plain object that Swift can work with, which provides access to the objects Koin manages. Think of it as a controlled window into your DI graph, purpose-built for the Swift layer.

Here's how that looks in practice:

**Shared**

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

On Android, you initialize Koin the usual way, with platform-specific extras like the Android context:

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

On iOS, instead of working against the bridge, you call `buildBridge()` and pull out what you need directly:

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

Swift receives a clean, strongly-typed object with no Kotlin extensions or `KoinComponent` involved, just a straightforward handoff.

---

## Trade-offs

This pattern is practical, but worth understanding before adopting it.

On the positive side, your DI configuration lives in one place, shared across both platforms. Injection remains centralized and controlled by Koin, the shared layer stays independently testable, and you get a simple managed object pool without any extra infrastructure.

The main friction points are that every object you want to expose to Swift must be explicitly declared in the `KoinBridge`, and there is potential for duplication between Bridge properties and your module definitions, particularly once ViewModels enter the picture.

---

## Wrapping Up

The `DIHelper` / `KoinBridge` pattern is a pragmatic response to a real limitation of the Swift bridge. It keeps dependency injection centralized and the shared logic clean, while remaining accessible from the iOS side. For a project where you want Koin managing your object graph across both platforms, it is a reasonable starting point worth considering.

If you have tackled this differently or found ways to reduce the Bridge boilerplate, feel free to share. This space continues to evolve and there are likely other patterns worth exploring.
