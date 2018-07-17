//
//  TabBarController.swift
//  CoinPrice
//
//  Created by User on 2018. 4. 29..
//  Copyright © 2018년 jungho. All rights reserved.
//

import Foundation
import UIKit
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    // Do all your subclassing as a regular UITabBarController.
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedViewController = viewControllers?[0]
        tabBar.unselectedItemTintColor = UIColor.darkGray.withAlphaComponent(0.6)
        setSwipeAnimation(type: SwipeAnimationType.sideBySide)
        //setTapAnimation(type: SwipeAnimationType.overlap)
        setDiagonalSwipe(enabled: false)
        setTabBarSwipe(enabled: true)

  
    }
}
