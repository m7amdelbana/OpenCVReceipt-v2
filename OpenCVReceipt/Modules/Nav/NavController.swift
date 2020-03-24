//
//  NavController.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit

var NAV = NavController.shared

class NavController: UINavigationController {
    
    static var shared: NavController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NavController.shared = self
        NAV = NavController.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavController.shared = self
        NAV = NavController.shared
    }
}
