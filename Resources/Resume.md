# [Resume](https://www.linkedin.com/in/igorcferreira/)

## About

I'm a mobile developer focused on building apps that people enjoy using. Over 15+ years in software development (with 10+ of those focused on iOS and Android), I've had the chance to work on everything from ride-hailing apps to real estate platforms to fintech products.

These days, I spend most of my time with Swift and SwiftUI on iOS, and Kotlin with Jetpack Compose on Android. I also use Kotlin Multiplatform for sharing code across platforms. When projects call for it, I've built server-side features using Kotlin and Spring Framework. This full-stack perspective helps me think beyond just the mobile layer.

Beyond writing code, I've grown into a Platform Leader role: mentoring developers, shaping technical direction, and helping teams ship quality work on both platforms. I care deeply about clean architecture, performance, accessibility, localization, and creating smooth user experiences.

## Experience

### Future Workshops

- Role: Senior Mobile Developer & Platform Leader
- Location: London, England, United Kingdom
- Start: September 2015
- End: March 2026

At Future Workshops I've grown from Senior Mobile Developer into a Platform Leader. I build iOS apps with Swift and SwiftUI, and Android apps with Kotlin and Jetpack Compose, serving startups and established companies around the world. Server-side development with Kotlin and Spring Framework is also part of my toolkit, which lets me deliver features end-to-end when needed.

A highlight of my work here has been integrating AI capabilities into mobile apps (chatbots, LLM-powered data processing, and image recognition), bringing intelligent features that improve user experiences.

As Platform Leader, I guide technical decisions across iOS and Android, mentor developers at various levels, and help shape how our teams approach mobile architecture. I run code reviews, lead technical discussions, and work to create an environment where developers can grow while delivering their best work. Seeing teammates advance their skills and take on bigger challenges is one of the most rewarding aspects of the role.

### App Rail

- Role: Senior Mobile Developer & Platform Lead
- Location: Remote
- Start: January 2022
- End: July 2025

At App Rail, I worked as both architect and developer. I helped design the architecture for native SDKs on both iOS (Swift) and Android (Kotlin), then built them. The iOS SDK leverages SwiftUI for modern UI components, while the Android SDK uses Jetpack Compose, ensuring both feel native and performant.

The SDK connects to a remote server to power a "no-code" app development approach. Through the App Rail portal, users design app flows using visual UI blocks, and our native SDK brings those designs to life with server-driven features. This approach makes app development more accessible to non-developers.

As Platform Lead, I guided technical decisions across both mobile platforms, ensured consistency in how we approached problems, and mentored team members on best practices. My focus was making sure the SDK was easy to integrate and use.

### 99 Táxis

- Role: Mobile Developer
- Location: São Paulo, Brazil
- Start: April 2015
- End: September 2015

I worked on both sides of a ride-hailing platform: the passenger app (for requesting car and taxi rides) and the driver app (for receiving and managing requests in real time). Delivering a smooth, responsive UI/UX was key. When users are under real-world pressure, every second counts.

I also developed companion apps for Apple Watch and Android Wear, which were emerging platforms at the time. These wearable apps let passengers check ride status and ETAs at a glance. Distilling complex information into minimal, glanceable interfaces required a thoughtful approach.

Building both phone and wearable apps gave me a strong appreciation for how different user experiences need to coordinate seamlessly within the same ecosystem. When a passenger taps "request," the driver sees it instantly, and that sync needs to be fast and reliable.

### Zap Imóveis

- Role: Mobile Developer
- Location: São Paulo, Brazil
- Start: October 2013
- End: March 2015

I built iOS and Android apps for one of Brazil's largest real estate platforms, helping users find homes to rent or buy. UI/UX was central to this work. Property search involves complex filters, map interactions, and image-heavy listings. Everything needed to feel fast and responsive.

I also developed early apps for Apple Watch and Android Wear. Users could browse saved properties and receive alerts from their wrist. Working with these emerging wearable platforms meant designing for constraints: tiny screens, limited interaction patterns, and the need to surface the right information instantly.

One feature I'm proud of: letting users draw directly on a map to define custom search boundaries. Instead of rigid filters, people could circle exactly where they wanted to live. A simple touch that made property hunting feel more personal and natural.

## Skills

**Mobile Development**
- iOS: Swift, SwiftUI, UIKit
- Android: Kotlin, Jetpack Compose
- Cross-platform: Kotlin Multiplatform

**Backend & Infrastructure**
- Kotlin, Spring Framework
- CI/CD pipeline design
- SDK architecture

