//
//  CBManagerStateExtension.swift
//
//  Created by Eden on 2021/10/4.
//  Copyright © 2021 Darktt. All rights reserved.
//

import CoreBluetooth.CBManager

extension CBManagerState: CustomDebugStringConvertible
{
    public var debugDescription: String {
        
        var description: String
        
        switch self {
            
        case .unknown:
            description = "unknown"
            
        case .resetting:
            description = "resetting"
            
        case .unsupported:
            description = "unsupported"
            
        case .unauthorized:
            description = "unauthorized"
            
        case .poweredOff:
            description = "powered off"
            
        case .poweredOn:
            description = "powered on"
            
        @unknown default:
            description = ""
        }
        
        return description
    }
}
