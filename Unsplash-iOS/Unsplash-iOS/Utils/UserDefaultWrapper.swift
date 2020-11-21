//
//  UserDefaultWrapper.swift
//  Unsplash-iOS
//
//  Created by Park GilNam on 2020/11/20.
//

import Foundation

// MARK: - UserDefaultKey
enum UserDefaultKey {
    case recentKeywords
    
    var key: String {
        switch self {
        case .recentKeywords:
            return "recentKeywords"
        }
    }
}

// MARK: - UserDefaultWrapper
@propertyWrapper
struct UserDefaultWrapper<T> {
    // MARK: - Property
    var key: String
    
    var wrappedValue: T? {
        get {
            guard let groupUserDefaults = UserDefaults(suiteName: "group.inviteshealthcare.TDNA-iOS.com") else{
                return UserDefaults.standard.object(forKey: key) as? T
            }
            return groupUserDefaults.object(forKey: key) as? T
        }
        set {
            if let groupUserDefaults = UserDefaults(suiteName: "group.inviteshealthcare.TDNA-iOS.com") {
                return groupUserDefaults.set(newValue, forKey: key)
            }
        }
    }
    
    // MARK: - Initialization
    init(wrappedValue: T?, key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    init(key: String) {
        self.key = key
    }
}
