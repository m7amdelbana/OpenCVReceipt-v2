//
//  UINavigationController+Extension.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func setup() {
        let font = UIFont.systemFont(ofSize: 18)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]
        navigationBar.isTranslucent = false
    }
}
