import Foundation
import Ignite
import ArkanaKeys

struct MainLayout: Layout {
    @Environment(\.site) var site
    
    var body: some Document {
        Head {
            MetaLink(href: URL(static: "/apple-touch-icon-precomposed.png"), rel: "apple-touch-icon")
            if let me = URL(string: ArkanaKeys.Global().mastodonPage) {
                MetaLink(href: me, rel: "me")
            }
            MetaTag(name: "apple-mobile-web-app-title", content: site.name)
            MetaTag(name: "fediverse:creator", content: ArkanaKeys.Global().mastodonHandle)
        }
        
        Body {
            TopBar()
            content
            IgniteFooter()
        }
    }
}
