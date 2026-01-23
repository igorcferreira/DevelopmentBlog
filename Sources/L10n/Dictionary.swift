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
