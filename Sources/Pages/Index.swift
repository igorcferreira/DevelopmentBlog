//
//  Index.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 02/02/2026.
//
import Foundation
import Ignite

struct Index: StaticPage {
    typealias LayoutType = EmptyPageLayout
    
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    var layout: EmptyPageLayout = EmptyPageLayout()
    
    var title: String {
        page.dictionary.localised("Home", decoder: decode)
    }
    
    var body: some HTML {
        Script(code: """
            const userLang = navigator.language || navigator.userLanguage;
            const locale = new Intl.Locale(userLang);
            if (locale.language === "\(Locale.alternative.identifier)") {
                window.location.replace("/\(Locale.alternative.identifier)/home");
            } else {
                window.location.replace("/\(Locale.default.identifier)/home");
            }
            """)
    }
}
