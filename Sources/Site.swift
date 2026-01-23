import Foundation
import Ignite
import ArkanaKeys

@main
struct IgniteWebsite {
    static func main() async {
        var site = ExampleSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ExampleSite: Site {    
    var name = ArkanaKeys.Global().siteName
    var url = URL(string: ArkanaKeys.Global().hostname)!
    var builtInIconsEnabled = true
    var author = ArkanaKeys.Global().authorName

    var homePage = Home()
    var layout = MainLayout()
    
    var articlePages: [any ArticlePage] {
        Story()
    }
    var staticPages: [any StaticPage] {
        Home()
        Categories()
    }
}
