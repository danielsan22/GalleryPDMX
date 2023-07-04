//
//  Config.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 03/07/23.
//

import Foundation

enum Config {
    
    enum Key: String {
        case unsplashAccessKey = "UNSPLASH_API_ACCESS_KEY"
    }
    
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static func value<T>(for key: Key) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else {
            throw Error.missingKey
        }
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

extension Config {
    static var unsplashAccessKey: String  { try! Config.value(for: .unsplashAccessKey) }
}
