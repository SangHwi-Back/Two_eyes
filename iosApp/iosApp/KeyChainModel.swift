//
//  KeyChainModel.swift
//  iosApp
//
//  Created by SangHwiBack on 4/27/26.
//

//import Foundation
//
//class KeychainModel<T: Codable & KeychainSendable> {
//    // MARK: Types
//    
//    enum KeychainError: Error {
//        case noPassword
//        case unexpectedData
//        case unexpectedItemData
//        case unhandledError
//    }
//    
//    // MARK: Properties
//    
//    let service: String
//    
//    private(set) var account: String
//    
//    let accessGroup: String?
//    
//    // MARK: Intialization
//    
//    init() {
//        self.service = T.service
//        self.account = T.account
//        self.accessGroup = T.accessGroup
//    }
//    
//    // MARK: Keychain access
//    
//    func readItem() throws -> T {
//        /*
//         Build a query to find the item that matches the service, account and
//         access group.
//         */
//        var query = KeychainModel.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
//        query[kSecMatchLimit as String] = kSecMatchLimitOne
//        query[kSecReturnAttributes as String] = kCFBooleanTrue
//        query[kSecReturnData as String] = kCFBooleanTrue
//        
//        // Try to fetch the existing keychain item that matches the query.
//        var queryResult: AnyObject?
//        let status = withUnsafeMutablePointer(to: &queryResult) {
//            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
//        }
//        
//        // Check the return status and throw an error if appropriate.
//        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
//        guard status == noErr else { throw KeychainError.unhandledError }
//        
//        // Parse the password string from the query result.
//        
//        guard let existingItem = queryResult as? [String: AnyObject],
//              let decodableData = existingItem[kSecValueData as String] as? Data,
//              let result = try? PropertyListDecoder().decode(T.self, from: decodableData)
//        else {
//            throw KeychainError.unexpectedData
//        }
//        
//        return result
//    }
//    
//    func saveItem(_ entity: T) throws {
//        // Encode the password into an Data object.
//        let encodedData = try PropertyListEncoder().encode(entity)
//        
//        do {
//            // Check for an existing item in the keychain.
//            try _ = readItem()
//            
//            // Update the existing item with the new password.
//            var attributesToUpdate = [String: AnyObject]()
//            attributesToUpdate[kSecValueData as String] = encodedData as AnyObject?
//            
//            let query = KeychainModel.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
//            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
//            
//            // Throw an error if an unexpected status was returned.
//            guard status == noErr else { throw KeychainError.unhandledError }
//        } catch KeychainError.noPassword {
//            /*
//             No password was found in the keychain. Create a dictionary to save
//             as a new keychain item.
//             */
//            var newItem = KeychainModel.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
//            newItem[kSecValueData as String] = encodedData as AnyObject?
//            
//            // Add a the new item to the keychain.
//            let status = SecItemAdd(newItem as CFDictionary, nil)
//            
//            // Throw an error if an unexpected status was returned.
//            guard status == noErr else { throw KeychainError.unhandledError }
//        }
//    }
//    
//    // MARK: Convenience
//    
//    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
//        var query = [String: AnyObject]()
//        query[kSecClass as String] = kSecClassGenericPassword
//        query[kSecAttrService as String] = service as AnyObject?
//        
//        if let account = account {
//            query[kSecAttrAccount as String] = account as AnyObject?
//        }
//        
//        if let accessGroup = accessGroup {
//            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
//        }
//        
//        return query
//    }
//}
