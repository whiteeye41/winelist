//
//  MonthlycalendarViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/28.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit
import CoreData

class MonthlycalendarViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = self.selectDataArray[indexPath.row].barName
        cell.detailTextLabel?.text = String(self.selectDataArray[indexPath.row].pick)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysInThisMonth + howManyItemsShouldIAdd
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"cell", for: indexPath) as! CalenderCollectionViewCell
        var day : String?
        if let textLabel = cell.contentView.subviews[0] as? UILabel{
            if indexPath.row < howManyItemsShouldIAdd {
                textLabel.text = ""
            }else{
                day = "\(indexPath.row + 1 - howManyItemsShouldIAdd)"
                textLabel.text = day
            }
            
        }
        
        cell.littleView.isHidden = true
        if let d =  day {
            let formattr = DateFormatter()
            formattr.dateFormat = "yyyy/M/d"
            formattr.timeZone = NSTimeZone.local
            if let todayDate = formattr.date(from: "\(currentYear)/\(currentMonth)/\(d)") {
                for bar in self.dataArray {
                    if let barDate = bar.date {
                        if formattr.string(from: todayDate) == formattr.string(from: barDate) {
                            cell.littleView.isHidden = false
                        }
                    }
                }
            }

            
        }
        return cell
    }
    

    
    var currentYear = Calendar.current.component(.year, from: Date())
    var currentMonth = Calendar.current.component(.month, from: Date())
    
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    var whatDayIsIt:Int{
        let dateComponents = DateComponents(year: currentYear ,month: currentMonth)
        let date = Calendar.current.date(from: dateComponents)!
        return Calendar.current.component(.weekday, from: date)
    }
    
    var howManyItemsShouldIAdd:Int{
        return whatDayIsIt - 1
    }
    var selectDataArray :[Bar] = []
    var bardata : Bar?
    
    @IBOutlet weak var calendar: UICollectionView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func nextMonth(_ sender: UIButton) {
        currentMonth -= 1
        if currentMonth == 0{
            currentMonth = 12
            currentYear -= 1
        }
        setUp()
    }
    
    @IBAction func lastMonth(_ sender: UIButton) {
        currentMonth += 1
        if currentMonth == 13{
            currentMonth = 1
            currentYear += 1
        }
        setUp()
    }
    
    var numberOfDaysInThisMonth:Int{
        let dateComponents = DateComponents(year: currentYear ,month: currentMonth)
        let date = Calendar.current.date(from: dateComponents)!
        let range = Calendar.current.range(of: .day, in: .month,for: date)
        return range?.count ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        self.loadFromCoreData()
    }
    func setUp(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        timeLabel.text = months[currentMonth - 1] + " \(currentYear)"
        calendar.reloadData()
        print(whatDayIsIt)
    }
    
    var dataArray: [Bar] = []
    func loadFromCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<Bar>(entityName: "Bar")

        moc.performAndWait {
            do{
                let result = try moc.fetch(fetchRequest)
                self.dataArray = result
                print("執行coreData檔案匯入self.data = try moc.fetch(request)")

            }catch{
                print("error=\(error)")
                self.dataArray=[]
            }
        }
    }
    
    var selectDateArray: [Bar] = []
    func getTheDataIWant(selectDateInt:Int?){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let mySelectDate = selectDateInt else{ return }
        
        let dateString = "\(currentYear)-\(currentMonth)-\(mySelectDate) 00:00:00"
        let secondDateString = "\(currentYear)-\(currentMonth)-\(mySelectDate) 23:59:59"
        let selectDate = dateFormatter.date(from: dateString)
        let secondDate = dateFormatter.date(from: secondDateString)

        guard let startDayDate = selectDate,
            let endDayDate = secondDate,
        self.dataArray.count != 0 else {
            return
        }
        for x in 0...self.dataArray.count-1{
            guard let checkStartDay = self.dataArray[x].date else{
                print("dataArray[\(x)].startTime沒有值")
                continue
            }
            //比較日期，以下結果我們要讓它值為-1或0
            let checkStartDayResule = (startDayDate.compare(checkStartDay))
            let checkEndDayResule = (checkStartDay.compare(endDayDate))
            if checkEndDayResule.rawValue<1 && checkStartDayResule.rawValue<1{
                print("\(self.dataArray[x])")
                self.selectDataArray.append(self.dataArray[x])

            }
        }
    }
    
    var selectDataInt: Int?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectDataArray.removeAll()
        selectDataInt = (indexPath.row) - (howManyItemsShouldIAdd - 1)
        self.getTheDataIWant(selectDateInt: selectDataInt)
        self.tableView.reloadData()
    }
}


class CalenderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var littleView: UIView!
}
