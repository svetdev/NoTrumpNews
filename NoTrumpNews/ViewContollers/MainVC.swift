//
//  MainVC.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class MainVC: UIViewController {
    
    var topArticles : [Article] = []
    
    var activityView: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    
    
    //MARK: - Json
    func getData() {
        //Show activity indicator while the articles are downloading.
        self.showActivity(self.view)
        NewYorkTimesAPI.sharedInstance.getArticles(category:"home", completionHandler: { (result, data) -> Void in
            if (result){
                self.topArticles = data
                self.downloadCompleted()
            } else {
                self.showError()
            }
            
        })
    }
    
    func showError() {
        self.removeActivity(self.view)
        let ErrorAlert = UIAlertController(title: "Error", message: "There is a problem with the internet connectivity or server. Please check your internet connection and try again!", preferredStyle: UIAlertControllerStyle.alert)
        ErrorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in self.getData()}))
        self.present(ErrorAlert, animated: true, completion: nil)
    }
    
    /*
     MARK: - Finished download
     Initializes the variables for the TopArticlesViewController and presests it.
     */
    func downloadCompleted() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topArticlesViewController = appDelegate.topArticlesVC! as! TopArticlesVC
        topArticlesViewController.sideMenu = SideMenuVC.instantiateFromStoryboardArticles(UIStoryboard(name: "Main", bundle: nil))
      
        topArticlesViewController.topArticles =  [Article](Set(self.topArticles))

        let nav: UINavigationController = UINavigationController(rootViewController: topArticlesViewController)
        present(nav, animated: false, completion: nil)
    }
    
    
    //MARK: - Activity Indicator
    func showActivity(_ myView: UIView) {
        
        myView.isUserInteractionEnabled = false
        myView.endEditing(true)
        
        self.activityView.frame = CGRect(x: 0, y: 0, width: myView.frame.width, height: myView.frame.height)
        
        self.activityView.center = myView.center
        self.activityView.backgroundColor = UIColor.white
        self.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        self.loadingView.center = myView.center
        self.loadingView.backgroundColor = UIColor.clear
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 15
        
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.activityIndicator.center = CGPoint(x: self.loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        self.titleLabel.frame = CGRect(x: 5, y: loadingView.frame.height-20, width: loadingView.frame.width-10, height: 20)
        self.titleLabel.textColor = UIColor.gray
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.text = "Loading..."
        
        self.loadingView.addSubview(self.activityIndicator)
        self.activityView.addSubview(self.loadingView)
        self.loadingView.addSubview(self.titleLabel)
        myView.addSubview(self.activityView)
        self.activityIndicator.startAnimating()
    }
    
    func removeActivity(_ myView: UIView) {
        myView.isUserInteractionEnabled = true
        myView.window?.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
        self.activityView.removeFromSuperview()
    }
    
    
}
