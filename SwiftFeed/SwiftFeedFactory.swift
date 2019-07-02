//
//  SwiftFeedFactory.swift
//  SwiftFeed
//
//  Created by Howie C on 6/27/19.
//  Copyright © 2019 Howie C. All rights reserved.
//

import Foundation

// immediate object to perform parsing
private struct CodableNewsFeeds: Decodable {
    
    var newsFeedArray: [Dictionary<String, Any>]
    
    enum Level00Keys: CodingKey {
        case data
    }
    
    enum Level01Keys: CodingKey {
        case children
    }
    
    enum Level02Keys: CodingKey {
        case data
    }
    
    enum Level03Keys: String, CodingKey {
        case id
        case title
        case text = "selftext"
        case thumbnailURLString = "thumbnail"
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
    
    init(from decoder: Decoder) throws {
        let level00Container = try decoder.container(keyedBy: Level00Keys.self)
        let level01Container = try level00Container.nestedContainer(keyedBy: Level01Keys.self, forKey: .data)
        var level02Container = try level01Container.nestedUnkeyedContainer(forKey: .children)
        newsFeedArray = []
        while !level02Container.isAtEnd {
            var newsFeedDictionary: [String : Any] = [:]
            let level03Container = try level02Container.nestedContainer(keyedBy: Level02Keys.self)
            let level04Container = try level03Container.nestedContainer(keyedBy: Level03Keys.self, forKey: .data)
            newsFeedDictionary["id"] = try level04Container.decode(String.self, forKey: .id)
            newsFeedDictionary["title"] = try level04Container.decode(String.self, forKey: .title)
            newsFeedDictionary["text"] = try level04Container.decode(String.self, forKey: .text)
            let thumbnailURLString = try level04Container.decodeIfPresent(String.self, forKey: .thumbnailURLString)
            if let thumbnailURLString = thumbnailURLString, thumbnailURLString != "self" && thumbnailURLString != "default", let thumbnailID = thumbnailURLString.split(whereSeparator: { $0 == "/" || $0 == "."}).dropLast().last.map(String.init) {
                // the url is "self" when there is no thumbnail
                newsFeedDictionary["thumbnailID"] = thumbnailID
                newsFeedDictionary["thumbnailWidth"] = try level04Container.decode(UInt.self, forKey: .thumbnailWidth)
                newsFeedDictionary["thumbnailHeight"] = try level04Container.decode(UInt.self, forKey: .thumbnailHeight)
            }
            newsFeedArray.append(newsFeedDictionary)
        }
    }
    
}

// alternatively can use JSONSerialization, or other ways of parsing
class SwiftFeedFactory: NewsFeedFactory {
    
    func makeNewsFeeds(data: Data) throws -> Array<Dictionary<String, Any>> {
        let makeNewsFeeds = makeNewsFeedsClosure()
        return try makeNewsFeeds(data)
    }
    
    func makeNewsFeedsClosure() -> (Data) throws -> Array<Dictionary<String, Any>> {
        return {
            let codableNewsFeeds = try JSONDecoder().decode(CodableNewsFeeds.self, from: $0)
            // Thread.sleep(forTimeInterval: 5) // test: make sure UI is responsive
            return codableNewsFeeds.newsFeedArray
        }
    }
    
}
