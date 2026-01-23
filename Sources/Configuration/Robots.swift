//
//  Robots.swift
//  IgniteStarter
//
//  Created by Igor Ferreira on 23/01/2026.
//
import Foundation
import Ignite

struct Robots: RobotsConfiguration {
    var disallowRules: [DisallowRule]

    init() {
        disallowRules = [
            DisallowRule(robot: .google),
            DisallowRule(robot: .bing),
            DisallowRule(robot: .chatGPT),
            DisallowRule(robot: .apple),
            DisallowRule(name: "*")
        ]
    }
}
