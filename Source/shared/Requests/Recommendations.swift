//
//  Recommendations.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestRecommendations<T: TraktObject where T: protocol<Trending>>: TraktRequest {
    let type: T.Type

    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil, pagination: TraktPagination? = nil) {
        self.type = type
        var params: JSONHash = [:]
        if extended != nil {
            params += extended!.value()
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/recommendations/\(type.listName)", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                self.type.init(data: $0[self.type.objectName] as? JSONHash)
            }, response.result.error)
        }
    }
}

public class TraktRequestRecommendationsHide: TraktRequest {
    public init(type: TraktType, id: AnyObject) {
        super.init(method: "DELETE", path: "/recommendations/\(type.rawValue)/\(id)", oAuth: true)
    }

    public func request(trakt: Trakt, completion: (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(response.response?.statusCode == 204, response.result.error)
        }
    }
}
