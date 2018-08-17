//
//  ViewController.swift
//  DTBLECommunication
//
//  Created by EdenLi on 2018/8/15.
//  Copyright © 2018年 Darktt. All rights reserved.
//

import UIKit
import SwiftExtensions

class ViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension ViewController
{
    @objc @IBAction
    private func launchCentralAction(_ sender: UIButton)
    {
        let viewController = DTCentralController.centralController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc @IBAction
    private func launchPeripheralAction(_ sender: UIButton)
    {
        let viewController = DTPeripheralController.peripheralController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
}
