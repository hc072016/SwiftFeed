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
        let newsFeedContext = NewsFeedContext(newsFeedGateway: NewsFeedNetwork(newsFeedFactory: SwiftFeedFactory()))
        swiftFeedMasterViewModel = SwiftFeedMasterViewModel(newsFeedContext: newsFeedContext)
        newsFeedMasterViewController.newsFeedMasterViewModel = swiftFeedMasterViewModel
        newsFeedMasterViewController.newsFeedMasterTableViewDataSource = SwiftFeedMasterTableViewDataSource(newsFeedMasterTableViewModel: swiftFeedMasterViewModel)
        newsFeedMasterViewController.newsFeedMasterTableViewDelegate = SwiftFeedMasterTableViewDelegate(newsFeedMasterTableViewModel: swiftFeedMasterViewModel)
        newsFeedMasterViewController.delegate = self
        navigationController.pushViewController(newsFeedMasterViewController, animated: false)
    }
    
    func tableViewDidSelectRow(atIndexPath indexPath: IndexPath) {
        let swiftFeed = swiftFeedMasterViewModel.newsFeed(atIndexPath: indexPath)
        let feedDetailViewController = NewsFeedDetailViewController()
        swiftFeedDetailViewModel = SwiftFeedDetailViewModel(model: swiftFeed)
        feedDetailViewController.newsFeedDetailViewModel = swiftFeedDetailViewModel
        navigationController.pushViewController(feedDetailViewController, animated: true)
    }
    
}
