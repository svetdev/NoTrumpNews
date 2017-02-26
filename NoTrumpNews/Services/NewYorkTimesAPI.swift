//
//  NewYorkTimesAPI.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NewYorkTimesAPI: NSObject {
    
    let api_key = "f6e2d6b3c665456682199045287b03fd"
    
    //singleton api object
    static let sharedInstance = NewYorkTimesAPI()
    
    
    func getArticles(category: String, completionHandler:@escaping (Bool, [Article]) -> ()) {
        let requestURL = URL(string:"https://api.nytimes.com/svc/topstories/v2/\(category).json?api-key=\(api_key)")!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        Alamofire.request(urlRequest).responseJSON {
            response in
            switch response.result{
            case .failure:
                //In case of an error a alert pops with a message.
                completionHandler(false, [])
            case .success(let value):
                //If the result is successfully, the json is saved.
                let json = JSON(value)
                
                //Successfully call getArticles for all the articles.
                let allArticles = self.extractArticles(json: json)
                
                completionHandler(true, allArticles)
            }
        }
    }
    
    func extractArticles(json: JSON) -> [Article] {
        var allArticles = [Article]();
        if let articlesUnwrapped = json["results"].array {
            
            for articleDictionary in articlesUnwrapped {
                var articleComplete = false
                if let article = articleDictionary.dictionary {
                    let artAuthor: String = article["byline"]!.stringValue
                    let artDesc: String = article["abstract"]!.stringValue
                    let artUrl: String = article["url"]!.stringValue
                    
                    if URL(string: artUrl) != nil {
                        articleComplete = true
                    }
                    
                    let artTitle: String = article["title"]!.stringValue
                    
                    if (artTitle.contains("Trump")){
                        articleComplete = false
                    }
                    
                    let artUrlImage: String = (article["multimedia"]?[4]["url"].stringValue)!
                    
                    
                    var publishedAt = Date()
                    if let artPubAt = article["published_date"]?.string {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                        let date = dateFormatter.date(from: artPubAt)
                        if  date != nil {
                            publishedAt = date!
                        }
                    }
                    
                    if articleComplete {
                        let articleToSave = Article(author: artAuthor,
                                                    title: artTitle,
                                                    articleDescription: artDesc,
                                                    url: artUrl,
                                                    urlToImage: artUrlImage,
                                                    publishedAt: publishedAt,
                                                    sortBy: "")
                        
                        allArticles.append(articleToSave)
                        
                        if !allArticles.contains(articleToSave){
                            allArticles.append(articleToSave)
                        }
                    }
                }
            }
        }
        return allArticles;
    }
    
    
}

