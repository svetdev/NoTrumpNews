//
//  Article.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import Foundation
import Foundation

class Article: NSObject, NSCoding {
       var author = String()
    var title = String()
    var articleDescription = String()
    var url = String()
    var urlToImage = String()
    var publishedAt = Date()
    var sortBy = String()
    
    override init() {
       
        self.author = ""
        self.title = ""
        self.articleDescription = ""
        self.url = ""
        self.urlToImage = ""
        self.publishedAt = Date()
        self.sortBy = ""
    }
    
    init(author: String, title: String, articleDescription: String, url: String, urlToImage:String, publishedAt: Date, sortBy: String) {
       
        self.author = author
        self.title = title
        self.articleDescription = articleDescription
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.sortBy = sortBy
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        self.init(
            author: aDecoder.decodeObject(forKey: "author") as! String,
            title: aDecoder.decodeObject(forKey: "title") as! String,
            articleDescription : aDecoder.decodeObject(forKey: "articleDescription") as! String,
            url : aDecoder.decodeObject(forKey: "url") as! String,
            urlToImage : aDecoder.decodeObject(forKey: "urlToImage") as! String,
            publishedAt : aDecoder.decodeObject(forKey: "publishedAt") as! Date,
            sortBy : aDecoder.decodeObject(forKey: "sortBy") as! String
            
        )
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return (self.title == (object as! Article).title  && self.articleDescription == (object as! Article).articleDescription && self.url == (object as! Article).url)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.author, forKey: "author")
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.articleDescription, forKey: "articleDescription")
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.urlToImage, forKey: "urlToImage")
        aCoder.encode(self.publishedAt, forKey: "publishedAt")
        aCoder.encode(self.sortBy, forKey: "sortBy")
        
    }
    
    
}
