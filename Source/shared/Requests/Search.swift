//
//  Search.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

/// Represents trakt search object type
private enum TraktSearchType: String {
    /// Movie
    case Movie = "movie"
    /// Show
    case Show = "show"
    /// Season
    case Season = "season"
    /// Episode
    case Episode = "episode"
    /// Person
    case Person = "person"

    /// Associated TraktObject type
    public var classType: TraktObject.Type? {
        switch self {
        case .Movie:
            return TraktMovie.self
        case .Show:
            return TraktShow.self
        case .Season:
            return TraktSeason.self
        case .Person:
            return TraktPerson.self
        case .Episode:
            return TraktEpisode.self
        }
    }
}

/// Serarch request
public class TraktRequestSearch<T: TraktObject>: TraktRequest where T: Searchable {
    /**
     Init

     - parameter query:      search query string
     - parameter type:       optional trakt type
     - parameter year:       optional year
     - parameter pagination: optional pagination
     */
    public init(query: String, type: T.Type? = nil, year: UInt? = nil, pagination: TraktPagination? = nil) {
        var params: JSONHash = [
			"query": query as AnyObject
        ]
        if year != nil {
			params["year"] = year! as AnyObject
        }
        if type != nil {
			params["type"] = type!.objectName as AnyObject
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/search", params: params)
    }

    /**
     Execute request

     - parameter trakt:      trakt client
     - parameter completion: closure [TraktObject]?, NSError?

     - returns: Alamofire.Request
     */
	public func request(trakt: Trakt, completion: @escaping ([TraktObject]?, NSError?) -> Void) -> Request? {
		return trakt.request(request: self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error as NSError?)
            }

			completion(entries.compactMap {
                guard let type = TraktSearchType(rawValue: $0["type"] as? String ?? "") else {
                    return nil
                }
                return type.classType?.init(data: $0[type.rawValue] as? JSONHash)
            }, nil)
        }
    }
}
