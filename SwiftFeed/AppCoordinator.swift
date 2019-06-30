//
//  AppCoordinator.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class AppCoordinator: WindowCoordinator {
    
    override func start() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let swiftFeedCoordinator = SwiftFeedCoordinator(navigationController: navigationController)
        childCoordinators.append(swiftFeedCoordinator)
        swiftFeedCoordinator.start()
        window.makeKeyAndVisible()
    }
    
}
