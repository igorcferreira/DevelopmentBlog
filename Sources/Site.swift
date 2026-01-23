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
    var robotsConfiguration: DefaultRobotsConfiguration {
        var configuration = DefaultRobotsConfiguration()
        configuration.disallowRules = {
            var items = KnownRobot.allCases.map(DisallowRule.init(robot:))
            items.append(DisallowRule(name: "*"))
            return items
        }()
        return configuration
    }

    var homePage = Home()
    var layout = MainLayout()
    
    var articlePages: [any ArticlePage] {
        Story()
    }
    var staticPages: [any StaticPage] {
        Home()
        Categories()
        Resume()
    }
}
