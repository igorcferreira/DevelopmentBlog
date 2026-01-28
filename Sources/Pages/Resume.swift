//
//  Resume.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct Resume: LocalisedStaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    var title: String {
        page.dictionary.localised("Resume", decoder: decode)
    }

    var resource: String {
        "resume_\(page.locale.identifier).md"
    }
    
    let locale: Locale
    
    var body: some BodyElement {
        if let data = decode.data(forResource: resource),
           let content = String(data: data, encoding: .utf8) {
            Text(markdown: content)
        }
    }
}
