//
//  NewsFeedNetwork.swift
//  SwiftFeed
//
//  Created by Howie C on 6/26/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

// dependency inversion
protocol NewsFeedFactory {
    
    func makeNewsFeeds(data: Data) throws -> Array<Dictionary<String, Any>>
    
    func makeNewsFeedsClosure() -> (Data) throws -> Array<Dictionary<String, Any>>
    
}

private enum NewsFeedNetworkError: Error {
    case notFound
    case invalidURL
    case nilData
    case invalidHTTPResponse
}

class NewsFeedNetwork: NewsFeedGateway {
    
    static private let newsFeedURLString = "https://www.reddit.com/r/swift/.json"
    static private let newsFeedThumbnailCommonURLPrefixString = "https://b.thumbs.redditmedia.com/"
    static private let newsFeedThumbnailCommonURLSuffixString = ".jpg"
    var newsFeedFactory: NewsFeedFactory
    
    init(newsFeedFactory: NewsFeedFactory) {
        self.newsFeedFactory = newsFeedFactory
    }
    
    func getResource(withURLString urlString: String, completionHandler: @escaping (Data, Error?) -> Void) {
        if let url = URL(string: urlString) {
            let urlSessionDataTask = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                // not in main thread here!
                //if !Thread.isMainThread {
                //    print("not in main thread")
                //}
                if error != nil {
                    completionHandler(Data(), error)
                } else {
                    if let httpURLResponse = urlResponse as? HTTPURLResponse {
                        if httpURLResponse.statusCode == 200 {
                            if let data = data {
                                completionHandler(data, nil)
                            } else {
                                completionHandler(Data(), NewsFeedNetworkError.nilData)
                            }
                        } else {
                            completionHandler(Data(), NewsFeedNetworkError.notFound)
                        }
                    } else {
                        completionHandler(Data(), NewsFeedNetworkError.invalidHTTPResponse)
                    }
                }
            }
            urlSessionDataTask.resume()
        } else {
            completionHandler(Data(), NewsFeedNetworkError.invalidURL)
        }
    }
    
    func getNewsFeeds(withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void) {
        // so that the closure using makeNewsFeeds() does not need to retain 'self'
        let makeNewsFeeds = newsFeedFactory.makeNewsFeedsClosure()
        getResource(withURLString: NewsFeedNetwork.newsFeedURLString) { (data, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                //especially ensures that the parsing is not in main queue
                if error == nil {
                    do {
                        completionHandler(try makeNewsFeeds(data), nil)
                    } catch {
                        completionHandler([], error)
                    }
                } else {
                    completionHandler([], error)
                }
            }
        }
    }
    
    func getNewsFeedThumbnail(withThumbnailID thumbnailID: String, completionHandler: @escaping (Data, Error?) -> Void) {
        let thumbnailURLString = NewsFeedNetwork.newsFeedThumbnailCommonURLPrefixString + thumbnailID + NewsFeedNetwork.newsFeedThumbnailCommonURLSuffixString
        getResource(withURLString: thumbnailURLString) { (data, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                if error == nil {
                    completionHandler(data, nil)
                } else {
                    completionHandler(Data(), error)
                }
            }
        }
    }
    
    func cancel() {
        // to-do
    }
    
    deinit {
        cancel()
    }
}
