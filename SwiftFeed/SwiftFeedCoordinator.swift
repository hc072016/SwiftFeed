//
//  SwiftFeedCoordinator.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedCoordinator: NavigationCoordinator, FeedMasterViewControllerDelegate {
    override func start() {
        let feedMasterViewController = FeedMasterViewController()
        feedMasterViewController.delegate = self
        feedMasterViewController.title = "Swift News"
        navigationController.pushViewController(feedMasterViewController, animated: false)
    }
    
    func didSelectString(_ string: String, atIndexPath indexPath: IndexPath) {
        navigationController.pushViewController(FeedDetailViewController(), animated: true)
    }
}
