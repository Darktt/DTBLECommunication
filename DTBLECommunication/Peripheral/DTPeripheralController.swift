//
//  DTPeripheralController.swift
//  DTBLECommunication
//
//  Created by EdenLi on 2018/8/15.
//  Copyright © 2018年 Darktt. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftExtensions

public class DTPeripheralController: UIViewController
{
    // MARK: - Properties -
    
    static public var peripheralController: DTPeripheralController {
        
        let viewController = DTPeripheralController.load(withName: "Peripheral", identifier: "DTPeripheralController")
        
        return viewController
    }
    
    fileprivate lazy var peripheralManager: CBPeripheralManager = {
        
        let queue = DispatchQueue.main
        let manager = CBPeripheralManager(delegate: self, queue: queue)
        
        return manager
    }()
    
    fileprivate var subscribedCentral: CBCentral?
    fileprivate var characteristic: CBMutableCharacteristic?
    
    // MARK: - Methods -
    // MARK: View Live Cycle
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
    }
    
    public override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        self.peripheralManager.stopAdvertising()
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let closeButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeAction(_:)))
        
        self.navigationItem.leftBarButtonItem = closeButtonItem
        
        // Trigger lazy property for initial instance, wait the power on state.
        let _ = self.peripheralManager
    }
    
    deinit
    {
        
    }

    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Actions -

fileprivate extension DTPeripheralController
{
    @objc
    fileprivate func closeAction(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Delegate Methods -

fileprivate extension DTPeripheralController
{
    fileprivate func setupService()
    {
        let authStatus = CBPeripheralManager.authorizationStatus()
        
        DTLog(authStatus)
        
        let characteristic = CBMutableCharacteristic(type: DTUUID.characteristicUuid, properties: [.notify, .read, .write], value: nil, permissions: [.readable, .writeable])
        
        let service = CBMutableService(type: DTUUID.serviceUuid, primary: true)
        service.characteristics = [characteristic]
        
        self.characteristic = characteristic
        self.peripheralManager.add(service)
    }
    
    fileprivate func startAdvertising()
    {
        var advertisementData: Dictionary<String, Any> = [CBAdvertisementDataLocalNameKey: "客顯"];
        advertisementData[CBAdvertisementDataServiceUUIDsKey] = [DTUUID.serviceUuid]
        
        self.peripheralManager.startAdvertising(advertisementData)
    }
    
    fileprivate func sendMessage(with string: String)
    {
        string.data(using: .utf8).unwrapped {
            
            self.peripheralManager.updateValue($0, for: self.characteristic!, onSubscribedCentrals: [self.subscribedCentral!])
        }
        
        if let data: Data = string.data(using: .utf8),
            let characteristic = self.characteristic,
            let central = self.subscribedCentral {
            
            self.peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: [central])
        }
    }
    
    fileprivate func logValue(_ value: Data?)
    {
        if let value = value, let string = String(data: value, encoding: .utf8) {
            
            DTLog(string)
        }
    }
}

// MARK: - Delegate Methods -

extension DTPeripheralController: CBPeripheralManagerDelegate
{
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        let state: CBManagerState = peripheral.state
        
        if state == .poweredOn {
            
            self.setupService()
        }
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?)
    {
        guard let error = error else {
            
            DTLog("Success add service.....")
            self.startAdvertising()
            return
        }
        
        DTLog("Failed add service, reason: " + error.localizedDescription)
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        guard let error = error else {
            
            DTLog("Start advertising.....")
            return
        }
        
        self.presentErrorAlert(error: error)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    {
        DTLog("Central subscribed to characteristic")
        
        if peripheral.isAdvertising {
            
            peripheral.stopAdvertising()
        }
        
        self.logValue(characteristic.value)
        self.subscribedCentral = central
        self.sendMessage(with: "Hello!")
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        DTLog("Central unsubscribed from characteristic")
        
        self.startAdvertising()
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    {
        let central: CBCentral = request.central
        let characteristic: CBCharacteristic = request.characteristic
        
        DTLog("Central: \(central)")
        DTLog("Characteristic: \(characteristic)")
        
        request.value = "Hello".data(using: .utf8)
        peripheral.respond(to: request, withResult: .success)
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    {
        
    }
}