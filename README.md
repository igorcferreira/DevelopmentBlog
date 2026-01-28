# DevelopmentBlog

This repository contains a project built using the [Ignite static site generator](https://github.com/twostraws/Ignite), 
you should refer to the [IgniteSamples](https://github.com/twostraws/IgniteSamples) repository for detailed code samples.

## Project Overview

Development blog using Ignite (Swift static site generator) that renders Markdown files to static HTML. Hosted on GitHub Pages at igorcferreira.dev.

## Build Commands

```bash
# Install secrets (required before first build)
bundle exec arkana

# Build the project
swift build
swift build -c release

# Generate static site (outputs to Build/)
swift run
swift run -c release

# Local development server (port 8000, opens browser)
./start.sh
./stop.sh --port 8000
```

## Architecture

**Entry Point:** `Sources/Site.swift` - `@main` struct that configures and publishes the site.

**Key Protocols:**
- `Site` - Root configuration (name, URL, author, themes, pages)
- `Layout` - Page container structure (`MainLayout.swift`)
- `StaticPage` - Custom pages (Home, Categories, Resume)
- `ArticlePage` - Auto-generated from Content/ markdown (`Story.swift`)

**Content Flow:**
```
Content/*.md → Ignite parses YAML front matter → Article model → Components → Build/*.html
```

**Directory Purpose:**
- `Sources/Components/` - Reusable UI (TopBar, ArticleContent, ArticleSummary)
- `Sources/Pages/` - Page definitions
- `Sources/Layouts/` - Page wrapper layouts
- `Sources/L10n/` - Localization helper
- `Content/` - Blog post markdown files
- `Build/` - Generated static HTML (git-ignored, deployed to gh-pages)
- `Resources/` - Localizable.strings and Resume.md content
- `keys/ArkanaKeys/` - Generated secrets framework

## Writing Blog Posts

Create markdown files in `Content/` with YAML front matter:

```markdown
---
author: Igor Ferreira
title: Post Title
description: Brief description
date: 2026-01-26 12:00
tags: iOS, SwiftUI, KMP
published: true
---

# Content here...
```

Optional front matter: `image` (featured image path), `path` (custom URL path).

## Configuration

Site configuration uses Arkana for secrets management. Environment variables are transformed into the `ArkanaKeys` Swift framework:
- `Hostname`, `AuthorName`, `SiteName` - Site identity
- `MastodonPage`, `MastodonHandle`, `GithubPage` - Social links

Run `bundle exec arkana` after changing `.arkana.yml` or environment variables.

## Deployment

GitHub Actions workflow (`.github/workflows/deploy.yml`) deploys on push to main:
1. Generates secrets from GitHub environment variables
2. Builds with `swift build -c release`
3. Generates site with `swift run -c release`
4. Pushes `Build/` contents to `gh-pages` branch
