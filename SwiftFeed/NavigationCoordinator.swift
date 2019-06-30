//
//  NavigationCoordinator.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class NavigationCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
}
