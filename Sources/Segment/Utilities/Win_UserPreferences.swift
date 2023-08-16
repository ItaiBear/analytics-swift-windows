//
//  Win_UserPreferences.swift
//  L1 - Angles
//
//  Created by Paaz Cohen-Abramovich on 29/12/2022.
//

#if !os(Windows)

import Foundation

/// On platforms other than Windows, UserPreferences is a typealias for UserDefaults.
typealias UserPreferences = UserDefaults

#else

import Foundation

/// On Windows, for some reason UserDefaults does not persist, so we implement an alternative.
class UserPreferences {
    let fileName = "AnalyticsDefaults.json"

    private let lock = NSLock() // for thread safety
    private var preferencesDict: [String : JSON] = [:]
    private var registrations: [String : Codable] = [:]

    init(suiteName: String? = nil) {        
        loadFromDisk()
    }

    /// Sets the value of the specified preference key to the specified value.
    func set(_ value: Codable, forKey key: String) {
        Analytics.segmentLog(message: "Setting \(key) to \(value) in UserPreferences", kind: .debug)
        // we encode the data as a JSON string and save to the dictionary
        //let encoder = JSONEncoder()
        
        // let json: Data
        // do {
        //     json = try encoder.encode(value)
        // } catch {
        //     Analytics.reportInternalError(error, fatal: true)
        //     return
        // }
        
        //let jsonString = String(data: json, encoding: .utf8) ?? ""
        guard let value = try? JSON(value) else {
            Analytics.segmentLog(message: "Error encoding \(key) to JSON", kind: .error)
            return
        }
        lock.lock()
        preferencesDict[key] = value
        Analytics.segmentLog(message: "Storing \(value.prettyPrint()) to UserPreferences", kind: .debug)
        saveToDisk()
        
        lock.unlock()
    }

    // /**
    //  Returns the value associated with the specified key.
    //  - Parameter key: A key in the current user‘s preferences database.
    //  - Returns: The value associated with the specified key.
    //             If the specified key doesn't exist, this method returns nil.
    // */
    // func get<T: Codable>(forKey key: String) -> T? {
    //     lock.lock()
        
    //     // unlock before exit
    //     defer {
    //         lock.unlock()
    //     }

    //     // if doesn't exist
    //     guard let Data = preferencesDict[key]?.data(using: .utf8) else {
    //         // if not in registration then return nil
    //         return registrations[key] as? T
    //     }

    //     let decoder = JSONDecoder()
    //     // decode from JSON string
    //     let value: T
    //     do {
    //         value = try decoder.decode(T.self, from: Data)
    //     } catch {
    //         Analytics.segmentLog(message: "Error decoding \(key) from JSON: \(error)", kind: .error)
    //         return nil
    //     }

    //     return value
    // }

    func object(forKey defaultName: String) -> Any? {
        lock.lock()
        let result = preferencesDict[defaultName]
        lock.unlock()
        return result
    }

    func integer(forKey defaultName: String) -> Int {
        guard let aVal = object(forKey: defaultName) else {
            return 0
        }
        if let bVal = aVal as? Int {
            return bVal
        }
        if let bVal = aVal as? Bool {
            return NSNumber(value: bVal).intValue
        }
        if let bVal = aVal as? Float {
            return NSNumber(value: bVal).intValue
        }
        if let bVal = aVal as? Double {
            return NSNumber(value: bVal).intValue
        }
        if let bVal = aVal as? String {
            return NSString(string: bVal).integerValue
        }
        return 0
    }

    /**
     Returns the Boolean value associated with the specified key.
     - Parameter key: A key in the current user‘s preferences database.
     - Returns: The Boolean value associated with the specified key.
                If the specified key doesn't exist, this method returns false.
    */
    func bool(forKey defaultName: String) -> Bool {
        guard let aVal = object(forKey: defaultName) else {
            return false
        }
        if let bVal = aVal as? Bool {
            return bVal
        }
        if let bVal = aVal as? Int {
            return bVal != 0
        }
        if let bVal = aVal as? Float {
            return bVal != 0
        }
        if let bVal = aVal as? Double {
            return bVal != 0
        }
        if let bVal = aVal as? String {
            return NSString(string: bVal).boolValue
        }
        return false
    }

    func removeObject(forKey defaultName: String) {
        lock.lock()
        
        preferencesDict.removeValue(forKey: defaultName)
        saveToDisk()
        
        lock.unlock()
    }

    /**
     Registers the default values for the user preferences.
     Not written to disk. You need to call this method each time your application starts.
    */
    func register(registrationDictionary: [String : Codable]) {
        lock.lock()

        // set registrations
        for (key, value) in registrationDictionary {
            registrations[key] = value
        }

        lock.unlock()
    }

    func synchronize(){ }

    /// Saves preferences to disk as JSON.
    private func saveToDisk() {
        let fullPath = NSCoderHelpers.userDataDirectory.appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(preferencesDict)
            try data.write(to: fullPath)
        } catch {
            Analytics.segmentLog(message: "Couldn't write file. \(error)", kind: .debug)
        }
    }
    
    /**
     Loads Decodable JSON from disk.
     - Parameters:
       - path: File path to load.
     - Returns: The loaded object on success, nil on failure.
    */
    private func loadFromDisk() {
        let fullPath = NSCoderHelpers.userDataDirectory.appendingPathComponent(fileName)
        guard let jsonData = try? Data(contentsOf: fullPath) else {
            preferencesDict = [:]
            return
        }
        let loadedPreferences = try? JSONDecoder().decode([String : JSON].self, from: jsonData)
        preferencesDict = loadedPreferences ?? [:]
        
    }
}

#endif
