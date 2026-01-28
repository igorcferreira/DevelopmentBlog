//
//  Dictionary.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct Dictionary {
    let locale: Locale
    
    func localised(
        _ key: String,
        decoder: DecodeAction
    ) -> String {
        return localised(String.LocalizationValue(key), decoder: decoder)
    }
    
    func localised(
        decoder: DecodeAction,
        format: String,
        _ arguments: any CVarArg...
    ) -> String {
        return String(format: localised(format, decoder: decoder), arguments: arguments)
    }
    
    func localised(
        _ key: String.LocalizationValue,
        decoder: DecodeAction
    ) -> String {
        guard let url = decoder.url(forResource: "Localizable.bundle") else {
            return "\(key)"
        }
        return String(localized: LocalizedStringResource(
            key,
            locale: locale,
            bundle: .atURL(url)
        ))
    }
}

extension Locale {
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


extension Article {
    var locale: Locale {
        guard let locale = metadata["language"] as? String else {
            return Locale(identifier: "en")
        }
        return Locale(identifier: locale)
    }    
}

extension ArticleLoader {
    func `in`(locale: Locale) -> [Article] {
        all.filter({ article in article.locale == locale })
    }
}

extension PageMetadata {
    var dictionary: Dictionary {
        Dictionary(locale: locale)
    }
    var locale: Locale {
        url.locale
    }
    var path: String {
        url.path()
    }
    func path(in other: Locale) -> String {
        guard other != locale else {
            return path
        }
        var components = url.pathComponents
            .filter({ $0 != "/" })
        if !components.isEmpty && locale != Locale.default {
            _ = components.removeFirst()
        }
        if other != Locale.default {
            components.insert(other.identifier, at: 0)
        }
        return "/\(components.joined(separator: "/"))"
    }
}

extension URL {
    var locale: Locale {
        
        let elements = pathComponents
            .filter({ $0 != "/" })
        guard let firstElement = elements.first else {
            return Locale.default
        }
        
        return if firstElement == Locale.alternative.identifier {
            .alternative
        } else {
            .default
        }
    }
}
