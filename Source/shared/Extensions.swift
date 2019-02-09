//
//  Extensions.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation

/// Key: Value typealias dictionary
public typealias JSONHash = [String: Any]

// Allow to merge JSONHash
func += (left: inout JSONHash, right: JSONHash) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/**
 Delay closure

 - parameter delay:   time in seconds
 - parameter closure: closure to exec
 */
internal func delay(delay: Double, closure: @escaping () ->()) {
	DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { closure() })
//    dispatch_after(
//        dispatch_time(
//			dispatch_time_t(DISPATCH_TIME_NOW),
//            Int64(delay * Double(NSEC_PER_SEC))
//        ),
//        dispatch_get_main_queue(), closure)
}

// Get the area of a size
extension CGSize {
    var area: CGFloat {
        return width * height
    }
}
