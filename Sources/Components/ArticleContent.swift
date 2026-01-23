//
//  ArticleContent.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct ArticleContent: HTML {
    @Environment(\.page) var page
    @Environment(\.decode) var decode

    let article: Article
    
    var body: some HTML {
        Text(article.title)
            .font(.title1)

        if let image = article.image {
            Image(image, description: article.imageDescription)
                .resizable()
                .cornerRadius(20)
                .frame(maxHeight: 300)
                .horizontalAlignment(.center)
        }
        
        if article.hasTags {
            Group {
                Text(page.dictionary.localised(
                    decoder: decode,
                    format: "Tagged with: %@",
                    article.tagList
                ))
                Text(page.dictionary.localised(
                    decoder: decode,
                    format: "%d words; %d minutes to read",
                    article.estimatedWordCount,
                    article.estimatedReadingMinutes
                ))
            }
        }
        
        Text(article.text)
            .font(.body)
    }
}
