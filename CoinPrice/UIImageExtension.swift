//
//  UIImageExtension.swift
//  CoinPrice
//
//  Created by User on 2017. 11. 6..
//  Copyright © 2017년 jungho. All rights reserved.
//

import UIKit

extension UIImage {
    class func createImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
