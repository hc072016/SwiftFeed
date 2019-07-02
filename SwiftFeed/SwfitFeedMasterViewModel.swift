//
//  SwfitFeedMasterViewModel.swift
//  SwiftFeed
//
//  Created by Howie C on 6/30/19.
//  Copyright © 2019 Howie C. All rights reserved.
//


// to do: import Foundation
import UIKit

private enum SwiftFeedMasterViewModelError: Error {
    case swiftFeedMasterViewModelDeallocated
    case indexOutOfRange
    case thumbnailNotAvailable
    case newsFeedsAreUpdatedAfterThumbnailRequest
}

// SwiftFeedMasterViewModel should be used in the main queuem so that table view and data can be in sync
class SwiftFeedMasterViewModel: NSObject, NewsFeedMasterViewModel {
    
    private var newsFeedArray: [SwiftFeedMasterViewNewsFeed] = []
    private let newsFeedContext: NewsFeedContext
    private let newsFeedResourceLoader: NewsFeedResourceLoader
    
    init(newsFeedContext: NewsFeedContext) {
        self.newsFeedContext = newsFeedContext
        newsFeedResourceLoader = NewsFeedResourceLoader(newsFeedContext: newsFeedContext)
    }
    
    func newsFeedCount() -> Int {
        return newsFeedArray.count
    }
    
    func newsFeed(atIndexPath indexPath: IndexPath) -> SwiftFeedMasterViewNewsFeed {
        return newsFeedArray[indexPath.row]
    }
    
    func rowHeight(AtIndexPath indexPath: IndexPath) -> CGFloat {
        // implement this one when not using auto layout
        return 0
    }
    
    func indexPath(forIDPath idPath: String) -> IndexPath? {
        let ids = idPath.split(separator: ".").map(String.init)
        if ids.count == 2, let rowIndex = newsFeedArray.firstIndex(where: { $0.id == ids[0] && $0.thumbnail?.id == ids[1]
        }) {
            return IndexPath(row: rowIndex, section: 0)
        } else {
            return nil
        }
    }
    
    func loadThumbnail(atIndexPath indexPath: IndexPath, withCompletionHandler completionHandler: @escaping (Data, Error?) -> Void) {
        let row = indexPath.row
        if row < newsFeedArray.count {
            let newsFeed = newsFeedArray[row]
            if let thumbnail = newsFeed.thumbnail {
                let newsFeedID = newsFeed.id
                let thumbnailID = thumbnail.id
                newsFeedResourceLoader.loadThumbnail(withIDPath: newsFeedID + "." + thumbnailID) { (data, error) in
                    if error == nil {
                        DispatchQueue.main.async { [weak self] in
                            // read newsFeedArray in main queue to prevent race condiction
                            if let rowIndex = self?.newsFeedArray.firstIndex(where: { $0.id == newsFeedID && $0.thumbnail?.id == thumbnailID
                            }) {
                                self?.newsFeedArray[rowIndex].thumbnail?.data = data
                                completionHandler(data, nil)
                            } else {
                                completionHandler(Data(), SwiftFeedMasterViewModelError.newsFeedsAreUpdatedAfterThumbnailRequest)
                            }
                        }
                    } else {
                        print("indexPath: \(indexPath) – " + String(describing: error))
                    }
                }
            } else {
                completionHandler(Data(), SwiftFeedMasterViewModelError.thumbnailNotAvailable)
            }
        } else {
            completionHandler(Data(), SwiftFeedMasterViewModelError.indexOutOfRange)
        }
    }
    
    func title() -> String {
        return "Swift News"
    }
    
    func reloadNewsFeeds(withCompletionHandler completionHandler: @escaping (Error?) -> Void) {
        newsFeedContext.fetchNewsFeeds { (newsFeedArray, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                if error == nil {
                    let swiftFeedMasterViewNewsFeeds = newsFeedArray.map({ (newsfeed) -> SwiftFeedMasterViewNewsFeed in
                        var swiftFeedMasterViewNewsFeed: SwiftFeedMasterViewNewsFeed! = nil
                        if let thumbnail = newsfeed.thumbnail {
                            swiftFeedMasterViewNewsFeed = SwiftFeedMasterViewNewsFeed(id: newsfeed.id, title: newsfeed.title, text: newsfeed.text, thumbnail: SwiftFeedMasterViewThumbnail(id: thumbnail.id, width: thumbnail.width, height: thumbnail.height))
                        } else {
                            swiftFeedMasterViewNewsFeed = SwiftFeedMasterViewNewsFeed(id: newsfeed.id, title: newsfeed.title, text: newsfeed.text)
                        }
                        return swiftFeedMasterViewNewsFeed
                    })
                    DispatchQueue.main.async { [weak self] in
                        if self != nil {
                            self?.newsFeedArray = swiftFeedMasterViewNewsFeeds
                            completionHandler(nil)
                        } else {
                            completionHandler(SwiftFeedMasterViewModelError.swiftFeedMasterViewModelDeallocated)
                        }
                    }
                } else {
                    completionHandler(error)
                }
            }
        }
    }
    
    func cancel() {
        
    }
    
}
