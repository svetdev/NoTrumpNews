//
//  ViewController.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import UIKit
import SDWebImage
import Social
import SwiftyJSON

//MARK: - Protocol
protocol delegateArticles: class {
    func getAllArticles() -> [AnyObject]
    func getTopArticles() -> [Article]
}

class TopArticlesVC: ArticleVC, UISearchBarDelegate, UIGestureRecognizerDelegate, delegateArticles {
    
    var titleViewController = UILabel()
    var searchController = UISearchController(searchResultsController : nil)
    var filteredArticles : [Article] = []
    //This array contains the articles sorted by "top".
    var topArticles : [Article] = []
    //This array contains all the dowmloaded articles.
    var allArticles : [Article] = []
    var rowToPass = 0
    var sectionToPass = 0
    var author = ""
    var articleTitle = ""
    var articleDescription = ""
    var url = ""
    var urlToImage = ""
    var publishedAt = Date()
    var sortBy = ""
    var gestureLeft = UIScreenEdgePanGestureRecognizer()
    var gestureRight = UIPanGestureRecognizer()
    var imageCache: SDImageCache = SDImageCache(namespace: "XXXXXXX")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blackView.alpha = 0
        self.searchController.searchBar.delegate = self
        //Sort top articles.
        self.topArticles.sort(by: { $0.publishedAt > $1.publishedAt })
        self.gridDisplay = false
        self.setGestureRecognizers()
        self.view.autoresizesSubviews = true
        self.createCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //Set View Controller's title.
        self.setTitle()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color:Const.backgroundColor()), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.setSavedArticles()
        self.setCollection()
        self.setButtonsImages()
        self.searchController.isActive = false
        self.collectionView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //Set gesture recognizers.
    func setGestureRecognizers() {
        self.gestureLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(TopArticlesVC.handleTap(_:)))
        self.gestureLeft.edges = .left
        self.gestureRight = UIPanGestureRecognizer(target: self, action: #selector(handleDragToLeft))
        self.blackView.addGestureRecognizer(self.gestureRight)
        self.view.addGestureRecognizer(self.gestureLeft)
    }
    
    func setTitle() {
        self.navigationItem.titleView = nil
        self.titleViewController.removeFromSuperview()
        self.titleViewController.frame = CGRect(x: 65, y: 6, width: 170, height: 34)
        self.titleViewController.text = "Top Articles"
        self.navigationController?.navigationBar.addSubview(self.titleViewController)
        self.searchController.searchBar.text = ""
        
    }
    
    //MARK: - Side Menu
    func setLeftMenu(){
        if let window = UIApplication.shared.keyWindow {
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
            self.sideMenu.view.backgroundColor = UIColor(white: 1, alpha: 1)
            window.addSubview(self.blackView)
            window.addSubview(sideMenu.view)
            self.sideMenu.delegate = self
            self.sideMenu.view.frame = CGRect(x: 0, y: 0, width: 0, height: window.frame.height)
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.sideMenu.view.frame = CGRect(x: 0, y: 0, width: window.frame.width - 70, height: window.frame.height)
                self.blackView.alpha = 1
            }, completion: nil)
            self.blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        }
    }
    
    //This function reveals the left menu.
    func showMenu(_ sender: UIBarButtonItem) {
        self.setLeftMenu()
    }
    
    //This function reveals the left menu when dragged from left.
    func handleTap(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            gestureRecognizer.isEnabled = false
            self.setLeftMenu()
            gestureRecognizer.isEnabled = true
        }
    }
    
    //This function handles the dismiss of the left menu.
    func handleDragToLeft(_ sender: UIPanGestureRecognizer) {
        handleDismiss()
    }
    
    //MARK: - Search
    //This function sets the search button's action.
    func searchButtonAction(_ sender: AnyObject) {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItem = nil
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        
        self.searchController.searchBar.tintColor = UIColor.black
        self.searchController.searchBar.showsCancelButton = true
    }
    
    //This function handles the dismiss of the search bar when the button "Cancel" is tapped.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: self.gridDisplayButton),UIBarButtonItem(customView: self.searchButton) ], animated: false)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.titleView = nil
        self.titleViewController.removeFromSuperview()
        self.navigationController?.navigationBar.addSubview(self.titleViewController)
    }
    
    // MARK: - Filter articles
    func filterArticles(_ searchText: String, scope: String = "All") {
        self.filteredArticles = self.topArticles.filter{article in
            return article.title.lowercased().contains(searchText.lowercased())}
        self.collectionView.reloadData()
    }
    
    
    //MARK: - Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            if self.filteredArticles.count == 0 {
                self.noData(message: "No results found.")
            } else {
                self.collectionView.backgroundView = self.backgroundView
            }
            return self.filteredArticles.count
        } else {
            if self.topArticles.count == 0 {
                self.noData(message: "No articles found.")
            } else {
                self.collectionView.backgroundView = self.backgroundView
            }
            return self.topArticles.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! CollectionCell
        self.collectionView.autoresizesSubviews = true
        //This variable contains what articles should be displayed.
        var articlesToDisplay : [Article] = []
        
        //Set the collectionView cell design.
        if self.gridDisplay == false {
            self.listDisplay(cell: cell)
        }
        else {
            self.gridDisplay(cell: cell)
        }
        
        //Determine what array is displayed in the collectionView.
        if searchController.isActive && searchController.searchBar.text != "" {
            articlesToDisplay = self.filteredArticles
            cell.addToArticlesList.accessibilityLabel = "filteredArticles"
            cell.shareButton.accessibilityLabel = "filteredArticles"
        }
        else {
            articlesToDisplay = self.topArticles
            cell.addToArticlesList.accessibilityLabel = "topArticles"
            cell.shareButton.accessibilityLabel = "topArticles"
        }
        
        //Set the content of the title, description.
        if articlesToDisplay[indexPath.row].title != "" {
            cell.titleLabel.text = articlesToDisplay[indexPath.row].title
        } else {
            cell.titleLabel.text = "No title."
      
        }
       
        if gridDisplay == false {
            if articlesToDisplay[indexPath.row].articleDescription != "" {
                cell.descriptionLabel.text = articlesToDisplay[indexPath.row].articleDescription
            } else {
                cell.descriptionLabel.text = "No description."
              
            }
        }
        
        //Download and set the article image.
        let articleImageString : String = articlesToDisplay[indexPath.row].urlToImage
        if  URL(string: articleImageString) != nil {
            cell.backgroundViewImage.sd_setImage(with: URL(string: articleImageString), placeholderImage:UIImage(contentsOfFile:"background_card_big"), options: [.continueInBackground, .progressiveDownload])
        }
        
        cell.contentView.addSubview(cell.whiteRoundedView)
        cell.backgroundViewCell.layer.masksToBounds = true
        cell.whiteRoundedView.addSubview(cell.backgroundViewImage)
        cell.backgroundViewImage.addSubview(cell.backgroundViewCell)
        cell.backgroundViewImage.isUserInteractionEnabled = true
        
        cell.addToArticlesList.setImage(UIImage(named: "bookmark_icon_normal"), for: UIControlState() )
        
        //Determine if the article displayed is saved or not.
        for i in 0..<self.savedArticles.count {
            if self.savedArticles[i].isEqual(articlesToDisplay[indexPath.row]) {
                cell.addToArticlesList.setImage(UIImage(named: "unmark_icon"), for: UIControlState() )
            }
        }
        
        //Set the buttons images.
        cell.addToArticlesList.addTarget(self, action: #selector(TopArticlesVC.markUnmarkArticle(_:)), for: UIControlEvents.touchUpInside)
        cell.addToArticlesList.setImage(UIImage(named: "bookmark_icon_active"), for: .highlighted )
        cell.addToArticlesList.tag = indexPath.row
        
        cell.shareButton.addTarget(self, action:  #selector(share(_:)), for: UIControlEvents.touchUpInside)
        cell.shareButton.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullArticleVC") as! FullArticleVC
        let nav: UINavigationController = UINavigationController(rootViewController: secondViewController)
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            secondViewController.urlString = self.filteredArticles[indexPath.row].url
        }
        else {
            secondViewController.urlString = self.topArticles[indexPath.row].url
        }
        present(nav, animated: false, completion: nil)
    }
    
    //MARK: - Mark Unmark Article
    func markUnmarkArticle(_ sender: UIButton) {
        let row = sender.tag
        var articleToSave = Article()
        
        if sender.accessibilityLabel == "topArticles" {
            articleToSave = Article(
                                    author: self.topArticles[row].author,
                                    title: self.topArticles[row].title,
                                    articleDescription: self.topArticles[row].articleDescription,
                                    url: self.topArticles[row].url,
                                    urlToImage: self.topArticles[row].urlToImage,
                                    publishedAt: self.topArticles[row].publishedAt,
                                    sortBy: self.topArticles[row].sortBy)
        }
        else if sender.accessibilityLabel == "filteredArticles" {
            articleToSave = Article(
                                    author: self.filteredArticles[row].author,
                                    title: self.filteredArticles[row].title,
                                    articleDescription: self.filteredArticles[row].articleDescription,
                                    url: self.filteredArticles[row].url,
                                    urlToImage: self.filteredArticles[row].urlToImage,
                                    publishedAt: self.filteredArticles[row].publishedAt,
                                    sortBy: self.filteredArticles[row].sortBy)
        }
        
        self.MarkUnmark(articleToSave: articleToSave)
        
    }
    
    //MARK: - Share Article
    func share(_ sender: UIButton) {
        if sender.accessibilityLabel == "topArticles" {
            shareArticles(url: self.topArticles[sender.tag].url)
        }
            
        else if sender.accessibilityLabel == "filteredArticles" {
            shareArticles(url: self.filteredArticles[sender.tag].url)
        }
    }
    
    // MARK: - Protocol
    func getAllArticles() -> [AnyObject] {
        return self.allArticles
    }
    func getTopArticles() -> [Article] {
        return self.topArticles
    }
}
