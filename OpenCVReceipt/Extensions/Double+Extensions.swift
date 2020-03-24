//
//  Double+Extensions.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/24/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
