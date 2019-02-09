//
//  People.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

/// Get all people related an object
public class TraktRequestMediaPeople<T: TraktObject>: TraktRequest where T: Credits {
    public init(type: T.Type, id: Any, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/\(type.listName)/\(id)/people", params: extended?.value())
    }

	public func request(trakt: Trakt, completion: @escaping ([TraktCharacter]?, [TraktCrewPosition: [TraktCrew]]?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let result = response.result.value as? JSONHash else {
                return completion(nil, nil, response.result.error as NSError?)
            }

			let casting = (result["cast"] as? [JSONHash])?.compactMap {
                TraktCharacter(data: $0)
            }
            var crew: [TraktCrewPosition: [TraktCrew]]? = nil
            if let crewData = (result["crew"] as? [String: [JSONHash]]) {
                crew = [:]
                crewData.forEach {
                    guard let position = TraktCrewPosition(rawValue: $0) else {
                        return
                    }
					crew![position] = $1.compactMap {
                        TraktCrew(data: $0)
                    }
                }
            }
            completion(casting, crew, response.result.error as NSError?)
        }
    }
}

/// Get a single person
public class TraktRequestPeople: TraktRequest {
    public init(id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/people/\(id)", params: extended.value())
    }

	public func request(trakt: Trakt, completion: @escaping (TraktPerson?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            completion(TraktPerson(data: response.result.value as? JSONHash), response.result.error as NSError?)
        }
    }
}

/// Get a person credits in a media type

public class TraktRequestPeopleCredits<T: TraktObject>: TraktRequest where T: Credits {
    let type: T.Type

    public init(type: T.Type, id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        self.type = type
        super.init(path: "/people/\(id)/\(type.listName)", params: extended.value())
    }

    public typealias CreditsCompletionObject = (cast: [(character: String, media: T)]?, crew: [TraktCrewPosition: [(job: String, media: T)]]?)

	public func request(trakt: Trakt, completion: @escaping (CreditsCompletionObject?, NSError?) -> Void) -> Request? {
        return trakt.request(request: self) { response in
            guard let result = response.result.value as? JSONHash else {
                return completion(nil, response.result.error as NSError?)
            }

            var tuple: CreditsCompletionObject = (cast: [], crew: [:])
            // Crew
            (result["crew"] as? [String: [JSONHash]])?.forEach { key, values in
                guard let position = TraktCrewPosition(rawValue: key) else {
                    return
                }
				tuple.crew![position] = values.compactMap {
                    let media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)

					guard let job = $0["job"] as? String, media != nil else {
                        print("cannot find job or media")
                        return nil
                    }
                    return (job: job, media: media!)
                }
            }
            // Cast
			tuple.cast = (result["cast"] as? [JSONHash])?.compactMap {
                let media: T? = self.type.init(data: $0[self.type.objectName] as? JSONHash)
				guard let character = $0["character"] as? String, media != nil else {
                    return nil
                }
                return (character: character, media: media!)
            }

            completion(tuple, response.result.error as NSError?)
        }
    }
}
