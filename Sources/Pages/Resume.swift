//
//  Resume.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct Resume: StaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    var title: String {
        page.dictionary.localised("Resume", decoder: decode)
    }

    let resource: String
    
    init(resource: String = "Resume.md") {
        self.resource = resource
    }
    
    var body: some BodyElement {
        if let data = decode.data(forResource: resource),
           let content = String(data: data, encoding: .utf8) {
            Text(markdown: content)
        }
    }
}
