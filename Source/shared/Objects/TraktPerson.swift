//
//  TraktPerson.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a person
public class TraktPerson: TraktObject, Searchable {
    /// Person's name
    public let name: String
    /// Person's biography
    public var biography: String?
    /// Person's birthday
    public var birthday: NSDate?
    /// Person's death
    public var death: NSDate?

    /**
     Init with data

     - parameter data: data
     */
    required public init?(data: JSONHash!) {
        guard let n = data["name"] as? String else {
            return nil
        }
        name = n

        super.init(data: data)
    }

    /**
     Digest data

     - parameter data: data
     */
    public override func digest(data: JSONHash?) {
        super.digest(data: data)

        biography = data?["biography"] as? String

		if let value = data?["birthday"] as? String, let date = Trakt.dateFormatter.date(from: value) {
			birthday = date as NSDate
        }

		if let value = data?["death"] as? String, let date = Trakt.dateFormatter.date(from: value) {
			death = date as NSDate
        }
    }

    /**
     Get the age of a person
     - returns: Age
     */
    public func age() -> Int? {
        guard birthday != nil else {
            return nil
        }
		let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
		let ageComponents = calendar.components(.year,
												from: birthday! as Date,
												to: (death ?? NSDate()) as Date,
                                                options: [])
        return ageComponents.year
    }

    public static var objectName: String {
        return "person"
    }
}
