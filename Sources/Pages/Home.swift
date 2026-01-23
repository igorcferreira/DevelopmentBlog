import Foundation
import Ignite

struct Home: StaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    @Environment(\.articles) var articles
    
    var title: String {
        page.dictionary.localised("Home", decoder: decode)
    }
    
    var headArticle: Article? {
        articles.all.first
    }
    var remainingArticles: [Article] {
        var list = articles.all.prefix(6)
        let _ = list.removeFirst()
        return Array(list)
    }

    var body: some HTML {
        
        if let headArticle {
            Card {
                ArticleContent(article: headArticle)
            }
        }
        
        if (!remainingArticles.isEmpty) {
            Accordion {
                Item(page.dictionary.localised("More", decoder: decode), startsOpen: true) {
                    ForEach(remainingArticles) { article in
                        Card {
                            ArticleSummary(article: article)
                        }
                    }
                }
            }
        }
    }
}

extension Article {
    var hasTags: Bool {
        !(tags?.isEmpty ?? true)
    }
    var tagList: String {
        tags?.joined(separator: ", ") ?? ""
    }
}
