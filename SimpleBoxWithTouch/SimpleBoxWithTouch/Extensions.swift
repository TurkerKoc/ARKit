//
//  Extensions.swift
//  SimpleBoxWithTouch
//
//  Created by Turker Koc on 1.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat
{
    static func random() -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor
{
    static func random() -> UIColor
    {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }
}
