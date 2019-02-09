//
//  Season.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestSeason: TraktRequest {
    public init(showId: AnyObject, seasonNumber: UInt, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/\(seasonNumber)", params: extended?.value())
    }

	public func request(trakt: Trakt, completion: @escaping ([TraktEpisode]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }
			completion(items.compactMap {
                TraktEpisode(data: $0)
            }, nil)
        }
    }
}

public class TraktRequestSeasons: TraktRequest {
    public init(showId: Any, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/", params: extended?.value())
    }

	public func request(trakt: Trakt, completion: @escaping ([TraktSeason]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }
			completion(items.compactMap {
                TraktSeason(data: $0)
            }.sorted {
                $0.number < $1.number
            }, nil)
        }
    }
}
