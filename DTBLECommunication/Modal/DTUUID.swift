//
//  DTUUID.swift
//  DTBLECommunication
//
//  Created by EdenLi on 2018/8/15.
//  Copyright © 2018年 Darktt. All rights reserved.
//

import CoreBluetooth
import SwiftExtensions

fileprivate let kUserDefaultsServiceUUIDKey = "ServiceUUIDKey"
fileprivate let kUserDefaultsCharacteristicUUIDKey = "CharacteristicUUIDKey"

public struct DTUUID
{
    // MARK: - Properties -
    
    public static let serviceUuid: CBUUID = CBUUID(string: "91C68CED-A0D3-47D4-9FEF-6538BE9CA92C")
    public static let characteristicUuid: CBUUID = CBUUID(string: "7B9992F7-D2D5-4452-82E1-A1CE6CD2E4AD")
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    private init()
    {
        
    }
}