**Specializations**
- Platform leadership & mentoring
- AI/LLM integration
- AR/VR (Unity, RealityKit, visionOS)
- Real-time communication (WebRTC, XMPP)

## Featured Projects

### IBM Automation Mobile Capture SDK

**Time Period:** September 2015 – June 2021
**Platforms:** iOS and Android
**Role:** Senior Mobile Developer

**Technologies:**
- iOS: Swift, UIKit, Vision Framework (OCR, edge detection), OpenCV, CoreData
- Android: Kotlin, Fragment/Activity architecture, OpenCV (OCR, edge detection), SQLite

Built native SDKs for iOS and Android that enable document scanning and data extraction. The SDK uses real-time edge detection to identify documents (passports, national IDs, A4 documents, receipts) within the camera frame. It captures high-quality images and extracts structured data using OCR, including MRZ parsing for travel documents.

Designed the SDK architecture and CI/CD pipeline. This made it easy for developers to integrate document capture into their apps connecting to IBM's automation platform. The SDK supports configurable scanning scenarios, allowing clients to define which document types and data fields to capture.

Accessibility was a core requirement. The SDK provides audio hints to guide users in positioning documents correctly. Localized for multiple languages including English, Japanese, Chinese, German, and Portuguese. All synchronized data is stored securely on-device using CoreData (iOS) and SQLite (Android) for offline support.

This was my first project at Future Workshops, spanning six years of development and iteration.

### STC Chat SDK

**Time Period:** January 2019 – April 2020
**Platforms:** iOS and Android
**Role:** Senior Mobile Developer

**Technologies:**
- General: XMPP protocol, WebRTC, Firebase Cloud Messaging
- iOS: Swift, UIKit, CoreData, CallKit, Background Tasks
- Android: Kotlin, Fragment/Activity architecture, SQLite, InCall Service, Background Tasks

Built a chat and calling SDK integrated into STC's suite of apps (STC Business, MySTC, STC Hub), serving users across Saudi Arabia's largest telecommunications provider. The SDK enables real-time messaging with support for text, images, documents, and video. Voice and group calls are powered by WebRTC.

Designed the SDK architecture and CI/CD pipeline for both platforms. On iOS, I integrated CallKit with Firebase Cloud Messaging to enable incoming call notifications even when the app is closed. On Android, I implemented InCall Service for a native calling experience. The XMPP protocol handles message delivery and presence, while WebRTC powers peer-to-peer and group voice communication.

All messages are stored locally (CoreData on iOS, SQLite on Android) and synced in the background, ensuring users have access to their conversations offline.

### XMPPColibri

**Time Period:** January 2019 – April 2020
**Platform:** iOS
**Role:** Senior Mobile Developer

**Technologies:**
- Swift, XMPP, WebRTC, Jitsi, Colibri protocol, Docker

Developed an iOS framework that simplifies WebRTC audio and video calling integration via XMPP. The framework abstracts the complexity of the Jitsi/Colibri protocol. This makes it straightforward to add voice and video calling to iOS apps with CallKit support.

Built initially as an internal tool to support the STC Chat SDK. The framework handles room creation, joining conferences, and managing WebRTC connections. For security, XMPP rooms used during the signaling phase are automatically deleted once calls are established. This ensures calls are peer-to-peer with no server participation in the actual communication.

Designed the SDK architecture and led its development. Currently being rewritten with SwiftUI and Swift Concurrency.

### App Rail SDK

**Time Period:** January 2022 – July 2025
**Platforms:** iOS and Android
**Role:** Senior Mobile Developer & Platform Lead

**Technologies:**
- iOS: Swift, SwiftUI, Keychain, CoreData, SwiftData
- Android: Kotlin, Jetpack Compose, Navigation 2, Room, DataStore
- Server: Rails, Python, GitHub Actions

Architected and built native SDKs for iOS and Android that power a "no-code" app development platform. Through the App Rail web portal, users design app flows using visual UI blocks (lists, stacks, forms, questions, grids). The native SDK then renders these designs as fully functional, native apps.

The iOS SDK uses SwiftUI for modern UI components. The Android SDK uses Jetpack Compose. Apps built with App Rail feel native and performant on each platform. The server-driven architecture delivers navigation and content via JSON, with support for dynamic data binding between steps and user-provided files.

Beyond the SDK, I developed project templates for both platforms and Python scripts for server-side project generation. This enabled App Rail to generate complete, ready-to-ship applications. Developers could commit these to GitHub and deploy to app stores via GitHub Actions.

