//
//  Season.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestSeason: TraktRequest, TraktRequest_Completion {
    public init(showId: AnyObject, seasonNumber: UInt, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/\(seasonNumber)", params: extended?.value())
    }

    public func request(trakt: Trakt, completion: ([TraktEpisode]?, NSError?) -> Void)-> Request? {
        return trakt.request(self) { [weak self] response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap {
                TraktEpisode(data: $0)
            }, nil)
        }
    }
}
