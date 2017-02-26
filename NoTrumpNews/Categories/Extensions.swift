//
//  Extensions.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardInstantiable: class {
    static var storyboardId: String {get}
    static func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    static var storyboardId: String {
        let classString = NSStringFromClass(self)
        let components = classString.components(separatedBy: ".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard, type: self)
    }
}

extension UIViewController {
    
    fileprivate class func instantiateFromStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewController(withIdentifier: self.storyboardId) as! T
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//Extension Top Articles

extension TopArticlesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterArticles(searchController.searchBar.text!)
    }
}


extension ArticlesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterArticles(searchController.searchBar.text!)
    }
}

extension UIViewController: StoryboardInstantiableArticles {
    static var storyboardIdentifier: String {
        let classString = NSStringFromClass(self)
        let components = classString.components(separatedBy: ".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }
    
    class func instantiateFromStoryboardArticles(_ storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboardArticles(storyboard, type: self)
    }
}
extension UIViewController {
    // Thanks to generics, return automatically the right type
    fileprivate class func instantiateFromStoryboardArticles<T: UIViewController>(_ storyboard: UIStoryboard, type: T.Type) -> T {
        return storyboard.instantiateViewController(withIdentifier: self.storyboardIdentifier) as! T
    }
}

protocol StoryboardInstantiableArticles: class {
    static var storyboardId: String {get}
    static func instantiateFromStoryboardArticles(_ storyboard: UIStoryboard) -> Self
}

