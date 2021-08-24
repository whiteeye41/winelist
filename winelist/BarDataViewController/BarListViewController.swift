//
//  BarListViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/18.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit
import CoreData
import Firebase


class BarListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,GetataFirst,UISearchResultsUpdating {
    
    

    @objc func receiveData(data: Bar) {
        
        if let indexPath = self.indexPath {
            self.dataArray.remove(at: indexPath.row)
            self.dataArray.insert(data, at: indexPath.row)
        }
        else {
            self.dataArray.append(data)
        }
        print("test 被呼叫")
        
        MyDatabase.dataSignltonArray.append(data)
        MyDatabase.shared.save()
        MyDatabase.shared.FirebaseCopyData()
        
//        self.saveCoreData()
        self.myBarTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive{
            return searchBar.count
        }else{
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath) as! SecondCell
        let bar = (searchController.isActive) ? searchBar[indexPath.row] : dataArray[indexPath.row]
        cell.topLabel.text = bar.barName
        cell.tailLabel.text = bar.win
        cell.firstImage.image = bar.thumbnailImage()
        
        return cell
    }
    

    @IBOutlet weak var myBarTableView: UITableView!
    
    var searchBar :[Bar] = []
    var dataArray : [Bar] = []
    var searchController :UISearchController!
    var selectData: Bar?
    var indexPath: IndexPath?
 
    
    required init?(coder: NSCoder) {
    super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myBarTableView.rowHeight = 80
        self.myBarTableView.dataSource = self
        self.myBarTableView.delegate = self
        //搜尋
        searchController = UISearchController(searchResultsController:nil)
//        self.navigationItem.searchController = searchController
        myBarTableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.title = NSLocalizedString("酒吧清單", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("loadCoreData前請印出data\(dataArray.count)")
        MyDatabase.shared.loadBarArrayCoreData()
        self.dataArray = MyDatabase.dataSignltonArray
//        loadFromCoreData()
        print("請印出data\(dataArray.count)")
    }
    
    
    @IBAction func addBar(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexPath = indexPath
        self.selectData = self.dataArray[indexPath.row]
        self.performSegue(withIdentifier: "edit", sender: nil)
        print("\(indexPath.row)")
        let cell = myBarTableView.cellForRow(at: indexPath)
        print(cell?.isSelected ?? "")
        myBarTableView.deselectRow(at: indexPath, animated: true)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBarSegue"{
                let dataSegue = segue.destination as! BarSecondViewController
                dataSegue.delegate = self
//                dataSegue.currentBarList = self.data
        }
        if segue.identifier == "edit" {
            let dataSegue = segue.destination as! BarSecondViewController
            guard let bar = self.selectData else { return }
            dataSegue.bartype = bar
            dataSegue.delegate = self
        }
    }
    //刪除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("刪除", comment: "")) { (action, view, completionHandler) in
            
            let controller = UIAlertController(title: nil, message: NSLocalizedString("確定要刪除?", comment: ""), preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("刪除", comment: ""), style: .destructive) { (action:UIAlertAction) in
                
                self.dismiss(animated: true, completion: nil)
//                Database.shared.deleteAllData("bar")
                let deleData = self.dataArray.remove(at: indexPath.row)
                let coreData = CoreDataHelper.shared.managedObjectContext()
                coreData.delete(deleData)
                self.myBarTableView.deleteRows(at: [indexPath], with: .automatic)
                let deletefile = "\(deleData.barID).jpg"
                let document = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents")
                let deleteURL = document.appendingPathComponent(deletefile)
                do{
                    try FileManager.default.removeItem(at: deleteURL)
                }catch{
                    print("")
                }
                MyDatabase.shared.save()
                MyDatabase.shared.FirebaseCopyData()
//                self.saveCoreData()
            }
            controller.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel) { (action:UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }
            controller.addAction(cancelAction)
            
            self.present(controller, animated: true, completion: nil)
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: NSLocalizedString("分享", comment: "") ) { (action, view, completionHandler) in
            
            let uploadbarNameID = self.dataArray[indexPath.row].barName
            let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/\(String(describing: uploadbarNameID)).archive")
            
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities:nil)
    
            self.present(activityController,animated: true)

            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        shareAction.backgroundColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1)
        shareAction.image = UIImage(systemName: "square.and.arrow.up.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
    }
    
    //搜尋
    func filterContent(for searchText:String){
        
        searchBar = dataArray.filter { (bar) -> Bool in
            return bar.barName.contains(searchText) || bar.win.contains(searchText)
        }
    }
    //搜尋2
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            filterContent(for: searchText)
            self.myBarTableView.reloadData()
        }
    }
    
//    func loadFromCoreData(){
//        let moc = CoreDataHelper.shared.managedObjectContext()
//        let fetchRequest = NSFetchRequest<Bar>(entityName: "Bar")
//
//        moc.performAndWait {
//            do{
//                self.dataArray = try moc.fetch(fetchRequest)
//                print("執行coreData檔案匯入\(self.dataArray)")
//            }catch{
//                print("error=\(error)")
//                dataArray=[]
//            }
//        }
//    }
//
//    func saveCoreData(){
//        CoreDataHelper.shared.saveContext()
//    }
    
}
