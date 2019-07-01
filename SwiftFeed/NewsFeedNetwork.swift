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
    
}

private enum NewsFeedNetworkError: Error {
    case invalidURL
    case nilData
}

class NewsFeedNetwork: NewsFeedGateway {
    
    static private let newsFeedURLString = "https://www.reddit.com/r/swift/.json"
    var newsFeedFactory: NewsFeedFactory
    var urlSessionDataTask: URLSessionDataTask?
    
    init(newsFeedFactory: NewsFeedFactory) {
        self.newsFeedFactory = newsFeedFactory
    }
    
    func getResource(withURLString urlString: String, completionHandler: @escaping (Data, Error?) -> Void) {
        if let url = URL(string: urlString) {
            urlSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
                // not in main thread here!
                /*
                if Thread.isMainThread {
                    print("main thread")
                } else {
                    print("not in main thread")
                    print(Thread.current)
                }
                */
                if error != nil {
                    completionHandler(Data(), error)
                } else {
                    if let data = data {
                        completionHandler(data, nil)
                    } else {
                        completionHandler(Data(), NewsFeedNetworkError.nilData)
                    }
                }
            })
            urlSessionDataTask?.resume()
        } else {
            completionHandler(Data(), NewsFeedNetworkError.invalidURL)
        }
    }
    
    func getNewsFeeds(withCompletionHandler completionHandler: @escaping (Array<Dictionary<String, Any>>, Error?) -> Void) {
        getResource(withURLString: NewsFeedNetwork.newsFeedURLString) { (data, error) in
            DispatchQueue.global(qos: .userInitiated).async {
                //especially ensures that the parsing is not in main queue
                if error != nil {
                    completionHandler([], error)
                } else {
                    do {
                        completionHandler(try self.newsFeedFactory.makeNewsFeeds(data: data), nil)
                    } catch {
                        completionHandler([], error)
                    }
                }
            }
        }
    }
    
    func cancel() {
        urlSessionDataTask?.cancel()
        urlSessionDataTask = nil
    }
    
    deinit {
        cancel()
    }
}
