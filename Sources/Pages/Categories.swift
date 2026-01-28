//
//  Categories.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

protocol LocalisedStaticPage: StaticPage {
    var locale: Locale { get }
}

extension LocalisedStaticPage {
    /// Auto-generates a path for this page using its Swift type name.
    var path: String {
        let prefix = if locale == .default { "" } else { "\(locale.identifier)/" }
        return "/" + prefix  + String(describing: Self.self).convertedToSlug()
    }
}

struct Categories: LocalisedStaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    @Environment(\.articles) var articles
    
    let locale: Locale
    
    var map: [String: [Article]] {
        articles.categories(for: locale)
    }
    
    var title: String {
        page.dictionary.localised("Categories", decoder: decode)
    }
    
    init(locale: Locale) {
        self.locale = locale
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
    func typed(_ type: String, locale: Locale) -> [Article] {
        self.in(locale: locale).filter { $0.type == type }
    }

    func tagged(_ tag: String, locale: Locale) -> [Article] {
        self.in(locale: locale).filter { $0.tags?.contains(tag) == true }
    }
    
    func categories(for locale: Locale) -> [String: [Article]] {
        let tags = Set(self.in(locale: locale).flatMap { article in article.tags ?? [] })
        var map = [String: [Article]]()
        tags.forEach { tag in
            map[tag] = tagged(tag, locale: locale)
        }
        return map
    }
}
