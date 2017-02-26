//
//  FullArticleVC.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import UIKit

class FullArticleVC: UIViewController, UIWebViewDelegate {
    
    var backButton = UIButton()
    var titleViewController = UILabel()
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Const.backgroundColor()
        let webView:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        webView.delegate = self
        //If the url is valid, load the page.
        if self.urlString != "" {
            webView.loadRequest(URLRequest(url: URL(string: urlString )!))
            webView.contentMode = .scaleAspectFit
            webView.scalesPageToFit = true
            self.view.addSubview(webView)
        }
        
        webView.backgroundColor = Const.backgroundColor()
        //Set the title for the View Controller.
        self.titleViewController.frame = CGRect(x: 75, y: 3, width: 170, height: 34)
        self.titleViewController.text = "Full Article"
        self.navigationController?.navigationBar.addSubview(self.titleViewController)
        
        //Set the back button image and function.
        self.backButton.frame = CGRect(x: 0, y: 5, width: 20 , height: 20)
        self.backButton.setImage(UIImage(named: "back_arrow_button"), for: UIControlState())
        self.backButton.addTarget(self, action: #selector(FullArticleVC.backTopArticles(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        self.navigationController?.navigationBar.barTintColor =  Const.backgroundColor()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color:Const.backgroundColor()), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    //MARK: - WebView
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled {
            let ErrorAlert = UIAlertController(title: "Error", message: "Please check your internet connection and try again!", preferredStyle: UIAlertControllerStyle.alert)
            ErrorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in self.dismiss(animated: false, completion: {}) }))
            self.present(ErrorAlert, animated: true, completion: nil)
        }
    }
    
    
    func backTopArticles(_ sender: UIButton) {
        self.dismiss(animated: false, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

