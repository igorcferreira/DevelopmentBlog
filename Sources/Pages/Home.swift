import Foundation
import Ignite

struct Home: LocalisedStaticPage {
    @Environment(\.page) var page
    @Environment(\.decode) var decode
    @Environment(\.articles) var articles
    
    let locale: Locale
    
    var title: String {
        page.dictionary.localised("Home", decoder: decode)
    }
    var avaibleArticles: [Article] {
        articles.in(locale: locale)
    }
    var headArticle: Article? {
        avaibleArticles.first
    }
    var remainingArticles: [Article] {
        var list = avaibleArticles.prefix(6)
        guard list.count > 1 else { return [] }
        let _ = list.removeFirst()
        return Array(list)
    }
    
    init(locale: Locale) {
        self.locale = locale
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
