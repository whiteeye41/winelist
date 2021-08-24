//
//  BartendinglistThirdViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/31.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit

class BartendinglistThirdViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! PrinceCollectionViewCell
        cell.winImage2.image = self.picArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.baseWineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        guard let wineData = self.wineData else { return UITableViewCell() }
        cell.textLabel?.text = wineData.baseWineArray?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var topView: BartendinglistThirdTopView!
    
    @IBOutlet weak var myPinceView: PrinceCollectionView!
    
    var wineData :BartendingData?
    
    var baseWineArray:[String] = []
    var picArray: [UIImage] = []
    
    
    func optionalBinding() {
        guard let wineData = self.wineData else { return }
        //確定基酒陣列是否有東西，如果有，存入baswWineArray
        if let baswWineArray = wineData.baseWineArray {
            for baseWine in baswWineArray {
                self.baseWineArray.append(baseWine)
            }
        }
        //確定照片牆是否有照片，如果有，存入picArray
        if let picArray = wineData.princeImages {
            for pic in picArray {
                self.picArray.append(pic)
            }
        }
    }
    
    func setView() {
        guard let wineData = self.wineData else { return }
        topView.nameLabel.text = wineData.barTendingWinName
        topView.topImageView.image = wineData.image()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //確定調酒是否有東西
        
        self.optionalBinding()
        self.setView()
        
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        self.myPinceView.delegate = self
        self.myPinceView.dataSource = self
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.hidesBarsOnSwipe = false
        
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        let vc = self.storyboard?.instantiateViewController(identifier: "BartendinglistSecondViewController") as! BartendinglistSecondViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        dismiss(animated: true, completion: nil)
    }
}
