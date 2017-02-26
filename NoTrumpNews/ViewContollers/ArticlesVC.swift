//
//  ArticlesVC.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import UIKit
import Social

class ArticlesVC: ArticleVC, UISearchBarDelegate {
    
    var titleViewController = UILabel()
    var delegate : delegateArticles?
    var articlesForDisplay : [Article] = []
    var filteredArticles : [Article] = []
    let searchController = UISearchController(searchResultsController : nil)
    var gestureLeft = UIScreenEdgePanGestureRecognizer()
    var gestureRight = UIPanGestureRecognizer()
    var placeholder: UILabel = UILabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.createCollectionView()
        self.setGestureRecognizers()
        self.searchController.searchBar.delegate = self
        
        if self.titleViewController.text != "My News Collection" {
            self.articlesForDisplay.sort(by: { $0.publishedAt > $1.publishedAt })
        }
        self.view.autoresizesSubviews = true
        self.gridDisplay = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationController()
        self.setSavedArticles()
        self.setCollection()
        self.setButtonsImages()
        self.searchController.isActive = false
        self.collectionView.reloadData()
        
    }
    
    //Set gesture recognizers
    func setGestureRecognizers() {
        self.gestureLeft = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ArticlesVC.handleTap(_:)))
        self.gestureLeft.edges = .left
        self.view.addGestureRecognizer(self.gestureLeft)
        self.gestureRight = UIPanGestureRecognizer(target: self, action: #selector(handleDragToLeft))
        self.blackView.addGestureRecognizer(self.gestureRight)
        self.blackView.alpha = 0
    }
    
    //Set the Navigation View Controller
    func setNavigationController() {
        
        self.navigationItem.titleView = nil
        self.titleViewController.removeFromSuperview()
        //Set the title of the View Controller.
        self.titleViewController.frame = CGRect(x: 65, y: 6, width: self.view.frame.width - 150, height: 34)
        self.titleViewController.textColor = UIColor.black
        self.titleViewController.textAlignment = .left
        self.navigationController?.navigationBar.addSubview(self.titleViewController)
        //Set navigation bar.
        self.navigationController?.navigationBar.barTintColor =  Const.backgroundColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color:Const.backgroundColor()), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        
    }
    
    //MARK: - Mark Unmark Articles
    func markUnmarkArticle(_ sender: UIButton) {
        let row = sender.tag
        var articleToSave = Article()
        
        if sender.accessibilityLabel == "articlesForDisplay" {
            articleToSave = Article(
                                    author: self.articlesForDisplay[row].author,
                                    title: self.articlesForDisplay[row].title,
                                    articleDescription: self.articlesForDisplay[row].articleDescription,
                                    url: self.articlesForDisplay[row].url,
                                    urlToImage: self.articlesForDisplay[row].urlToImage,
                                    publishedAt: self.articlesForDisplay[row].publishedAt,
                                    sortBy: self.articlesForDisplay[row].sortBy)
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
    
    //MARK: - Side Menu
    func setLeftMenu() {
        if let window = UIApplication.shared.keyWindow {
            self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.7)
            self.sideMenu.view.backgroundColor = UIColor(white: 1, alpha: 1)
            window.addSubview(self.blackView)
            window.addSubview(sideMenu.view)
            self.sideMenu.delegate = self.delegate
            self.sideMenu.view.frame = CGRect(x: 0, y: 0, width: 0, height: window.frame.height)
            self.blackView.frame = window.frame
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.sideMenu.view.frame = CGRect(x: 0, y: 0, width: window.frame.width - 70, height: window.frame.height)
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
    func handleDragToLeft(_ sender: UIPanGestureRecognizer)
    {
        handleDismiss()
    }
    
    
    // MARK: - Filter articles
    func filterArticles(_ searchText: String, scope: String = "All") {
        self.filteredArticles = self.articlesForDisplay.filter{article in
            return article.title.lowercased().contains(searchText.lowercased())}
        self.collectionView.reloadData()
    }
    
    //MARK: - Share Article
    func share(_ sender: UIButton) {
        if sender.accessibilityLabel == "articlesForDisplay" {
            shareArticles(url: self.articlesForDisplay[sender.tag].url)
        }
        else if sender.accessibilityLabel == "filteredArticles" {
            shareArticles(url: self.filteredArticles[sender.tag].url)
        }
        
    }
    
    //MARK: - Search Articles
    //This function sets the search button's action.
    func searchButtonAction(_ sender: AnyObject) {
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.leftBarButtonItem = nil
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = self.searchController.searchBar
        self.searchController.searchBar.tintColor = UIColor.black
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.text = ""
        
    }
    
    //This function handles the dismiss of the search bar when the button "Cancel" is tapped.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: gridDisplayButton),UIBarButtonItem(customView: searchButton) ], animated: false)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.navigationItem.titleView = nil
        self.titleViewController.removeFromSuperview()
        self.navigationController?.navigationBar.addSubview(self.titleViewController)
    }
    
    
    //MARK: - Collection View
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            if self.filteredArticles.count == 0 {
                self.noData(message: "No results found.")
            } else {
                self.collectionView.backgroundView = self.backgroundView
            }
            return self.filteredArticles.count
        } else {
            if self.articlesForDisplay.count == 0 {
                self.noData(message: "No articles found.")
            } else {
                self.collectionView.backgroundView = self.backgroundView
            }
            return self.articlesForDisplay.count
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
            articlesToDisplay = self.articlesForDisplay
            cell.addToArticlesList.accessibilityLabel = "articlesForDisplay"
            cell.shareButton.accessibilityLabel = "articlesForDisplay"
        }
        //Set the content of the title, description and
        if articlesToDisplay[indexPath.row].title != "" {
            cell.titleLabel.text = articlesToDisplay[indexPath.row].title
        } else {
            cell.titleLabel.text = "No title."
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
        
               
        //Determine if the article displayed is saved or not.
        cell.addToArticlesList.setImage(UIImage(named: "bookmark_icon_normal"), for: UIControlState() )
        for i in 0..<self.savedArticles.count {
            if self.savedArticles[i].isEqual(articlesToDisplay[indexPath.row]) {
                cell.addToArticlesList.setImage(UIImage(named: "unmark_icon"), for: UIControlState() )
            }
        }
        //Set the buttons images.
        if self.titleViewController.text == "My Collection"
        {
            cell.addToArticlesList.addTarget(self, action: #selector(ArticlesVC.removeArticle(_:)), for: UIControlEvents.touchUpInside)
            cell.addToArticlesList.setImage(UIImage(named: "trash_icon"), for: UIControlState() )
            cell.addToArticlesList.tag = indexPath.row
        }
        else {
            cell.addToArticlesList.setImage(UIImage(named: "bookmark_icon_active"), for: .highlighted )
            cell.addToArticlesList.addTarget(self, action: #selector(ArticlesVC.markUnmarkArticle(_:)), for: UIControlEvents.touchUpInside)
            cell.addToArticlesList.tag = indexPath.row
            
            
        }
        
        cell.shareButton.addTarget(self, action:  #selector(ArticlesVC.share(_:)), for: UIControlEvents.touchUpInside)
        cell.shareButton.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullArticleVC") as! FullArticleVC
        let nav: UINavigationController = UINavigationController(rootViewController: secondViewController)
        if self.searchController.isActive && self.searchController.searchBar.text != ""{
            secondViewController.urlString = self.filteredArticles[indexPath.row].url
        }
        else {
            secondViewController.urlString = self.articlesForDisplay[indexPath.row].url
        }
        present(nav, animated: false, completion: nil)
    }
    
    //MARK: Remove Article from My News Collection
    func removeArticle(_ sender: UIButton) {
        self.articlesForDisplay.remove(at: sender.tag)
        let alertControllerSaved = UIAlertController(title: "Removed!", message:"", preferredStyle: UIAlertControllerStyle.alert)
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.articlesForDisplay), forKey: "myArticles")
        self.present(alertControllerSaved, animated: true, completion: nil)
        let time = DispatchTime.now() + Double(Int64(30)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            alertControllerSaved.dismiss(animated: true, completion: nil)
        }
        self.setSavedArticles()
        self.collectionView.reloadData()
        
    }
}
