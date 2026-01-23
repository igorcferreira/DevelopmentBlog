//
//  ArticleSummary.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct ArticleSummary: HTML {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    
    let article: Article
    
    var body: some HTML {
        Text {
            Link(article)
        }
        .font(.title2)
        
        if article.hasTags {
            Text(page.dictionary.localised(
                decoder: decode,
                format: "Tagged with: %@",
                article.tagList
            )).font(.xSmall)
        }
        
        Text(article.description)
            .font(.lead)
    }
}
