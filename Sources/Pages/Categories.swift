//
//  Categories.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct Categories: StaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    @Environment(\.articles) var articles
    
    var map: [String: [Article]] {
        articles.categories(for: page.locale)
    }
    
    var title: String {
        page.dictionary.localised("Categories", decoder: decode)
    }
    
    var body: some BodyElement {
        Accordion(map.keys, content: { key in
            Item(key, startsOpen: true) {
                Card {
                    List {
                        ForEach(map[key] ?? []) { article in
                            Link(article)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        })
    }
}

extension ArticleLoader {
    func categories(for locale: Locale) -> [String: [Article]] {
        let tags = Set(all.flatMap({ $0.tags ?? [] }))
        var map = [String: [Article]]()
        tags.forEach { tag in
            map[tag] = tagged(tag)
        }
        return map
    }
}
