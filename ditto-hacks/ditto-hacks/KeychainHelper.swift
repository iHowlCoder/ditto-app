//
//  KeychainHelper.swift
//  ditto-hacks
//
//  Secure token storage using Keychain
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private let service = "com.ditto.hacks"
    private let tokenKey = "authToken"
    private let userIdKey = "userId"
    
    // MARK: - Token Management
    
    func saveToken(_ token: String) -> Bool {
        let data = Data(token.utf8)
        return save(key: tokenKey, data: data)
    }
    
    func getToken() -> String? {
        guard let data = load(key: tokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken() -> Bool {
        return delete(key: tokenKey)
    }
    
    // MARK: - User ID Management
    
    func saveUserId(_ userId: Int) -> Bool {
        let data = withUnsafeBytes(of: userId) { Data($0) }
        return save(key: userIdKey, data: data)
    }
    
    func getUserId() -> Int? {
        guard let data = load(key: userIdKey) else { return nil }
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
    
    func deleteUserId() -> Bool {
        return delete(key: userIdKey)
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        _ = deleteToken()
        _ = deleteUserId()
    }
    
    // MARK: - Private Helpers
    
    private func save(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess ? result as? Data : nil
    }
    
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
