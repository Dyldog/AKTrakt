//
//  Recommendations.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestRecommendations<T: TraktObject>: TraktRequest where T: Recommandable {
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

	public func request(trakt: Trakt, completion: @escaping ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }
			completion(entries.compactMap {
                self.type.init(data: $0)
            }, response.result.error as NSError?)
        }
    }
}

public class TraktRequestRecommendationsHide<T: TraktObject>: TraktRequest where T: Recommandable {
    public init(type: T.Type, id: AnyObject) {
        super.init(method: "DELETE", path: "/recommendations/\(type.listName)/\(id)", oAuth: true)
    }

	public func request(trakt: Trakt, completion: @escaping (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            completion(response.response?.statusCode == 204, response.result.error as NSError?)
        }
    }
}
