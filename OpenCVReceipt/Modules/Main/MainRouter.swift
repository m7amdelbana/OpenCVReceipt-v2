//
//  MainRouter.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/24/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit

class MainRouter {

    static func assembleModule() -> UIViewController {
        let view: MainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainController") as! MainController
        return view
    }
}
