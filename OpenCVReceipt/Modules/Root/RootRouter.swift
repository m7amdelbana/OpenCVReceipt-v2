//
//  RootRouter.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit

class RootRouter {
    
    func presentRootScreen(in window: UIWindow) {
        window.makeKeyAndVisible()
        window.rootViewController = MainRouter.assembleModule()
    }
    
    func resetApp() {
        let vc = MainRouter.assembleModule()
        rootVC(vc)
    }
    
    func rootVC(_ vc: UIViewController) {
        let appDlg = UIApplication.shared.delegate as? AppDelegate
        appDlg?.window?.rootViewController = vc
    }
}
