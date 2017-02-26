//
//  ArticleVC.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

/*
 This class will hold functions common for TopArticlesViewController and ArticlesViewController
 */
import UIKit

class ArticleVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var savedArticles: [Article] = []
    var searchButton = UIButton()
    var menuButton = UIButton()
    var gridDisplayButton = UIButton()
    var gridDisplay = false
    var collectionView : UICollectionView!
    var gradientLayer = CAGradientLayer()
    var backgroundView = UIView()
    let blackView = UIView()
    var sideMenu = SideMenuVC.instantiateFromStoryboardArticles(UIStoryboard(name: "Main", bundle: nil))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setSavedArticles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Share Article
    func shareArticles(url: String) {
        
        if url != "" {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList,    UIActivityType.postToFlickr, UIActivityType.postToVimeo]
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                vc.modalPresentationStyle = .popover
                vc.popoverPresentationController!.barButtonItem = navigationItem.rightBarButtonItem
            }
            self.present(vc, animated: true, completion: nil)
            
        }
        else {
            let alertError = UIAlertController(title: "Error", message: "This article cannot be shared!", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alertError, animated: true, completion: nil)
        }
    }
    
    //MARK: - Set saved articles
    //This function sets gets the articles saved by the user.
    func setSavedArticles(){
        
        if let data = UserDefaults.standard.object(forKey: "myArticles") as?	 Data {
            self.savedArticles = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Article]
        }
        else {
            self.savedArticles = []
        }
    }
    
    //MARK: - Save/Unsave Article
    //This function saves an article in the user's savedArticles array or deletes it from it
    func MarkUnmark(articleToSave: Article) {
        
        var saved: Bool = false
        var index: Int = -1
        
        self.setSavedArticles()
        
        for i in 0..<self.savedArticles.count {
            if self.savedArticles[i].isEqual(articleToSave) {
                saved = true
                index = i
            }
        }
        
        if saved == false {
            //save
            let alertControllerSaved = UIAlertController(title: "Saved!", message:"", preferredStyle: UIAlertControllerStyle.alert)
            self.savedArticles.append(articleToSave)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: savedArticles), forKey: "myArticles")
            self.present(alertControllerSaved, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(90)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                alertControllerSaved.dismiss(animated: true, completion: nil)
            }
        }
        else if saved == true {
            //delete
            self.savedArticles.remove(at: index)
            UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: savedArticles), forKey: "myArticles")
            let alertControllerDeleted =  UIAlertController(title: "Removed!", message:"", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alertControllerDeleted, animated: true, completion: nil)
            let time = DispatchTime.now() + Double(Int64(90)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                alertControllerDeleted.dismiss(animated: true, completion: nil)
            }
            
        }
        self.setSavedArticles()
        self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
    }
    
    //MARK: Set Buttons images
    func setButtonsImages() {
        
        self.menuButton.frame = CGRect(x: 0, y: 0, width: 20 , height: 20)
        self.menuButton.setImage(UIImage(named: "menu_icon_normal"), for: UIControlState())
        self.menuButton.setImage(UIImage(named: "menu_icon_active"), for: UIControlState.highlighted)
        self.menuButton.addTarget(self, action: #selector(TopArticlesVC.showMenu(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        self.searchButton.frame = CGRect(x: 0, y: 5, width: 20 , height: 20)
        self.searchButton.setImage(UIImage(named: "search_icon_normal"), for: UIControlState())
        self.searchButton.setImage(UIImage(named: "search_icon_active"), for: UIControlState.highlighted)
        self.searchButton.addTarget(self, action: #selector(TopArticlesVC.searchButtonAction(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.searchButton)
        
        if self.gridDisplay == false {
            self.gridDisplayButton.frame = CGRect(x: 0, y: 5, width: 20 , height: 20)
            self.gridDisplayButton.setImage(UIImage(named: "view_icon_normal"), for: UIControlState())
            self.gridDisplayButton.setImage(UIImage(named: "view_icon_active"), for: UIControlState.highlighted)
        } else {
            self.gridDisplayButton.frame = CGRect(x: 0, y: 5, width: 20 , height: 20)
            self.gridDisplayButton.setImage(UIImage(named: "list_icon_normal"), for: UIControlState())
            self.gridDisplayButton.setImage(UIImage(named: "list_icon_active"), for: UIControlState.highlighted)
        }
        self.gridDisplayButton.addTarget(self, action: #selector(TopArticlesVC.gridDisplay(_:)), for: UIControlEvents.touchUpInside)
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: self.gridDisplayButton),UIBarButtonItem(customView: self.searchButton) ], animated: false)
        
    }
    
    //MARK: - Collection View
    //This function creates the collection view in which the articles are displayed.
    func createCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if UIApplication.shared.statusBarOrientation.isPortrait {
            if gridDisplay == false {
                layout.sectionInset = UIEdgeInsets(top: 40, left: 10, bottom: 40, right: 10)
                layout.itemSize = CGSize(width: self.view.frame.width - 50 , height: 236)
            }
            else {
                layout.sectionInset = UIEdgeInsets(top: 40, left: 25, bottom: 70, right: 25)
                layout.itemSize = CGSize(width: self.view.frame.width/2 - 35, height: self.view.frame.width/2 - 35)
            }
            
            
            self.collectionView = UICollectionView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! ), collectionViewLayout: layout)
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CellIdentifier")
            let color33 =  Const.backgroundColor().cgColor as CGColor
            let color44 = UIColor(white: 1, alpha: 0.9).cgColor as CGColor
            self.gradientLayer.colors = [color33,color44] // top , bottom
            self.gradientLayer.locations = [0.0,1.0]
            self.gradientLayer.frame = self.collectionView.bounds
            self.backgroundView = UIView(frame: self.collectionView.bounds)
            self.backgroundView.layer.insertSublayer(self.gradientLayer, at: 0)
            self.collectionView.backgroundView = self.backgroundView
            self.view.addSubview(self.collectionView)
            self.collectionView.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath)
        return cell
    }
    
    //MARK: - Grid Display
    //This funtions handles the display of the articles. From grid display makes it list display and from list display it makes it grid display.
    func gridDisplay(_ sender: UIButton) {
        
        if self.gridDisplay == true {
            self.gridDisplay = false
            self.gridDisplayButton.setImage(UIImage(named: "view_icon_normal"), for: UIControlState())
            self.gridDisplayButton.setImage(UIImage(named: "view_icon_active"), for: UIControlState.highlighted)
            
        } else {
            self.gridDisplay = true
            self.gridDisplayButton.setImage(UIImage(named: "list_icon_normal"), for: UIControlState())
            self.gridDisplayButton.setImage(UIImage(named: "list_icon_active"), for: UIControlState.highlighted)
        }
        
        self.setCollection()
    }
    
    func setCollection() {
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if self.gridDisplay == false {
            layout.sectionInset = UIEdgeInsets(top: 40, left: 10, bottom: 40, right: 10)
            layout.itemSize = CGSize(width: self.view.frame.width - 50 , height: 236)
        }
        else {
            layout.sectionInset = UIEdgeInsets(top: 40, left: 25, bottom: 70, right: 25)
            layout.itemSize = CGSize(width: self.view.frame.width/2 - 35, height: self.view.frame.width/2 - 35)
        }
        self.collectionView.collectionViewLayout = layout
        self.collectionView.autoresizesSubviews = true
        self.collectionView.reloadData()
    }
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        var result : CGFloat = 0.0
        if UIApplication.shared.statusBarOrientation.isPortrait {
            if self.gridDisplay == false {
                result = 15.0
            }
            if self.gridDisplay == true {
                result = 25.0
            }
        }
        return result
    }
    
    //MARK: - No data found
    //This functions shows a label when there are no articles to display.
    func noData(message: String) {
        let noResultsView = UIView(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.size.width,height: self.collectionView.bounds.size.height))
        let noResultsLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 50, width: noResultsView.bounds.size.width,height: 21))
        noResultsLabel.text = message
        noResultsLabel.textColor = UIColor.gray
        noResultsLabel.textAlignment = .center
        noResultsLabel.backgroundColor = self.view.backgroundColor
        noResultsView.backgroundColor = self.view.backgroundColor
        noResultsView.addSubview(noResultsLabel)
        self.collectionView.backgroundView = noResultsView
        
    }
    
    //MARK: Handle sideMenu dismiss
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            if  UIApplication.shared.keyWindow != nil {
                self.sideMenu.view.frame = CGRect(x: 0, y: 1, width: 0, height: self.sideMenu.view.frame.height)
            }
        })
    }
    
    //MARK: - CollectionView list display
    func listDisplay(cell: CollectionCell) {
        
        let gradientLayerCell = CAGradientLayer()
        let color33 =  UIColor.clear.cgColor as CGColor
        let color44 = UIColor(white: 0 , alpha: 0.8).cgColor as CGColor
        gradientLayerCell.colors = [color33,color44] // top , bottom
        gradientLayerCell.locations = [0.0,1.0]
        gradientLayerCell.removeFromSuperlayer()
        
        cell.backgroundColor = UIColor.clear
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 2.0
        
        cell.backgroundViewImage.removeFromSuperview()
        cell.whiteRoundedView.removeFromSuperview()
        cell.backgroundViewCell.removeFromSuperview()
        
        cell.backgroundViewImage = UIImageView(frame: CGRect(x: 10, y: 10, width: self.view.frame.size.width - 60, height: 130))
        cell.backgroundViewImage.layer.cornerRadius = 2.0
        cell.backgroundViewImage.layer.masksToBounds = true
        cell.backgroundViewImage.contentMode = .scaleAspectFill
        
        cell.backgroundViewCell = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 60, height: 130))
        cell.backgroundViewCell.layer.cornerRadius = 2.0
        cell.backgroundViewCell.layer.zPosition = 1
        gradientLayerCell.frame = cell.backgroundViewCell.bounds
        cell.backgroundViewCell.layer.addSublayer(gradientLayerCell)
        
        
        cell.whiteRoundedView = UIView(frame: CGRect(x: -5, y: 10, width: self.view.frame.size.width - 40, height: 235))
        cell.whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        cell.whiteRoundedView.layer.masksToBounds = false
        cell.whiteRoundedView.layer.cornerRadius = 4.0
        cell.whiteRoundedView.layer.shadowRadius = 4.0
        cell.whiteRoundedView.layer.shadowColor = UIColor(white: 0.7, alpha: 0.7).cgColor
        
        cell.whiteRoundedView.addSubview(cell.backgroundViewCell)
        
        cell.titleLabel = UILabel(frame: CGRect(x: 12, y: 155, width: self.view.frame.size.width - 60, height: 25))
        cell.titleLabel.textColor = UIColor(red: 86/255, green: 98/255, blue: 106/255, alpha: 1.0)
        cell.titleLabel.text = "Title"
        cell.whiteRoundedView.addSubview(cell.titleLabel)
        
        cell.descriptionLabel = UILabel(frame: CGRect(x: 12, y: 180, width: self.view.frame.size.width - 60, height: 25))
        cell.descriptionLabel.textColor = UIColor(red: 120/255, green: 122/255, blue: 123/255, alpha: 1.0)
        cell.descriptionLabel.text = "Description"
        cell.whiteRoundedView.addSubview(cell.descriptionLabel)
        
        cell.addToArticlesList = UIButton(frame: CGRect(x: 2, y: 200, width: 35, height: 35))
        cell.whiteRoundedView.addSubview(cell.addToArticlesList)
        
        cell.shareButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 75, y: 200, width: 35, height: 35))
        cell.shareButton.setImage(UIImage(named: "share_icon_normal"), for: UIControlState() )
        cell.shareButton.setImage(UIImage(named: "share_icon_active"), for: .highlighted )
        cell.whiteRoundedView.addSubview(cell.shareButton)
    }
    
    //CollectionView grid display.
    func gridDisplay(cell: CollectionCell) {
        
        let gradientLayerCell = CAGradientLayer()
        let color33 =  UIColor.clear.cgColor as CGColor
        let color44 = UIColor(white: 0 , alpha: 0.8).cgColor as CGColor
        gradientLayerCell.colors = [color33,color44] // top , bottom
        gradientLayerCell.locations = [0.0,1.0]
        gradientLayerCell.removeFromSuperlayer()
        
        cell.backgroundColor = UIColor.clear
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 2.0
        
        cell.backgroundViewImage.removeFromSuperview()
        cell.whiteRoundedView.removeFromSuperview()
        cell.backgroundViewCell.removeFromSuperview()
        
        cell.backgroundViewImage = UIImageView(frame: CGRect(x: 5, y: 5, width: self.view.frame.size.width/2 - 30, height: self.view.frame.size.width/2 - 30))
        cell.backgroundViewImage.layer.cornerRadius = 2.0
        cell.backgroundViewImage.layer.masksToBounds = true
        cell.backgroundViewImage.contentMode = .scaleAspectFill
        
        cell.backgroundViewCell = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/2 - 30, height: self.view.frame.size.width/2 - 30 ))
        cell.backgroundViewCell.layer.cornerRadius = 2.0
        cell.backgroundViewCell.layer.zPosition = 0
        gradientLayerCell.frame = cell.backgroundViewCell.bounds
        cell.backgroundViewCell.layer.addSublayer(gradientLayerCell)
        cell.backgroundViewCell.layer.masksToBounds = false
        
        
        cell.whiteRoundedView = UIView(frame: CGRect(x: -8, y: 10, width: self.view.frame.size.width/2 - 20 , height: self.view.frame.size.width/2 - 20))
        cell.whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        cell.whiteRoundedView.layer.masksToBounds = false
        cell.whiteRoundedView.layer.cornerRadius = 4.0
        cell.whiteRoundedView.layer.shadowRadius = 4.0
        cell.whiteRoundedView.layer.shadowColor = UIColor(white: 0.7, alpha: 0.7).cgColor
    
        cell.whiteRoundedView.addSubview(cell.backgroundViewCell)
        
        cell.titleLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.size.width/2 - 60, width: self.view.frame.size.width/2 - 50, height: 20))
        cell.titleLabel.textColor = UIColor.white
        cell.titleLabel.text = "Title"
        cell.backgroundViewCell.addSubview(cell.titleLabel)
        
        cell.addToArticlesList = UIButton(frame: CGRect(x: self.view.frame.size.width/2 - 89,y: 5, width: 35, height: 35))
        cell.addToArticlesList.contentMode = .scaleAspectFit
        cell.backgroundViewCell.addSubview(cell.addToArticlesList)
        
        cell.shareButton = UIButton(frame: CGRect(x: self.view.frame.size.width/2 - 62,y: 5, width: 35, height: 35))
        cell.shareButton.setImage(UIImage(named: "share_icon_normal"), for: UIControlState() )
        cell.shareButton.setImage(UIImage(named: "share_icon_active"), for: .highlighted )
        cell.shareButton.contentMode = .scaleAspectFit
        cell.backgroundViewCell.addSubview(cell.shareButton)
        
    }
}
