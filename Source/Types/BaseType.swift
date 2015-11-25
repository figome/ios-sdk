//
//  BaseType.swift
//  Figo
//
//  Created by Christian König on 25.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import Foundation


public protocol ResponseObjectSerializable {
    init(representation: AnyObject) throws
}

public protocol ResponseCollectionSerializable {
    static func collection(representation: AnyObject) throws -> [Self]
}

public protocol JSONObjectConvertible {
    var JSONObject: [String: AnyObject] { get }
}

protocol PropertyKey {
    var rawValue: String { get }
}

func JSONStringFromType(type: JSONObjectConvertible) -> String {
    if let data = try? NSJSONSerialization.dataWithJSONObject(type.JSONObject, options: NSJSONWritingOptions.PrettyPrinted) {
        if let string = String(data: data, encoding: NSUTF8StringEncoding) {
            return string
        }
    }
    return ""
}
