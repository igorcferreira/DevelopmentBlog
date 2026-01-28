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

struct BaseTheme: Theme {
    var colorScheme: ColorScheme = .light // or .dark
    // Override any theme properties you want to customize
    var syntaxHighlighterTheme: HighlighterTheme = .githubDark
    var accent: Color { Color(hex: "#FF0000") }
    var secondaryAccent: Color { Color(hex: "#00FF00") }
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

    var homePage = Home(locale: Locale.default)
    var layout = MainLayout()
    var lightTheme: (any Theme)? = BaseTheme()
    var darkTheme: (any Theme)? = nil
    
    var articlePages: [any ArticlePage] {
        Story()
    }
    var staticPages: [any StaticPage] {
        let pages: [any StaticPage] = [Locale.default, .alternative].flatMap({ locale in
            [
                Home(locale: locale) as any StaticPage,
                Categories(locale: locale) as any StaticPage,
                Resume(locale: locale) as any StaticPage
            ]
        })
        return pages
    }
    var syntaxHighlighterConfiguration: SyntaxHighlighterConfiguration {
        SyntaxHighlighterConfiguration(languages: [
            .swift,
            .kotlin
        ])
    }
}
