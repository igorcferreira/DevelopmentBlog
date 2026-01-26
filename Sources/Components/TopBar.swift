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
        }
        .navigationItemAlignment(.leading)
        .navigationBarStyle(.dark)
        .background(.bootstrapRed)
    }
}

extension PageMetadata {
    var dictionary: Dictionary {
        Dictionary(locale: locale)
    }
    var locale: Locale {
        url.locale
    }
}

extension URL {
    var locale: Locale {
        return if pathComponents.count > 1 {
            Locale(identifier: pathComponents[1])
        } else {
            Locale(identifier: "en")
        }
    }
}
