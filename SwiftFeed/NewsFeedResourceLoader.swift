//
//  NewsFeedResourceLoader.swift
//  SwiftFeed
//
//  Created by Howie C on 7/1/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

private enum NewsFeedResourceLoaderError: Error {
    case invalidIDPath
    case newsFeedResourceLoaderDeallocated
    case loadingAlreadyInProgress
}

class NewsFeedResourceLoader {
    
    private let newsFeedContext: NewsFeedContext
    private let loadingOperationQueue = OperationQueue()
    private var loadingProgressDictionary: [String : Operation] = [:]
    /*
     * When using a dispatch queue attribute @a attr specifying a QoS class (derived
     * from the result of dispatch_queue_attr_make_with_qos_class()), passing the
     * result of dispatch_get_global_queue() in @a target will ignore the QoS class
     * of that global queue and will use the global queue with the QoS class
     * specified by attr instead.
    */
    // let dataAccessQueue = DispatchQueue(__label: "label", attr: nil, queue: DispatchQueue.global(qos: .userInteractive))
    // the libdispatch source code shows that a global queue with qos parameter or default is supplied if not specified in target parameter
    private let dataAccessQueue = DispatchQueue(label: "com.SwiftFeed.NewsFeedResourceLoader", qos: .userInteractive)
    
    init(newsFeedContext: NewsFeedContext) {
        self.newsFeedContext = newsFeedContext
    }
    
    func loadThumbnail(withIDPath idPath: String, completionHandler: @escaping (Data, Error?) -> Void) {
        dataAccessQueue.async { [weak self] in
            if let self = self {
                if self.loadingProgressDictionary[idPath] == nil {
                    if idPath.count > 0, let thumbnailID = idPath.split(separator: ".").last.map(String.init) {
                        let loadThumbnailOperation = BlockOperation { [weak self] in
                            if let self = self {
                                self.newsFeedContext.fetchNewsFeedThumbnail(withThumbnailID: thumbnailID) { [weak self] (data, error) in
                                    if let self = self {
                                        self.dataAccessQueue.async {
                                            if error == nil {
                                                completionHandler(data, nil)
                                            } else {
                                                completionHandler(Data(), error)
                                            }
                                            self.loadingProgressDictionary[idPath] = nil
                                        }
                                    } else {
                                        completionHandler(Data(), NewsFeedResourceLoaderError.newsFeedResourceLoaderDeallocated)
                                    }
                                }
                            } else {
                                // operation queue and operation are retained by the OS even 'self' is deallocated
                                // without checking 'self', if 'self' is deallocated, completionHandler might not be executed
                                completionHandler(Data(), NewsFeedResourceLoaderError.newsFeedResourceLoaderDeallocated)
                            }
                        }
                        self.loadingProgressDictionary[idPath] = loadThumbnailOperation
                        self.loadingOperationQueue.addOperation(loadThumbnailOperation)
                    } else {
                        completionHandler(Data(), NewsFeedResourceLoaderError.invalidIDPath)
                    }
                } else {
                    completionHandler(Data(), NewsFeedResourceLoaderError.loadingAlreadyInProgress)
                }
            } else {
                completionHandler(Data(), NewsFeedResourceLoaderError.newsFeedResourceLoaderDeallocated)
            }
        }
    }
    
    func cancel() {
        loadingOperationQueue.cancelAllOperations()
        loadingProgressDictionary = [:]
    }
}
