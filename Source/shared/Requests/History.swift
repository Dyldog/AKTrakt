//
//  History.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

/// Add an object to watched history
public class TraktRequestAddToHistory<T: TraktObject>: TraktRequest where T: ObjectType, T: ListType {
    private var type: T.Type
    /**
     Init request

     - parameter type:      type (ex: TraktMovie.self)
     - parameter id:        id
     - parameter watchedAt: optional date (default to now)
     */
    public init(type: T.Type, id: TraktIdentifier, watchedAt: NSDate = NSDate()) {
        self.type = type
		let params: [String: Any] = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
					"watched_at": Trakt.datetimeFormatter.string(from: watchedAt as Date)
                ]
            ]
        ]
		super.init(method: "POST", path: "/sync/history", params: params as JSONHash, oAuth: true)
    }


    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure (bool: added, NSError?)

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (Bool?, NSError?) -> Void) -> Request? {
		return trakt.request(request: self) { response in
            guard let items = response.result.value as? JSONHash,
                let added = items["added"] as? [String: Int],
                let value = added[self.type.listName]
                else {
                return completion(nil, response.result.error as NSError?)
            }

            completion(value == 1, response.result.error as NSError?)
        }
    }
}

/// Remove an object from watched history
public class TraktRequestRemoveFromHistory<T: TraktObject>: TraktRequest where T: ObjectType, T: ListType {
    private var type: T.Type

    /**
     Init request

     - parameter type:      type (ex: TraktMovie.self)
     - parameter id:        id
     */
    public init(type: T.Type, id: TraktIdentifier) {
        self.type = type
		let params: [String: Any] = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
                ]
            ]
        ]
		super.init(method: "POST", path: "/sync/history/remove", params: params as JSONHash, oAuth: true)
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure (bool: deleted, NSError?)

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping (Bool?, NSError?) -> Void) -> Request? {
		return trakt.request(request: self) { response in
            guard let items = response.result.value as? JSONHash,
                let added = items["deleted"] as? [String: Int],
                let value = added[self.type.listName]
                else {
                    return completion(nil, response.result.error as NSError?)
            }

            completion(value == 1, response.result.error as NSError?)
        }
    }
}
