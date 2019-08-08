//
//  DTPeripheralsController.swift
//  DTBLECommunication
//
//  Created by EdenLi on 2018/11/23.
//  Copyright © 2018年 Darktt. All rights reserved.
//

import UIKit
import CoreBluetooth
import SwiftExtensions

public class DTPeripheralsController: UIViewController
{
    // MARK: - Properties -
    
    public static var peripheralsController: DTPeripheralsController {
        
        let viewController = DTPeripheralsController.load(withName: "Central", identifier: "DTPeripheralsController")
        
        return viewController
    }
    
    fileprivate lazy var centralManager: CBCentralManager = {
        
        let queue = DispatchQueue.main
        let manager = CBCentralManager(delegate: self, queue: queue)
        
        return manager
    }()
    
    fileprivate var peripherals: Array<CBPeripheral> = []
    fileprivate weak var connectedPeripheral: CBPeripheral?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
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
        
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.setupNavigationItems()
        let _ = self.centralManager
    }
    
    deinit
    {
        
    }
}

// MARK: - Actions -
fileprivate extension DTPeripheralsController
{
    @objc
    func discoverPeripheralsAction(_ sender: UIBarButtonItem)
    {
        if self.centralManager.isScanning {
            
            DTLog("Stop scan.")
            
            self.centralManager.stopScan()
            return
        }
        
        DTLog("Start scanning")
        
        let serviceUUIDs = ["180F", "180A", "6675E16C-F36D-4567-BB55-6B51E27A23E5", "ADDC3E26-4AA5-4C1A-8A6A-735DB4E01C6C", "BBE87709-5B89-4433-AB7F-8B8EEF0D8E37", "21C50462-67CB-63A3-5C4C-82B5B9939AEB", "2BBE7F7C-7304-4466-8407-8EAF89F8CE45", "C7261110-F425-447A-A1BD-9D7246768BD8"]
        
        let services: Array<CBUUID> = serviceUUIDs.map { CBUUID(string: $0) }
        
        let options: Dictionary<String, Any> = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        
        self.centralManager.scanForPeripherals(withServices: services, options: options)
    }
}

// MARK: - Private Methods -
fileprivate extension DTPeripheralsController
{
    func setupNavigationItems()
    {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(discoverPeripheralsAction(_:)))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
}

// MARK: - Delegate Methods -
// MARK: #UITableViewDataSource
extension DTPeripheralsController: UITableViewDataSource
{
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.peripherals.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        let peripheral = self.peripherals[indexPath.row]
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel.unwrapped {
            
            $0.text = peripheral.name
        }
        
        cell?.detailTextLabel.unwrapped {
            
            $0.text = peripheral.identifier.uuidString
        }
        
        return cell!
    }
}

// MARK: #UITableViewDelegate
extension DTPeripheralsController: UITableViewDelegate
{
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let peripheral = self.peripherals[indexPath.row]
        let options: Dictionary<String, Any> = [CBConnectPeripheralOptionNotifyOnConnectionKey: true, CBConnectPeripheralOptionNotifyOnNotificationKey: true, CBConnectPeripheralOptionNotifyOnDisconnectionKey: true]
        
        self.centralManager.connect(peripheral, options: options)
    }
}

// MARK: #CBCentralManagerDelegate
extension DTPeripheralsController: CBCentralManagerDelegate
{
    public func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        let state: CBManagerState = central.state
        
        guard let rightBarButtonItem: UIBarButtonItem = self.navigationItem.rightBarButtonItem else {
            
            return
        }
        
        let enabled: Bool = (state == .poweredOn)
        
        rightBarButtonItem.isEnabled = enabled
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if self.peripherals.contains(peripheral) {
            
            return
        }
        
        self.peripherals += peripheral
        self.tableView.reloadData()
        
        let serviceUUIDKey: DictionaryKey<String, CBUUID> = CBUUID.key(CBAdvertisementDataServiceDataKey)
        let manufacturerKey: DictionaryKey<String, Data> = Data.key(CBAdvertisementDataManufacturerDataKey)
        
        DTLog("*********************************************")
        DTLog(peripheral.name ?? "nil")
        DTLog("Adverting Data: \(advertisementData)")
        
        if let serviceUUID = advertisementData[serviceUUIDKey] {
            
            DTLog("Service: \(serviceUUID.uuidString)")
        }
        
        if let manufacturer = advertisementData[manufacturerKey] {
            
            DTLog("Manfacturer: \(manufacturer.debugHexString)")
            
            if let utf8String = String(data: manufacturer, encoding: .utf8) {
                
                DTLog("\t\t(UTF8)\(utf8String)\n")
            }
            
            if let asciiString = String(data: manufacturer, encoding: .ascii) {
                
                DTLog("\t\t(ASCII)\(asciiString)\n")
            }
        }
        DTLog("*********************************************")
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        peripheral.delegate = self
        peripheral.discoverServices([])
        
        self.connectedPeripheral = peripheral
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        DTLog("[Failed] failed to connect peripheral.")
    }
}

extension DTPeripheralsController: CBPeripheralDelegate
{
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        DTLog("*********************************************")
        
        if let error = error as? CustomNSError {
            
            DTLog("Failed to discover services.")
            DTLog("Reason: \(error.errorCode)\(error.localizedDescription)")
            return
        }
        
        DTLog("Dicovered services")
        
        peripheral.services.unwrapped {
            
            let uuidStrings: Array<String> = $0.map { $0.uuid.uuidString }
            
            DTLog("Service uuids: \(uuidStrings)");
        }
        
        DTLog("*********************************************")
    }
}