As Platform Lead, I guided technical decisions across both mobile platforms and mentored team members on best practices, ensuring the SDK provided a great experience for developers adopting this no-code solution.

### LV x Yayoi Kusama

**Time Period:** October 2022 – February 2023
**Platforms:** iOS and Android
**Role:** Senior Mobile Developer

**Technologies:**
- General: Unity, Google Maps
- iOS: Swift, Vision Framework
- Android: Kotlin, Camera2

Developed a location-based AR game for Louis Vuitton's collaboration with artist Yayoi Kusama. Similar to Pokémon Go, users explore a map to find Louis Vuitton stores. They trigger AR experiences at those locations and collect points that convert into virtual representations of LV products. Collecting enough items unlocks real-world rewards.

The app features multiple mini-games (Colour Craze, Pumpkin Painter, Louis Labyrinth, Alma Assembly), a collectibles system with seeds and boosters, and immersive AR experiences. These overlay Kusama's signature polka dots onto the real world.

Contributed to both iOS and Android development, leveraging previous Unity experience to facilitate integration between native code and the Unity game engine.

### visionOS Applications

**Time Period:** October 2023 – April 2024
**Platform:** visionOS
**Role:** Senior iOS Developer

**Technologies:**
- Swift, SwiftUI, RealityKit, Blender (3D modeling)

Built an immersive visionOS application that transforms how farm owners visualize and interact with agricultural data. The app renders a detailed 3D model of farmland in mixed reality. Users can explore their fields spatially, viewing weather forecasts, yield trajectories, soil health, and flood risk data in a clean, immersive environment.

Users can interact with specific areas of their land through spatial pins. They can access detailed field information (soil pH, yield potential, rainfall) and explore intervention options like flood defences with cost and environmental impact breakdowns.

Led the entire development as a client exploration project, including visits to Apple's visionOS Labs before Vision Pro's public release to learn the hardware and spatial computing best practices firsthand.

### WatchWell

**Time Period:** September 2025 – December 2026
**Platform:** iOS
**Role:** Senior Mobile Developer

**Technologies:**
- Swift, SwiftUI, HealthKit, Swift Charts, WidgetKit, Vision Framework
- Apple Foundation Models (on-device AI)
- OpenAI (image analysis for calorie estimation)

Building an iOS health and wellness app that displays and analyzes user health data from HealthKit. This includes steps, heart rate, sleep, and calories burned. The app provides personalized insights and recommendations powered by Apple's on-device Foundation Models, helping users understand their health trends and improve their habits.

Key features include AI-powered food tracking that estimates calories from photos using OpenAI's image analysis. Weekly trend visualizations use Swift Charts. Home screen widgets show real-time health metrics. The Foundation Models integration analyzes health patterns and generates actionable suggestions tailored to each user's data.

Defined the app architecture and led initial development, implementing all data collection pipelines and AI/LLM integrations.

Currently in development.

## Open Source Projects

### [MusicStreamSync](https://github.com/igorcferreira/MusicStreamSync)

A Kotlin Multiplatform app that connects Apple Music and Last.fm, automatically syncing listening history to the Last.fm portal. The project integrates with native Apple Music SDKs on both iOS and Android. It demonstrates cross-platform development with platform-specific API integration.

### [GIFImage](https://github.com/igorcferreira/GIFImage)

A Swift Package for rendering and animating GIFs across Apple platforms (macOS, iOS, and visionOS). Built with Swift Concurrency and SwiftUI, it provides a modern, performant approach to GIF display.

### [KotlinNativeStudies](https://github.com/igorcferreira/KotlinNativeStudies)

A collection of Kotlin Native exploration projects. Currently includes a Kotlin Multiplatform app integrating with Microsoft's SharePoint Embedded APIs, useful for understanding enterprise API integration in a cross-platform context.

## Education

### Senac

- Degree: Associate's degree in Game Development
- Start: January 2010
- End: July 2012

This course shaped my mobile development career. I built apps and games for iOS, Android, and Windows Mobile. I worked with native frameworks like Corona and Cocos2d as well as Unity. It gave me hands-on experience across multiple mobile platforms early on, a foundation that carries through my work today.

### ETEC - Escola Técnica Estadual de São Paulo

- Degree: Technical degree in Computer Science
- Start: January 2007
- End: December 2008

Technical education focused on software development principles, with hands-on experience in C# and Java.

### Instituto Federal de Educação, Ciência e Tecnologia de São Paulo

- Degree: High School
- Start: January 2006
- End: December 2008
