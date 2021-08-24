//
//  Firebase.swift
//  winelist
//
//  Created by cosima on 2020/7/4.
//  Copyright © 2020 cosima. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit


class LoginInfo {
    var name: String?
    var id: String?
    var loginType: LoginType?
}

class MyDatabase{
    
    static let shared = MyDatabase()
    static var userID:String?
    static var dataSignltonArray:[Bar] = []
    static var BartendingArray:[BartendingData] = []
    var ref: DatabaseReference!
    
    //    func callReloadTableView(){
    //        NotificationCenter.default.post(name: Notification.Name("reloadDataArray"), object: nil)
    //    }
    
    func save(){
        CoreDataHelper.shared.saveContext()
    }
    
    func loadBarArrayCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<Bar>(entityName: "Bar")
        moc.performAndWait {
            do{
                MyDatabase.dataSignltonArray = try moc.fetch(fetchRequest)
                print("執行coreData檔案匯入\(MyDatabase.dataSignltonArray.count)")
            }catch{
                print("error\(error)")
                MyDatabase.dataSignltonArray=[]
            }
        }
    }
    func loadBarTendingCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<BartendingData>(entityName: "WineList")
        moc.performAndWait {
            do{
                MyDatabase.BartendingArray = try moc.fetch(request)
            }catch{
                print("error\(error)")
                MyDatabase.BartendingArray = []
            }
        }
    }
    
    func getDataFromFirebase(userId: String, complete: @escaping () -> Void) {
        let ref = Database.database().reference()
        ref.child(userId).observeSingleEvent(of: .value) { (data) in
            if let dictionary = data.value as? Dictionary<String, Any> {
                
                if let userName = dictionary["userName"] as? Dictionary<String, String>{
                    UserDefaults.standard.set(userName["userName"], forKey: "name")
                }
                
                if let barListDictionary = dictionary["barList"] as? Dictionary<String, Any> {
                    barListDictionary.keys.forEach { (key) in
                        if let barDictionary = barListDictionary[key] as? Dictionary<String, Any> {
                            
                            let moc = CoreDataHelper.shared.managedObjectContext()
                            let barList = Bar(context: moc)
                            
                            for (key, value) in barDictionary {
                                switch key {
                                case "barName":
                                    barList.barName = "\(value)"
                                    break
                                case "baraddress":
                                    barList.baraddress = "\(value)"
                                    break
                                case "win":
                                    barList.win = "\(value)"
                                    break
                                case "pick":
                                    barList.pick = Int64("\(value)") ?? 0
                                    break
                                case "imageName":
                                    barList.imageName =  "\(value)"
                                    break
                                case "date":
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss zzz"
                                    barList.date = dateFormatter.date(from: "\(value)")
                                    break
                                case "barID":
                                    barList.barID = "\(value)"
                                    break
                                default:
                                    print("not going here")
                                }
                                
                            }
                            MyDatabase.dataSignltonArray.append(barList)
                            self.save()
                        }
                    }
                }
            }
            complete()
        }
    }
    
    func getLoginInfoFromLocal() -> LoginInfo {
        let loginInfo = LoginInfo()
        loginInfo.name = UserDefaults.standard.string(forKey: "name")
        loginInfo.id = UserDefaults.standard.string(forKey: "userID")
        if let typeString = UserDefaults.standard.string(forKey: "loginType") {
            if typeString == LoginType.Facebook.rawValue {
                loginInfo.loginType = .Facebook
            }
            else if typeString == LoginType.SignInWithApple.rawValue {
                loginInfo.loginType = .SignInWithApple
            }
        }
        return loginInfo
    }
    
    func saveNameAndIdToLocalAndFirebase(name: String?, userId: String?, loginType: LoginType) {

        guard let name = name,
            let userId = userId else { return }
        self.ref = Database.database().reference()
        self.ref.child("\(userId)").child("userName").setValue(["userName":"\(name)"])
        MyDatabase.userID = "\(userId)"
        UserDefaults.standard.set(userId, forKey: "userID")
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.set(loginType.rawValue, forKey: "loginType")
        self.FirebaseCopyData()
    }
    
    func FirebaseCopyData(){
        if let id = UserDefaults.standard.string(forKey: "userID") {
            MyDatabase.userID = id
        }
        guard let userID = MyDatabase.userID else {
            print("沒有登入狀態下，無法上傳資料到firebase")
            return
        }
//        guard MyDatabase.dataSignltonArray.count != 0,MyDatabase.BartendingArray.count != 0 else{
//            print("data or worklist沒有資料，無法上傳到firebase")
//            return
//        }
        self.ref = Database.database().reference()
        guard MyDatabase.dataSignltonArray.count != 0 else { return }
        for x in 0...MyDatabase.dataSignltonArray.count-1{
            self.ref.child(userID).child("barList").child(MyDatabase.dataSignltonArray[x].barID).setValue(
                ["barName":MyDatabase.dataSignltonArray[x].barName
                    ,"win":MyDatabase.dataSignltonArray[x].win
                    ,"baraddress":MyDatabase.dataSignltonArray[x].baraddress
                    ,"pick":MyDatabase.dataSignltonArray[x].pick
                    ,"imageName":MyDatabase.dataSignltonArray[x].imageName ?? ""
                    ,"date":"\(MyDatabase.dataSignltonArray[x].date)"
                    ,"barID":MyDatabase.dataSignltonArray[x].barID
                ]
            )
        }
        
        guard MyDatabase.BartendingArray.count != 0 else { return }
        for x in 0...MyDatabase.BartendingArray.count-1{
//        guard let WinebaseName = MyDatabase.BartendingArray[x].winIDD else{
//            continue
//        }
            self.ref.child(userID).child("WinebaseName").child(MyDatabase.BartendingArray[x].winIDD).setValue(
                ["barTendingImage":MyDatabase.BartendingArray[x].barTendingImage ?? ""
                    ,"barTendingWinName":MyDatabase.BartendingArray[x].barTendingWinName
                    ,"barTendingWinType":MyDatabase.BartendingArray[x].barTendingWinType ?? ""
                    ,"dataWinList":MyDatabase.BartendingArray[x].dataWinList ?? ""
                    ,"winIDD":MyDatabase.BartendingArray[x].winIDD
                    ,"baseWineArray":MyDatabase.BartendingArray[x].baseWineArray ?? ""
                ]
            )
        }
    }

    func dateToString(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: NSLocalizedString("zh-TW", comment: ""))
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

extension String{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
