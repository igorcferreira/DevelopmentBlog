//
//  Index.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 02/02/2026.
//
import Foundation
import Ignite

struct Index: StaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    var title: String {
        page.dictionary.localised("Home", decoder: decode)
    }
    
    var body: some HTML {
        Script(code: """
            const userLang = navigator.language || navigator.userLanguage;
            const locale = new Intl.Locale(userLang);
            if (locale.language === "pt") {
                window.location.replace("/pt/home");
            } else {
                window.location.replace("/en/home");
            }
            """)
    }
}
