import Foundation
import Ignite
import ArkanaKeys

struct MainLayout: Layout {
    @Environment(\.site) var site
    
    var body: some Document {
        Head {
            MetaLink(href: "/css/sidebar.css", rel: .stylesheet)
            MetaLink(href: "/css/prism-default-dark.css", rel: .stylesheet)
            Script(file: URL(string: "/script/theme.js")!)
            Script(file: URL(string: "/script/syntax-highlighting.js")!)
            MetaLink(href: URL(string: "/apple-touch-icon-precomposed.png")!, rel: "apple-touch-icon")
            MetaLink(href: URL(string: ArkanaKeys.Global().mastodonPage)!, rel: "me")
            MetaTag(name: "apple-mobile-web-app-title", content: site.name)
            MetaTag(name: "fediverse:creator", content: ArkanaKeys.Global().mastodonHandle)
        }
        
        Body {
            TopBar()
                .padding(.bottom, 20)
            content
            IgniteFooter()
        }
    }
}
