
//
//  Watchlist.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire


public class TraktRequestGetWatchlist<T: TraktObject>: TraktRequest where T: Watchlist {
    let type: T.Type
    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil, sort: TraktSortHeaders? = nil) {
        self.type = type
		super.init(path: "/sync/watchlist/\(type.listName)", params: extended?.value(), oAuth: true, headers: sort?.value())
    }

	public func request(trakt: Trakt, completion: @escaping ([(listedAt: NSDate, media: T)]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }

			completion(entries.compactMap {
                var media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                media?.watchlist = true
				guard let date = $0["listed_at"] as? String, let listedAt = Trakt.datetimeFormatter.date(from: date), media != nil else {
                    return nil
                }
                return (listedAt: listedAt as NSDate, media: media!)
            }, nil)
        }
    }
}

public class TraktRequestGetWatched<T: TraktObject>: TraktRequest where T: Watchlist {
    let type: T.Type
    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil) {
        self.type = type
		super.init(path: "/sync/watched/\(type.listName)", params: extended?.value(), oAuth: true)
    }

	public func request(trakt: Trakt, completion: @escaping ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }
			completion(entries.compactMap {
                let media = self.type.init(data: $0[self.type.objectName] as? JSONHash)
                /// Digest other data like plays, last watched at ...
				media?.digest(data: $0)
                return media
            }, nil)
        }
    }
}


/// Request to add object to your watchlist
public class TraktRequestAddToWatchlist<T: TraktObject>: TraktRequest where T: ObjectType, T: ListType {
    private let type: T.Type
    public init(type: T.Type, id: TraktIdentifier) {
        self.type = type

        let params: JSONHash = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
                ]
            ]
        ]
        super.init(method: "POST", path: "/sync/watchlist", params: params, oAuth: true)
    }

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

/// Request to remove an object from watchlist
public class TraktRequestRemoveFromWatchlist<T: TraktObject>: TraktRequest where T: ObjectType, T: ListType {
    private let type: T.Type
    public init(type: T.Type, id: TraktIdentifier) {
        self.type = type
        let params: JSONHash = [
            type.listName: [
                [
                    "ids": [
                        "trakt": id
                    ],
                ]
            ]
        ]
        super.init(method: "POST", path: "/sync/watchlist/remove", params: params, oAuth: true)
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
