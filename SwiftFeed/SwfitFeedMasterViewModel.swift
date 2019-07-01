//
//  SwfitFeedMasterViewModel.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import UIKit

class SwiftFeedMasterViewModel: NSObject, NewsFeedMasterViewModel {
    
    private var newsFeedArray: [NewsFeed] = []
    private let newsFeedContext: NewsFeedContext
    
    init(model newsFeedContext: NewsFeedContext) {
        self.newsFeedContext = newsFeedContext
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: tableViewCellReuseIdentifier(), for: indexPath)
        tableViewCell.textLabel?.text = newsFeedArray[indexPath.row].title
        tableViewCell.textLabel?.adjustsFontSizeToFitWidth = true
        return tableViewCell
    }
    
    func title() -> String {
        return "Swift News"
    }
    
    func tableViewCellReuseIdentifier() -> String {
        return String(describing: SwiftFeedMasterTableViewCell.self)
    }
    
    func refresh(withCompletionHandler completionHandler: @escaping (Error?) -> Void) {
        newsFeedContext.fetchNewsFeeds { (newsFeedArray, error) in
            if error == nil {
                self.newsFeedArray = newsFeedArray
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }
    
    func swiftFeed(atIndexPath indexPath: IndexPath) -> NewsFeed {
        return newsFeedArray[indexPath.row]
    }
    
}
