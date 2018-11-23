//
//  DTCentralController.swift
//  DTBLECommunication
//
//  Created by EdenLi on 2018/8/15.
//  Copyright © 2018年 Darktt. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftExtensions

public class DTCentralController: UIViewController
{
    // MARK: - Properties -
    
    static public var centralController: DTCentralController {
        
        let viewController = DTCentralController.load(withName: "Central", identifier: "DTCentralController")
        
        return viewController
    }
    
    fileprivate lazy var centralManager: CBCentralManager = {
        
        let queue = DispatchQueue.main
        let manager = CBCentralManager(delegate: self, queue: queue)
        
        return manager
    }()
    
    fileprivate var peripheral: CBPeripheral?
    fileprivate var service: CBService?
    fileprivate var characteristic: CBCharacteristic?
    
    @IBOutlet fileprivate weak var listButton: UIButton!
    @IBOutlet fileprivate weak var test1Button: UIButton!
    @IBOutlet fileprivate weak var test2Button: UIButton!
    
    // MARK: View Live Cycle
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.startDiscover()
    }
    
    public override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
    }
    
    public override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if self.centralManager.isScanning {
            
            self.centralManager.stopScan()
        }
        
        if let peripheral = self.peripheral {
            
            peripheral.delegate = nil
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let closeButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeAction(_:)))
        
        self.navigationItem.leftBarButtonItem = closeButtonItem
        
        self.listButton.setBackgroundImage(withColor: UIColor.iOS7Blue, for: .normal)
        self.listButton.addTarget(self, action: #selector(listAction(_:)), for: .touchUpInside)
        
        self.test1Button.isEnabled = false
        self.test1Button.setBackgroundImage(withColor: UIColor.deepFacebook, for: .normal)
        self.test1Button.addTarget(self, action: #selector(test1Action(_:)), for: .touchUpInside)
        
        self.test2Button.isEnabled = false
        self.test2Button.setBackgroundImage(withColor: UIColor.deepFacebook, for: .normal)
        self.test2Button.addTarget(self, action: #selector(test2Action(_:)), for: .touchUpInside)
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

fileprivate extension DTCentralController
{
    @objc
    fileprivate func closeAction(_ sender: UIBarButtonItem)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc
    fileprivate func listAction(_ sender: UIButton)
    {
        let viewController = DTPeripheralsController.peripheralsController
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    fileprivate func test1Action(_ sender: UIButton)
    {
        "你好".data(using: .utf8).unwrapped {
            
            self.peripheral?.writeValue($0, for: self.characteristic!, type: .withResponse)
        }
    }
    
    @objc
    fileprivate func test2Action(_ sender: UIButton)
    {
        "台灣傳奇高山茶一二三四五六七八九十零一二三四五六七八九十零,1,500".data(using: .utf8).unwrapped {
            
            self.peripheral?.writeValue($0, for: self.characteristic!, type: .withResponse)
        }
    }
}

// MARK: - Private Methods -

fileprivate extension DTCentralController
{
    fileprivate func startDiscover()
    {
        let options: Dictionary<String, Any> = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        let services: Array<CBUUID> = [DTUUID.serviceUuid]
        
        self.centralManager.scanForPeripherals(withServices: services, options: options)
    }
    
    fileprivate func connect(for peripheral: CBPeripheral)
    {
        let options: Dictionary<String, Any> = [CBConnectPeripheralOptionNotifyOnConnectionKey: true, CBConnectPeripheralOptionNotifyOnNotificationKey: true, CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
     
        self.peripheral = peripheral
        self.centralManager.connect(peripheral, options: options)
    }
    
    fileprivate func discoverService()
    {
        let services = [DTUUID.serviceUuid]
        
        self.peripheral?.delegate = self
        self.peripheral?.discoverServices(services)
    }
    
    fileprivate func discoverCharacteristics(for service: CBService)
    {
        let characteristicUUIDs = DTUUID.characteristicUuids
        
        self.service = service
        self.peripheral?.discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    fileprivate func subscribeCharacteristic(for characteristic: CBCharacteristic)
    {
        self.peripheral?.setNotifyValue(true, for: characteristic)
    }
    
    fileprivate func logValue(_ value: Data?)
    {
        if let value = value, let string = String(data: value, encoding: .utf8) {
            
            DTLog(string)
        }
    }
}

// MARK: - Delegate Methods -
// MARK: #CBCentralManagerDelegate

extension DTCentralController: CBCentralManagerDelegate
{
    public func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        let state: CBManagerState = central.state
        
        if state == .poweredOn {
            
            self.startDiscover()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        let key: DictionaryKey<String, String> = String.key(CBAdvertisementDataLocalNameKey)
        
        if let name: String = advertisementData[key] {
            
            let rssiValue: String = RSSI.intValue.format("%td")
            DTLog("Discovered peripheral:" + name + " rssi: " + rssiValue)
            
            central.stopScan()
            self.connect(for: peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        DTLog("Connected peripheral:" + (peripheral.name ?? "Null"))
        
        self.discoverService()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        DTLog("Disconnected peripheral:" + (peripheral.name ?? "Null"))
        
        error.unwrapped {
            
            DTLog("Error reason: \($0.localizedDescription)")
        }
    }
}

extension DTCentralController: CBPeripheralDelegate
{
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?)
    {
        DTLog("Update rssi: \(RSSI)")
        
        if let error = error {
            
            DTLog("Error reason: \(error.localizedDescription)")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        DTLog("Discover services...")
        
        if let error = error {
            
            DTLog("Error reason: \(error.localizedDescription)")
            return
        }
        
        if let services: Array<CBService> = peripheral.services, let service: CBService = services.first {
            
            DTLog("Found service: \(service)")
            
            self.discoverCharacteristics(for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        DTLog("Discover characteristics...")
        
        if let error = error {
            
            DTLog("Error reason: \(error.localizedDescription)")
            return
        }
        
        if let characteristics: Array<CBCharacteristic> = service.characteristics {
            
            DTLog("Found characteristic: \(characteristics)")
            
            [self.test1Button, self.test2Button].forEach { $0?.isEnabled = true }
            
            self.characteristic = characteristics.first!
            self.subscribeCharacteristic(for: characteristics.last!)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        if let error = error {
            
            DTLog("Notify characteristic failed, reason: " + error.localizedDescription)
            return
        }
        
        DTLog("Success to notify characteristic.")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        guard let error = error else {
            
            return
        }
        
        DTLog("Write data to characteristic failed, reason: " + error.localizedDescription)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if let error = error {
            
            DTLog("Update data to characteristic failed, reason: " + error.localizedDescription)
            return
        }
        
        self.logValue(characteristic.value)
    }
}
