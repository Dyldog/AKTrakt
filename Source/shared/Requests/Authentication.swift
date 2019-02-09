//
//  Authentication.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public typealias GeneratedCodeResponse = (deviceCode: String, userCode: String, verificationUrl: String, expiresAt: NSDate, interval: TimeInterval)

///	Generate new device codes
public class TraktRequestGenerateCode: TraktRequest {
    /**
     Init with a clientID

     - parameter clientId: clientId
     */
    public init(clientId: String) {
		super.init(method: "POST", path: "/oauth/device/code", params: ["client_id": clientId as AnyObject])
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure GeneratedCodeResponse, NSError

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (GeneratedCodeResponse?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard
                let data = response.result.value as? JSONHash,
				let deviceCode = data["device_code"] as? String,
                let userCode = data["user_code"] as? String,
                let verificationUrl = data["verification_url"] as? String,
                let expiresIn = data["expires_in"] as? Double,
                let interval = data["interval"] as? Double else {
                    return completion(nil, response.result.error as NSError?)
            }
			completion((deviceCode: deviceCode, userCode: userCode, verificationUrl: verificationUrl, expiresAt: NSDate().addingTimeInterval(expiresIn), interval: interval), nil)
        }
    }
}

///	Poll for the access_token
public class TraktRequestPollDevice: TraktRequest {
    /**
     Init

     - parameter trakt:      trakt client
     - parameter deviceCode: deviceCode
     */
    public init(trakt: Trakt, deviceCode: String) {
        super.init(method: "POST", path: "/oauth/device/token", params: [
			"client_id": trakt.clientId as AnyObject,
			"client_secret": trakt.clientSecret as AnyObject,
			"code": deviceCode as AnyObject,
        ])
        attemptLeft = 1
    }

    /**
     Request

     - parameter trakt:      trakt
     - parameter completion: closure TraktToken?, NSError?

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (TraktToken?, NSError?) -> Void) -> Request? {
		return trakt.request(request: self) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error as NSError?)
        }
    }
}

///	Exchange code for access_token
public class TraktRequestToken: TraktRequest {
    /**
     Init

     - parameter trakt: trakt client
     - parameter pin:   pin string
     */
    public init(trakt: Trakt, pin: String) {
        super.init(method: "POST", path: "/oauth/token", params: [
			"code": pin as AnyObject,
			"client_id": trakt.clientId as AnyObject,
			"client_secret": trakt.clientSecret as AnyObject,
			"redirect_uri": "urn:ietf:wg:oauth:2.0:oob" as AnyObject,
            "grant_type": "authorization_code" as AnyObject,
            ])
    }

    /**
     Request

     - parameter trakt:      trakt client
     - parameter completion: closure TraktToken?, NSError?

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (TraktToken?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error as NSError?)
        }
    }
}

///	Refresh token request
public class TraktRequestRefreshToken: TraktRequest {
    /**
     Init

     - parameter trakt: trakt client
     - parameter pin:   pin string
     */
    public init(trakt: Trakt, token: TraktToken) {
        super.init(method: "POST", path: "/oauth/token", params: [
			"refresh_token": token.refreshToken as AnyObject,
            "client_id": trakt.clientId  as AnyObject,
            "client_secret": trakt.clientSecret  as AnyObject,
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob"  as AnyObject,
            "grant_type": "refresh_token"  as AnyObject
        ])
    }

    /**
     Request

     - parameter trakt:      trakt client
     - parameter completion: closure TraktToken?, NSError?

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (TraktToken?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error as NSError?)
        }
    }
}

///	Get a user profile
public class TraktRequestProfile: TraktRequest {
    /**
     Init

     - parameter username: username or self("me") if nil
     */
    public init(username: String = "me") {
        super.init(path: "/users/\(username)", oAuth: true)
    }

    /**
     Request

     - parameter trakt:      trakt client
     - parameter completion: closure JSONHash?, NSError?

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (JSONHash?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            completion(response.result.value as? JSONHash, response.result.error as NSError?)
        }
    }
}
