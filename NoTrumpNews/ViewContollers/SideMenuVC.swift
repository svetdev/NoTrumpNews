//
//  SideMenuVC.swift
//  NoTrumpNews
//
//  Created by Andrey Kasatkin on 2/21/17.
//  Copyright © 2017 Svetliy. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class sideMenuCell : UITableViewCell {
    
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var itemImage: UIImageView!
    
}

class SideMenuVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var itemsLabels : [String] = []
    var itemsImages : [String] = []
  
    var allArticles : [Article] = []
    var swipeLeft = UISwipeGestureRecognizer()
    var delegate : delegateArticles?
    var topArticles : [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegates()
        self.tableView.separatorStyle = .none
        
        self.swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SideMenuVC.swipeLeftAction(_:)))
        self.swipeLeft.direction = .left
        self.tableView.addGestureRecognizer(self.swipeLeft)
    }
    
    override func viewWillLayoutSubviews() {
        
        if self.delegate != nil {
            self.allArticles = (self.delegate?.getAllArticles())! as! [Article]
            self.topArticles = (self.delegate?.getTopArticles())!
        }
      
        self.itemsLabels = ["My Collection","Top Articles"]
        self.itemsImages = ["bookmark_icon_normal","top_articles_icon", ]
        self.tableView.alpha = 0
        self.tableView.frame = CGRect(x: 0, y: 1, width: 0, height: self.view.frame.height)
     
        self.tableView.isScrollEnabled = false
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.tableView.alpha = 1
                self.tableView.frame = CGRect(x: 0, y: 1, width: window.frame.width - 70, height: window.frame.height)
            }, completion: nil)
        }
    }
    
    
    //Set delegates.
    func setDelegates() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    

    func swipeLeftAction(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let sectionName = UILabel()
        sectionName.textColor = UIColor(red: 144/255, green: 148/255, blue: 150/255, alpha: 1.0)
        
     
        if tableView == self.tableView {
            if let window = UIApplication.shared.keyWindow {
                
                let gradient = CAGradientLayer()
                let color33 = UIColor(red: 33/255, green: 209/255, blue: 237/255, alpha: 1.0).cgColor as CGColor
                let color44 = UIColor(red: 85/255, green: 163/255, blue: 237/255, alpha: 1.0).cgColor as CGColor
                gradient.colors = [color44,color33]
                gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradient.frame = CGRect(x: 0,y: 0,width: window.frame.size.width - 60,height: 8)
                headerView.layer.addSublayer(gradient)
                
            }
        }
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        if tableView == self.tableView {
            footerView.backgroundColor = UIColor(red: 32/255, green: 36/255, blue: 38/255, alpha: 0.1)
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 8
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = sideMenuCell()
        cell.selectionStyle = .none
        
        if tableView == self.tableView {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath as IndexPath) as! sideMenuCell
            cell.itemImage.image = UIImage()
            cell.itemLabel.text = ""
            cell.itemLabel.textColor = UIColor(red: 113/255, green: 210/255, blue: 231/255, alpha: 1.0)
            cell.itemImage.layer.cornerRadius = 2.0
            cell.itemImage.layer.masksToBounds = true
            cell.itemImage.image = UIImage(named: self.itemsImages[indexPath.row])
            cell.itemImage.contentMode = .scaleAspectFit
            
            let itemText = self.itemsLabels[indexPath.row].replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
            cell.itemLabel.text = itemText
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let secondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticlesVC") as! ArticlesVC
        let nav: UINavigationController = UINavigationController(rootViewController: secondViewController)
        
        //MyCollection
        if tableView == self.tableView && indexPath.row == 0 {
            self.view.alpha = 0
            var articlesToPass = [Article]()
            secondViewController.delegate = self.delegate
            if let data = UserDefaults.standard.object(forKey: "myArticles") as? NSData {
                articlesToPass = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Article]
            }
            else {
                articlesToPass = []
            }
            secondViewController.articlesForDisplay = articlesToPass.reversed()
            secondViewController.titleViewController.text = "My Collection"
            present(nav, animated: false, completion: nil)
        }
        //Top Articles.
        if tableView == self.tableView && indexPath.row == 1 {
            self.view.alpha = 0
            secondViewController.delegate = self.delegate
            secondViewController.articlesForDisplay = self.topArticles
            secondViewController.titleViewController.text = "Top Articles"
            present(nav, animated: false, completion: nil)
            
        }
    }
}
