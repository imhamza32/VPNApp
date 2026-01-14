//
//  KeychainHelper.swift
//  VPNApp
//
//  Created by Munib Hamza on 14.01.26.
//


import Foundation
import Security

class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    // Save data to Keychain
    func save(_ data: Data, service: String, account: String) {
        // Create query
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ] as CFDictionary
        
        // Add data in query to keychain
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            // Item already exists, thus update it.
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword
            ] as CFDictionary

            let attributesToUpdate = [kSecValueData: data] as CFDictionary

            // Update existing item
            SecItemUpdate(query, attributesToUpdate)
        }
    }
    
    // Read data from Keychain
    func read(service: String, account: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return result as? Data
    }
    
    // Delete data from Keychain
    func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}

// Extension to make saving Strings easier
extension KeychainHelper {
    func save(_ value: String, service: String, account: String) {
        if let data = value.data(using: .utf8) {
            // Explicitly call the Data version to avoid ambiguity
            self.save(data, service: service, account: account)
        }
    }
    
    func read(service: String, account: String) -> String? {
        // Explicitly call the Data version to avoid ambiguity
        if let data: Data = (self.read(service: service, account: account) as Data?) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
