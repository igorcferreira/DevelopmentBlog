//
//  EmptyPageLayout.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 02/02/2026.
//
import Foundation
import Ignite
import ArkanaKeys

struct EmptyPageLayout: Layout {
    @Environment(\.site) var site
    
    var body: some Document {
        Head {
            MetaLink(href: URL(static: "/apple-touch-icon-precomposed.png"), rel: "apple-touch-icon")
            if let me = URL(string: ArkanaKeys.Global().mastodonPage) {
                MetaLink(href: me, rel: "me")
            }
            MetaTag(name: "apple-mobile-web-app-title", content: site.name)
            MetaTag(name: "fediverse:creator", content: ArkanaKeys.Global().mastodonHandle)
        }
        
        Body {
            content
        }
    }
}
