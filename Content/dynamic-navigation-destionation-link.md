---
author: Igor Ferreira
title: Using DynamicNavigationDestinationLink
description: A glance on the usage of DynamicNavigationDestinationLink
date: 2019-06-28 12:00
tags: iOS, SwiftUI
published: true
---
# Using DynamicNavigationDestinationLink

Because of a [thread on Twitter](https://twitter.com/thwittem/status/1143272885588549632), I created this [simple gist](https://gist.github.com/igorcferreira/b302ea59830ce1a3ee2558fa996505ea) with an attempt to simulate the use of DynamicNavigationDestinationLink to display a content fetched from an external source, it may be useful for you on trying to find a solution for your crashes.

```swift
import SwiftUI
import PlaygroundSupport

struct RootView: View {
    var body: some View {
        NavigationView {
            MainView()
        }
    }
}

struct MainView: View {
    
    let destination = DynamicNavigationDestinationLink(id: \String.self) { state in
        SecondaryView(input: state)
    }
    @State var loading: Bool = false
    
    var body: some View {
        VStack {
            Text(loading ? "Loading" : "Main View")
            if !loading {
                Button(action: self.navigate) {
                    Text("Random number")
                }
            }
        }
    }
    
    func navigate() {
        self.loading = true
        let number = (1...100).randomElement() ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.loading = false
            self.destination.presentedData?.value = "\(number)"
        }
    }
}

struct SecondaryView: View {
    @State var input: String
    
    var body: some View {
        Text(input)
    }
}

PlaygroundPage.current.liveView = UIHostingController(rootView: RootView())
PlaygroundPage.current.needsIndefiniteExecution = true
```

P.s.: It is as a Playground because I prefer this way to test/run SwiftUI on Mojave.
