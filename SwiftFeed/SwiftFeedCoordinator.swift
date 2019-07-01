//
//  SwiftFeedCoordinator.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedCoordinator: NavigationCoordinator, NewsFeedMasterViewControllerDelegate {
    
    var swiftFeedMasterViewModel: SwiftFeedMasterViewModel!
    var swiftFeedDetailViewModel: SwiftFeedDetailViewModel!
    
    
    override func start() {
        let newsFeedMasterViewController = NewsFeedMasterViewController()
        swiftFeedMasterViewModel = SwiftFeedMasterViewModel(model: NewsFeedContext(newsFeedGateway: NewsFeedNetwork(newsFeedFactory: SwiftFeedFactory())))
        newsFeedMasterViewController.newsFeedMasterViewModel = swiftFeedMasterViewModel
        newsFeedMasterViewController.newsFeedMasterTableViewDelegate = SwiftFeedMasterViewDelegate(dataSource: swiftFeedMasterViewModel)
        newsFeedMasterViewController.delegate = self
        navigationController.pushViewController(newsFeedMasterViewController, animated: false)
    }
    
    func tableViewDidSelectRow(atIndexPath indexPath: IndexPath) {
        let swiftFeed = swiftFeedMasterViewModel.swiftFeed(atIndexPath: indexPath)
        let feedDetailViewController = NewsFeedDetailViewController()
        swiftFeedDetailViewModel = SwiftFeedDetailViewModel(model: swiftFeed)
        feedDetailViewController.newsFeedDetailViewModel = swiftFeedDetailViewModel
        navigationController.pushViewController(feedDetailViewController, animated: true)
    }
    
}
