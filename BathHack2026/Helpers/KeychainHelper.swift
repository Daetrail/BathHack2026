//
//  KeychainHelper.swift
//  BathHack2026
//
//  Created by Matt Dustin Cruz on 28/03/2026.
//

import Foundation

enum KeychainError: LocalizedError {
    case failedToSave(String)
    case failedToRead(String)
    
    var errorDescription: String? {
        switch self {
        case .failedToSave(let msg): return msg
        case .failedToRead(let msg): return msg
        }
    }
}

class KeychainHelper {
    private static var accountName = Constants.appName + "User"
    
    static let standard = KeychainHelper()
    private init() {}
    
    func save<T: Codable>(_ item: T, service: String, account: String = accountName) throws {
        do {
            let data = try JSONEncoder().encode(item)
        
            var query = [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ] as CFDictionary
            
            let status = SecItemAdd(query, nil)
            
            if status == errSecDuplicateItem {
                query = [
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary
                
                let attributesToUpdate = [kSecValueData: data] as CFDictionary
                SecItemUpdate(query, attributesToUpdate)
            }
        } catch {
            throw KeychainError.failedToSave(error.localizedDescription)
        }
    }
    
    func read<T: Codable>(service: String, account: String = accountName, type: T.Type) throws -> T? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let unwrappedResult = result as? Data else {
            return nil
        }
        
        do {
            let item = try JSONDecoder().decode(type, from: unwrappedResult)
            return item
        } catch {
            throw KeychainError.failedToRead(error.localizedDescription)
        }
    }
    
    func delete(service: String, account: String = accountName) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
