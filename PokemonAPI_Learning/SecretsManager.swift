//
//  SecretsManager.swift
//  PokemonAPI_Learning
//
//  Created by cmStudent on 2025/04/18.
//

import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private var secrets: [String: Any]?
    
    private init() {
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            self.secrets = plist
        }
    }
    func get(_ key: String) -> String? {
        return secrets?[key] as? String
    }
}
