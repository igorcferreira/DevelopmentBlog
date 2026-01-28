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
        _ = components.removeFirst()
        if (other != Locale(identifier: "en")) {
            components.insert(other.identifier, at: 0)
        }
        return "/\(components.joined(separator: "/"))"
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
