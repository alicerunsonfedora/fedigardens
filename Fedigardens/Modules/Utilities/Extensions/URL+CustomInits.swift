//
//  URL+CustomInits.swift
//  Fedigardens
//
//  Created by Marquis Kurt on 1/3/23.
//
//  This file is part of Fedigardens.
//
//  Fedigardens is non-violent software: you can use, redistribute, and/or modify it under the terms of the CNPLv7+
//  as found in the LICENSE file in the source code root directory or at <https://git.pixie.town/thufie/npl-builder>.
//
//  Fedigardens comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

extension URL {
    enum AppDestination {
        case oneSec
        case oneSecSettings
        case ghBugs
        case github
        case raceway(title: String? = nil)
        case changelog
        case orion(String)

        private var ghLink: String { "https://github.com/alicerunsonfedora/fedigardens" }

        var absoluteString: String {
            switch self {
            case .oneSec:
                return "onesec://reintervene?appId=fedigardens"
            case .oneSecSettings:
                return "onesec://integrationsettings?appId=fedigardens"
            case .github:
                return ghLink
            case .raceway(let title):
                let titleArgument = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                return "https://feedback.marquiskurt.net/composer?primary_tag=fedigardens&title='\(titleArgument)'"
            case .changelog:
                return "https://fedigardens.app/changelog"
            case .ghBugs:
                return ghLink + "/issues/new?assignees=alicerunsonfedora&labels=Bug&template=bug_report.md"
            case .orion(let realURL):
                return "orion://open-url?url=" + realURL
            }
        }
    }

    init?(destination: AppDestination) {
        print(destination.absoluteString)
        self.init(string: destination.absoluteString)
    }

    @available(*, deprecated, message: "Use URL.init(destination:) instead.")
    static func oneSec() -> URL? {
        return URL(string: "onesec://reintervene?appId=fedigardens")
    }
}
