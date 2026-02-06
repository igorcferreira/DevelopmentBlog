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
            Link(page.dictionary.localised("Home", decoder: decode), target: Home(locale: page.locale))
            Link(page.dictionary.localised("Categories", decoder: decode), target: Categories(locale: page.locale))
            Link(page.dictionary.localised("Resume", decoder: decode), target: Resume(locale: page.locale))
            Link(page.dictionary.localised("GitHub", decoder: decode), target: ArkanaKeys.Global().githubPage)
                .target(.blank)
            Link(page.dictionary.localised("Mastodon", decoder: decode), target: ArkanaKeys.Global().mastodonPage)
                .target(.blank)
            Link(page.dictionary.localised("Feed", decoder: decode), target: "/feed.rss")
                .target(.blank)
            Spacer()
            Link(page.dictionary.localised(page.locale.linkLabel, decoder: decode), target: page.path(in: page.locale.linkTarget))
        }
        .navigationItemAlignment(.leading)
        .navigationBarStyle(.dark)
        .background(.bootstrapRed)
    }
}
