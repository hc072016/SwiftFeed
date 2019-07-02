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
    
    func getNewsFeedThumbnail(withThumbnailID thumbnailID: String, completionHandler: @escaping (Data, Error?) -> Void)
    
    func cancel()
    
}

// dependency inversion; implement later
protocol NewsFeedCache {
    
    func getNewsFeeds(withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void)
    
    func cancel()
}

private enum NewsFeedContextError: Error {
    case invalidNewsFeedData
}

class NewsFeedContext {
    var newsFeedGateway: NewsFeedGateway
    var newsFeedCache: NewsFeedCache?
    
    init(newsFeedGateway: NewsFeedGateway) {
        self.newsFeedGateway = newsFeedGateway
    }
    
    func fetchNewsFeeds(withCompletionHandler completionHandler: @escaping ([NewsFeed], Error?) -> Void) {
        if let newsFeedCache = newsFeedCache {
            newsFeedCache.getNewsFeeds { (newsFeedArray, error) in
                // check with cache first...
            }
        } else {
            // even by using an intermediate local variable referencing a function, closures would still capture 'self'
            // by making a closure, the other closure does not need to capture 'self'
            let makeNewsFeeds = makeNewsFeedsClosure()
            newsFeedGateway.getNewsFeeds { (newsFeedArray, error) in
                DispatchQueue.global(qos: .userInitiated).async {
                    //especially ensures that the parsing is not in main queue
                    if error != nil {
                        completionHandler([], error)
                    } else {
                        do {
                            // completionHandler could still get executed when this closure executed even 'self' is released
                            completionHandler(try makeNewsFeeds(newsFeedArray), nil)
                        } catch {
                            completionHandler([], error)
                        }
                    }
                }
            }
        }
    }
    
    func fetchNewsFeedThumbnail(withThumbnailID thumbnailID: String, completionHandler: @escaping (Data, Error?) -> Void) {
        newsFeedGateway.getNewsFeedThumbnail(withThumbnailID: thumbnailID, completionHandler: completionHandler)
    }
    
    private func makeNewsFeedsClosure() -> (Array<Dictionary<String, Any>>) throws -> [NewsFeed] {
        return { newsFeedArray in
            return try newsFeedArray.map({ (newsFeedDictionary) -> NewsFeed in
                if let id = newsFeedDictionary["id"] as? String, let title = newsFeedDictionary["title"] as? String, let text = newsFeedDictionary["text"] as? String {
                    var newsFeed: NewsFeed! = nil
                    if let thumbnailID = newsFeedDictionary["thumbnailID"] {
                        if let thumbnailID = thumbnailID as? String, let thumbnailWidth = newsFeedDictionary["thumbnailWidth"] as? UInt, let thumbnailHeight = newsFeedDictionary["thumbnailHeight"] as? UInt {
                            newsFeed = NewsFeed(id: id, title: title, text: text, thumbnail: Thumbnail(id: thumbnailID, width: thumbnailWidth, height: thumbnailHeight))
                        } else {
                            throw NewsFeedContextError.invalidNewsFeedData
                        }
                    } else {
                        newsFeed = NewsFeed(id: id, title: title, text: text)
                    }
                    return newsFeed
                } else {
                    throw NewsFeedContextError.invalidNewsFeedData
                }
            })
        }
    }
    
    func cancel() {
        
    }
    
}
