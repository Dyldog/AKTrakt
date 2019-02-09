//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

/// Trakt client
public class Trakt {
    // Client Id
    public let clientId: String
    // Application Secret
    internal let clientSecret: String
    // Application Id
    internal let applicationId: Int
    // Trakt Token
    public var token: TraktToken?
    /// Delay between each re attempt in seconds
    internal var retryInterval: Double = 5
    // Cache request attempts (in case of faileur/retry)
	internal var attempts = NSCache<AnyObject, AnyObject>()
    // Alamofire Manager
    internal let manager = SessionManager()
    // Trakt api version
    public let traktApiVersion = 2
    // UserDefaults key
    private var userDefaultsTokenKey: String

    /**
     Init

     - parameter clientId:      clientId
     - parameter clientSecret:  clientSecret
     - parameter applicationId: applicationId
     */
    public init(clientId: String, clientSecret: String, applicationId: Int) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.applicationId = applicationId
        userDefaultsTokenKey = "trakt_token_" + clientId

        // autoload token
        token = loadTokenFromDefaults()
    }

    /**
     Attempt to load token from UserDefaults

     - returns: TraktToken
     */
    private func loadTokenFromDefaults() -> TraktToken? {
		let defaults = UserDefaults.standard
		guard let data = defaults.object(forKey: userDefaultsTokenKey) as? NSData,
			let token = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? TraktToken else {
            return nil
        }
        return token
    }

    /**
     Save token

     - parameter token: TraktToken
     */
    public func saveToken(token: TraktToken) {
        self.token = token

		let data = NSKeyedArchiver.archivedData(withRootObject: token)
		UserDefaults.standard.set(data, forKey: userDefaultsTokenKey)
    }

    /// Remove token from UserDefaults
    public func clearToken() {
		UserDefaults.standard.removeObject(forKey: userDefaultsTokenKey)
        token = nil
    }

    /**
     Check if client has a non expired token

     - returns: bool
     */
    public func hasValidToken() -> Bool {
		return token?.expiresAt.compare(NSDate() as Date) == .orderedDescending
    }

    /// Date formatter (trakt style)
	public static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        df.dateFormat = "yyyy'-'MM'-'dd"
        return df
    }()

    /// Datetime formatter (trakt style)
	public static let datetimeFormatter: DateFormatter = {
        let df = DateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        return df
    }()
}
