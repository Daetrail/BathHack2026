//
//  ParseCodable.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

enum ParseCodableError: LocalizedError {
    case failedToParse(String)
    
    var errorDescription: String? {
        switch self {
        case .failedToParse(let msg): return msg
        }
    }
}

func parseCodable<T: Codable>(type: T.Type, from data: Any) throws -> T {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(T.self, from: jsonData)
        
        return decoded
        
    } catch {
        throw ParseCodableError.failedToParse(error.localizedDescription)
    }
}

func parseCodable<T: Codable>(type: T.Type, from data: Data) throws -> T {
    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(T.self, from: data)
        
        return decoded
        
    } catch {
        throw ParseCodableError.failedToParse(error.localizedDescription)
    }
}
