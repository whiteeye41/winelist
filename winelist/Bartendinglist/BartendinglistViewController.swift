//
//  BartendinglistViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/28.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit
import CoreData

class BartendinglistViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,Getatasecond,UISearchResultsUpdating{
    @objc func receiveDatasecond(data: BartendingData) {
        if let indexPath = self.indexPath{
            self.dataArray.insert(data, at: indexPath.row)
        }else{
            self.dataArray.append(data)
        }
        print("test 被呼叫")
        MyDatabase.BartendingArray.append(data)
        MyDatabase.shared.save()
        MyDatabase.shared.FirebaseCopyData()
//        self.saveCoreData()
        self.myTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive{
            return searchbasewine.count
        }else{
            return dataArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchbase = (searchController.isActive) ? searchbasewine[indexPath.row] : dataArray[indexPath.row]
        let cell = myTableView.dequeueReusableCell(withIdentifier: "barTendingCell", for: indexPath) as! BartendingTableViewCell
        cell.barTendingWinName.text = searchbase.barTendingWinName
        cell.barTendingWinType.text = searchbase.dataWinList
        cell.barTendingImage.image = searchbase.thumbnailImage()
        return cell
    }
    
   
    
   
    @IBOutlet weak var myTableView: UITableView!
    
    
    var baseWinedata : BartendingData?
    
    var searchbasewine :[BartendingData] = []
    
    var dataArray :[BartendingData] = []
    
    var indexPath : IndexPath?
    
    var searchController :UISearchController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyDatabase.shared.loadBarTendingCoreData()
        self.dataArray = MyDatabase.BartendingArray
//        loadFromCoreData()
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        searchController = UISearchController(searchResultsController:nil)
        myTableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater  = self
        self.navigationItem.title = NSLocalizedString("調酒清單", comment: "")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        self.indexPath = indexPath
        self.baseWinedata = self.dataArray[indexPath.row]
        self.performSegue(withIdentifier: "BartendinglistNo1", sender: nil)
        myTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BartendinglistNo2"{
            let adddataSegue = segue.destination as! BartendinglistSecondViewController
            adddataSegue.delegte = self
        }
        if segue.identifier == "BartendinglistNo1"{
            if let indexPath = myTableView.indexPathForSelectedRow{
                 let datasegue = segue.destination as! BartendinglistThirdViewController
                datasegue.wineData = dataArray[indexPath.row]
            }
        }
    }
    
    //刪除1.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("刪除", comment: "")) { (action, view, completionHandler) in
            
            let controller = UIAlertController(title: nil, message: NSLocalizedString("確定要刪除?", comment: ""), preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("刪除", comment: ""), style: .destructive) { (action:UIAlertAction) in
                
                self.dismiss(animated: true, completion: nil)
                let deleData = self.dataArray.remove(at: indexPath.row)
                let coreData = CoreDataHelper.shared.managedObjectContext()
                coreData.delete(deleData)
                self.myTableView.deleteRows(at: [indexPath], with: .automatic)
                
                let deletefile = "\(deleData.winIDD).jpg"
                let document = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents")
                let deleteURL = document.appendingPathComponent(deletefile)
                do{
                    try FileManager.default.removeItem(at: deleteURL)
                }catch{
                    print("")
                }
                MyDatabase.shared.FirebaseCopyData()
                MyDatabase.shared.save()
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
        
        let shareAction = UIContextualAction(style: .normal, title: NSLocalizedString("分享", comment: "")) { (action, view, completionHandler) in
            
            let uploadbarNameID = self.dataArray[indexPath.row].barTendingWinName
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
        
        searchbasewine = dataArray.filter({ (bartendingData) -> Bool in
            return bartendingData.barTendingWinName.contains(searchText) || bartendingData.dataWinList!.contains(searchText)
        })
    }
    //搜尋2
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            filterContent(for: searchText)
            self.myTableView.reloadData()
        }
    }
    
//    func loadFromCoreData(){
//        let moc = CoreDataHelper.shared.managedObjectContext()
//        let fetchRequest = NSFetchRequest<BartendingData>(entityName: "WineList")
//
//        moc.performAndWait {
//            do{
//                let result = try moc.fetch(fetchRequest)
//                self.dataArray = result
//                print("執行coreData檔案匯入self.data = try moc.fetch(request)")
//
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
