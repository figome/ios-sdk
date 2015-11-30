//
//  Decoder.swift
//  Figo
//
//  Created by Christian König on 27.11.15.
//  Copyright © 2015 CodeStage. All rights reserved.
//

import Foundation


struct Decoder {
    let representation: Dictionary<String, AnyObject>
    let typeName: String
    
    init(_ representation: AnyObject, typeName: String) throws {
        guard let representation: Dictionary<String, AnyObject> = representation as? Dictionary<String, AnyObject> else {
            throw FigoError.JSONUnexpectedRootObject(typeName: typeName)
        }
        self.representation = representation
        self.typeName = typeName
    }
    
    func valueForKey<T>(key: PropertyKey) throws -> T {
        return try valueForKeyName(key.rawValue)
    }
    
    func valueForKeyName<T>(keyName: String) throws -> T {
        guard representation[keyName] != nil else {
            throw FigoError.JSONMissingMandatoryKey(key: keyName, typeName: typeName)
        }
        guard (representation[keyName] as? NSNull) == nil else {
            throw FigoError.JSONMissingMandatoryValue(key: keyName, typeName: typeName)
        }
        guard let value = representation[keyName] as? T else {
            throw FigoError.JSONUnexpectedType(key: keyName, typeName: typeName)
        }
        return value
    }
    
    func optionalForKey<T>(key: PropertyKey) throws -> T? {
        return try optionalForKeyName(key.rawValue)
    }
    
    func optionalForKeyName<T>(keyName: String) throws -> T? {
        guard representation[keyName] != nil else {
            return nil
        }
        guard (representation[keyName] as? NSNull) == nil else {
            return nil
        }
        guard let value: T? = representation[keyName] as? T? else {
            throw FigoError.JSONUnexpectedType(key: keyName, typeName: typeName)
        }
        return value
    }
}

func decodeTaskTokenResponse(response: FigoResult<NSData>) -> FigoResult<String> {
    switch response {
    case .Failure(let error):
        return .Failure(error)
    case .Success(let data):
        do {
            if let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] {
                if let token: String = JSON["task_token"] as? String {
                    return .Success(token)
                }
            }
            return .Failure(.JSONMissingMandatoryValue(key: "task_token", typeName: ""))
        } catch (let error as NSError) {
            return .Failure(.JSONSerializationError(error: error))
        }
    }
}

func decodeJSONResponse(response: FigoResult<NSData>) -> FigoResult<[String: AnyObject]> {
    switch response {
    case .Failure(let error):
        return .Failure(error)
    case .Success(let data):
        do {
            if let JSON: [String: AnyObject] = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject] {
                return .Success(JSON)
            } else {
                return .Failure(.JSONUnexpectedRootObject(typeName: "JSONResponse"))
            }
        } catch (let error as NSError) {
            return .Failure(.JSONSerializationError(error: error))
        }
    }
}

func decodeVoidResponse(response: FigoResult<NSData>) -> FigoResult<Void> {
    switch response {
    case .Failure(let error):
        return .Failure(error)
    case .Success:
        return .Success()
    }
}

func decodeObjectResponse<T: ResponseObjectSerializable>(response: FigoResult<NSData>) -> FigoResult<T> {
    switch response {
    case .Failure(let error):
        return .Failure(error)
    case .Success(let data):
        var JSON: AnyObject
        do {
            JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        } catch (let error as NSError) {
            return .Failure(.JSONSerializationError(error: error))
        }
        do {
            let decodedObject = try T(representation: JSON)
            return .Success(decodedObject)
        } catch (let error as FigoError) {
            return .Failure(error)
        } catch {
            return .Failure(.UnspecifiedError(reason: "Failed to serialize type: \(T.self)"))
        }
    }
}

func decodeCollectionResponse<T: ResponseCollectionSerializable>(response: FigoResult<NSData>) -> FigoResult<[T]> {
    switch response {
    case .Failure(let error):
        return .Failure(error)
    case .Success(let data):
        var JSON: AnyObject
        do {
            JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
        } catch (let error as NSError) {
            return .Failure(.JSONSerializationError(error: error))
        }
        do {
            let decodedCollection = try T.collection(JSON)
            return .Success(decodedCollection)
        } catch (let error as FigoError) {
            return .Failure(error)
        } catch {
            return .Failure(.UnspecifiedError(reason: "Failed to serialize type: \(T.self)"))
        }
    }
}

func base64Encode(clientID: String, _ clientSecret: String) -> String {
    let clientCode: String = clientID + ":" + clientSecret
    let utf8str: NSData = clientCode.dataUsingEncoding(NSUTF8StringEncoding)!
    return utf8str.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
}
