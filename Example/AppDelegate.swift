//
//  AppDelegate.swift
//  AKTrakt
//
//  Created by Florian Morello on 10/30/2015.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import AKTrakt

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

/// Extends Trakt to create an autoload
extension Trakt {
    static private var loaded: Trakt?

    static func autoload() -> Trakt {
        if Trakt.loaded == nil {
            Trakt.loaded = Trakt(clientId: Secrets.clientId,
                                 clientSecret: Secrets.clientSecret,
                                 applicationId: Secrets.applicationId)
        }
        return Trakt.loaded!
    }
}
