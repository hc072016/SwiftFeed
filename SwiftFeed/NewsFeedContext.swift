//
//  NewsFeedContext.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

// dependency inversion
protocol NewsFeedGateway {
    // use plain objects between layers
    func getNewsFeeds(withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void)
    
    func cancel()
    
}

private enum NewsFeedContextError: Error {
    case invalidNewsFeedData
}

class NewsFeedContext {
    var newsFeedGateway: NewsFeedGateway
    
    init(newsFeedGateway: NewsFeedGateway) {
        self.newsFeedGateway = newsFeedGateway
    }
    
    func fetchNewsFeed(withCompletionHandler completionHandler: @escaping ([NewsFeed], Error?) -> Void) {
        newsFeedGateway.getNewsFeeds { (newsFeedArray, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                //especially ensures that the parsing is not in main queue
                if error != nil {
                    completionHandler([], error)
                } else {
                    do {
                        completionHandler(try newsFeedArray.map({ (newsFeedDictionary) -> NewsFeed in
                            if let id = newsFeedDictionary["id"] as? String, let title = newsFeedDictionary["title"] as? String, let text = newsFeedDictionary["text"] as? String{
                                var newsFeed = NewsFeed(id: id, title: title, text: text)
                                if let thumbnailID = newsFeedDictionary["thumbnailID"] {
                                    if let thumbnailID = thumbnailID as? String, let thumbnailWidth = newsFeedDictionary["thumbnailWidth"] as? UInt, let thumbnailHeight = newsFeedDictionary["thumbnailHeight"] as? UInt {
                                        newsFeed.thumbnail = Thumbnail(id: thumbnailID, width: thumbnailWidth, height: thumbnailHeight)
                                    } else {
                                        throw NewsFeedContextError.invalidNewsFeedData
                                    }
                                }
                                return newsFeed
                            } else {
                                throw NewsFeedContextError.invalidNewsFeedData
                            }
                        }), nil)
                    } catch {
                        completionHandler([], error)
                    }
                }
            }
        }
    }
    
}
