//
//  UIView+Extensions.swift
//  OpenCVReceipt
//
//  Created by Mohamed Elbana on 3/23/20.
//  Copyright © 2020 Mohamed Elbana. All rights reserved.
//

import UIKit

extension UIImage {
    
    func fixImageOrientation() -> UIImage? {
        var flip: Bool = false
        var isRotatedBy90: Bool = false
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.rotated(by: CGFloat(Double.pi));
        case .left, .leftMirrored:
            transform = transform.rotated(by: CGFloat(Double.pi));
            isRotatedBy90 = true
        case .right, .rightMirrored:
            transform = transform.rotated(by: CGFloat(-Double.pi));
            isRotatedBy90 = true
        case .up, .upMirrored:
            break
        @unknown default:
            print("Error")
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            flip = true
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            flip = true
        default:
            break;
        }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint(x:0, y:0), size: size))
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0);
        
        var yFlip: CGFloat
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap!.scaleBy(x: yFlip, y: -1.0)
        
        if isRotatedBy90 {
            bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.height,height: size.width))
        } else {
            bitmap?.draw(self.cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width,height: size.height))
        }
        
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return fixedImage
    }
}
