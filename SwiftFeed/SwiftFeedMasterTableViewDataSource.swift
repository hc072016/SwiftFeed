//
//  SwiftFeedMasterTableViewDataSource.swift
//  SwiftFeed
//
//  Created by Howie C on 7/10/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedMasterTableViewDataSource: NSObject, NewsFeedMasterTableViewDataSource {
    
    var newsFeedMasterTableViewModel: NewsFeedMasterTableViewModel
    
    init(newsFeedMasterTableViewModel: NewsFeedMasterTableViewModel) {
        self.newsFeedMasterTableViewModel = newsFeedMasterTableViewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeedMasterTableViewModel.newsFeedCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let it crash if the downcast is not successful; ensure the correct cell type used
        let swiftFeedMasterTableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier(), for: indexPath) as! SwiftFeedMasterTableViewCell
        let newsfeed = newsFeedMasterTableViewModel.newsFeed(atIndexPath: indexPath)
        swiftFeedMasterTableViewCell.title = newsfeed.title
        if let thumbnail = newsfeed.thumbnail {
            if let data = thumbnail.data {
                swiftFeedMasterTableViewCell.thumbnailImage = UIImage(data: data)
            } else {
                swiftFeedMasterTableViewCell.thumbnailImage = nil
                if !tableView.isDragging && !tableView.isDecelerating {
                    newsFeedMasterTableViewModel.loadThumbnail(atIndexPath: indexPath) { (data, error) in
                        if error == nil {
                            DispatchQueue.main.async { [weak self, weak tableView] in
                                // read in the main queue to prevent race condiction
                                // check if the list is updated while downloading
                                if let indexPath = self?.newsFeedMasterTableViewModel.indexPath(forIDPath: newsfeed.id + "." + thumbnail.id) {
                                    if let tableViewCell = tableView?.cellForRow(at: indexPath) {
                                        // let it crash if the downcast is not successful; ensure the correct cell type used
                                        let swiftFeedMasterTableViewCell = tableViewCell as! SwiftFeedMasterTableViewCell
                                        swiftFeedMasterTableViewCell.thumbnailImage = UIImage(data: data)
                                    } else {
                                        // it means the cell is not visible on screen
                                        // test if .fade animation is ok; saw bugs in the past
                                        tableView?.reloadRows(at: [indexPath], with: .none)
                                    }
                                }
                            }
                        } else {
                            print("indexPath: \(indexPath) – " + String(describing: error))
                        }
                    }
                }
            }
        } else {
            swiftFeedMasterTableViewCell.thumbnailImage = nil
        }
        return swiftFeedMasterTableViewCell
    }
    
    
    func cellClass() -> AnyClass {
        return SwiftFeedMasterTableViewCell.self
    }
    
    func tableViewCellReuseIdentifier() -> String {
        return String(describing: SwiftFeedMasterTableViewCell.self)
    }
    
}
