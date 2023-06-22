//
//  WindowsUtils.swift
//  Kiloma Advanced Solutions
//
//  Created by Itai Bear on 6/22/23.
//

import Foundation

#if os(Windows)

class WindowsVendorSystem: VendorSystem {
    override var manufacturer: String {
        return "unknown"
    }
    
    override var type: String {
        return "Windows"
    }
    
    override var model: String {
        return "unknown"
    }
    
    override var name: String {
        return "unknown"
    }
    
    override var identifierForVendor: String? {
        return nil
    }
    
    override var systemName: String {
        return "unknown"
    }
    
    override var systemVersion: String {
        return ""
    }
    
    override var screenSize: ScreenSize {
        return ScreenSize(width: 0, height: 0)
    }
    
    override var userAgent: String? {
        return "unknown"
    }
    
    override var connection: ConnectionStatus {
        return ConnectionStatus.unknown
    }
    
    override var requiredPlugins: [PlatformPlugin] {
        return []
    }
}

#endif
