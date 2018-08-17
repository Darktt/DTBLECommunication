//
//  DTAPP.swift
//
//  Created by Darktt on 16/10/14.
//  Copyright © 2016 Darktt. All rights reserved.
//

import Foundation

public struct DTAPP
{
    // MARK: - Properties -
    
    public static var isSimulator: Bool {
        
        return (TARGET_OS_SIMULATOR != 0)
    }
    
    public static var isDebug: Bool {
        
        return _isDebugAssertConfiguration()
    }
    
    public static var name: String {
        
        return DTInfo.bundleDisplayName
    }
    
    public static var bundleIdentifier: String {
        
        return DTInfo.bundleIdentifier
    }
    
    public static var version: String {
        
        return DTInfo.bundleShortVersion
    }
    
    public static var buildVersion: String {
    
        return DTInfo.bundleVersion
    }
}

public struct DTInfo
{
    // MARK: - Properties -
    
    fileprivate let bundle = Bundle.main
    
    public static var bundleVersion: String {
        
        return DTInfo()["CFBundleVersion"] as! String
    }
    
    public static var bundleShortVersion: String {
        
        return DTInfo()["CFBundleShortVersionString"] as! String
    }
    
    public static var bundleName: String {
        
        return DTInfo()["CFBundleName"] as! String
    }
    
    public static var bundleDisplayName: String {
        
        return DTInfo()["CFBundleDisplayName"] as! String
    }
    
    public static var bundleIdentifier: String {
        
        return DTInfo()["CFBundleIdentifier"] as! String
    }
    
    public subscript (key: String) -> Any?
    {
        return self.bundle.object(forInfoDictionaryKey: key)
    }
}
