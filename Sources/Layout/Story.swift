//
//  File.swift
//  
//
//  Created by Igor Ferreira on 25/05/2024.
//

import Foundation
import Ignite

struct Story: ContentPage {
    func body(content: Content, context: PublishingContext) -> [any BlockElement] {
        Text(content.title)
            .font(.title1)

        if let image = content.image {
            Image(image, description: content.imageDescription)
                .resizable()
                .cornerRadius(20)
                .frame(maxHeight: 300)
                .horizontalAlignment(.center)
        }

        if content.hasTags {
            Group {
                Text("Tagged with: \(content.tags.joined(separator: ", "))")

                Text("\(content.estimatedWordCount) words; \(content.estimatedReadingMinutes) minutes to read.")
            }
        }

        Text(content.body)
    }
}
