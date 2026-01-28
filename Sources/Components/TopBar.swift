//
//  TopBar.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//

import Ignite
import Foundation
import ArkanaKeys

struct TopBar: HTML {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    var body: some HTML {
        NavigationBar(logo: nil) {
            Link(page.dictionary.localised("Home", decoder: decode), target: "/")
            Link(page.dictionary.localised("Categories", decoder: decode), target: Categories())
            Link(page.dictionary.localised("Resume", decoder: decode), target: Resume())
            Link(page.dictionary.localised("GitHub", decoder: decode), target: ArkanaKeys.Global().githubPage)
            Link(page.dictionary.localised("Mastodon", decoder: decode), target: ArkanaKeys.Global().mastodonPage)
            Link(page.dictionary.localised("Feed", decoder: decode), target: "/feed.rss")
            Spacer()
            Link(page.dictionary.localised(page.locale.linkLabel, decoder: decode), target: page.path(in: page.locale.linkTarget))
        }
        .navigationItemAlignment(.leading)
        .navigationBarStyle(.dark)
        .background(.bootstrapRed)
    }
}

private extension Locale {
    static var `default`: Locale {
        Locale(identifier: "en")
    }
    static var alternative: Locale {
        Locale(identifier: "pt")
    }
    var linkLabel: String {
        if self == .default {
            "Ver em Português"
        } else {
            "See in English"
        }
    }
    var linkTarget: Locale {
        if self == .default {
            .alternative
        } else {
            .default
        }
    }
}
