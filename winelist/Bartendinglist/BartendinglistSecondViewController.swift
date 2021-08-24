//
//  BartendinglistSecondViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/29.
//  Copyright © 2020 cosima. All rights reserved.
//

import Foundation
import UIKit
import CoreData


protocol Getatasecond: class {
    func receiveDatasecond(data:BartendingData)
    
}

class BartendinglistSecondViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource{
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseWineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell.textLabel?.text = self.baseWineArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        self.baseWineArray.remove(at: indexPath.row)
        self.myTableView.deleteRows(at: [indexPath], with: .automatic)
        
    }
    
    //選單畫面
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if myPickerViewCollection.tag == 1{
            switch component {
            case 0:
                return barBaseWines.count
            case 1:
                return number.count
            case 2:
                return unit.count
            default:
                return 1
            }
        }else if myPickerViewCollection.tag == 2{
            switch component {
            case 0:
                return liqueurWine.count
            case 1:
                return number.count
            case 2:
                return unit.count
            default:
                return 1
            }
        }else if myPickerViewCollection.tag == 3{
            switch component {
            case 0:
                return otherWine.count
            case 1:
                return number.count
            case 2:
                return unit.count
            default:
                return 1
            }
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if myPickerViewCollection.tag == 1{
            switch component {
            case 0:
                return barBaseWines[row]
            case 1:
                return number[row]
            case 2:
                return unit[row]
            default:
                return nil
            }
        }else if myPickerViewCollection.tag == 2{
            switch component {
            case 0:
                return liqueurWine[row]
            case 1:
                return number[row]
            case 2:
                return unit[row]
            default:
                return nil
            }
        }else if myPickerViewCollection.tag == 3{
            switch component {
            case 0:
                return otherWine[row]
            case 1:
                return number[row]
            case 2:
                return unit[row]
            default:
                return nil
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
    }
    
    //照片牆
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return princeImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PrinceCollectionViewCell
        cell.winImage.image = princeImages[indexPath.row]
//        myPickerView.reloadAllComponents()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    let images : [String:UIImage] = ["琴酒":UIImage(named: "琴酒")!,"伏特加":UIImage(named: "伏特加")!,"龍舌蘭":UIImage(named: "龍舌蘭")!,"蘭姆酒":UIImage(named: "蘭姆酒")!,"威士忌":UIImage(named: "威士忌")!,"白蘭地":UIImage(named: "白蘭地")!,"Gin":UIImage(named: "Gin")!,"Vodka":UIImage(named: "Vodka")!,"Tequila":UIImage(named: "Tequila")!,"Rum":UIImage(named: "Rum")!,"Whiskey":UIImage(named: "Whiskey")!,"Brandy":UIImage(named: "Brandy")!]
    
    var barBaseWines = [NSLocalizedString("琴酒", comment: ""),NSLocalizedString("伏特加", comment: ""),NSLocalizedString("龍舌蘭", comment: ""),NSLocalizedString("蘭姆酒", comment: ""),NSLocalizedString("威士忌", comment: ""),NSLocalizedString("白蘭地", comment: "")]
    
    let liqueurWine = [NSLocalizedString("香艾酒", comment: ""),NSLocalizedString("苦艾酒", comment: ""   ),NSLocalizedString("君度橙酒", comment: ""),NSLocalizedString("香甜酒", comment: ""),NSLocalizedString("杏仁酒", comment: "")]
    
    let otherWine = [NSLocalizedString("香檳", comment: ""),NSLocalizedString("氣泡酒", comment: ""),NSLocalizedString("葡萄酒", comment: ""),NSLocalizedString("白葡萄酒", comment: ""),NSLocalizedString("啤酒", comment: "")]
    
    let number = ["5","10","15","20","25","30","45","60"]
    let unit = ["mL","oz","dash"]
    
    var beaswine : [BartendingData] = []
    var baseWineArray: [String] = []
    var showBaseWine: String = ""
    var princeImages : [UIImage] = []
    
    
    @IBOutlet weak var myLableField: UITextField!{
        didSet{
            addDoneButtonOnKeyboard()
        }
    }
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var buttonImage: UIButton!
    
    @IBOutlet var myPickerViewCollection: UIView!
    
    @IBOutlet weak var myPickerView: UIPickerView!
    
    @IBOutlet weak var winName: UILabel!
    
    
    @IBOutlet weak var myPrinceCollectionView: PrinceCollectionView!
    
    var datatype:BartendingData?
    
    var basewinedata : String = ""
    
    var wineImage : Bool = true
    
    var delegte : Getatasecond?
    
    var wine:BartendingData?
    
    
    //點選空白處鍵盤消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("完成", comment: ""), style: .done,target: self,action: #selector(doneButtonAction))
        
        var items:[UIBarButtonItem] = []
        
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        self.myLableField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.myLableField.resignFirstResponder()
    }
    
    //酒的照片
    @IBAction func myImage(_ sender: UIButton) {
        let photoSource = UIAlertController(title: nil, message: NSLocalizedString("選擇你的照片來源", comment: "" ), preferredStyle: .actionSheet)
        
        let camerAction = UIAlertAction(title: NSLocalizedString("相機", comment: ""), style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                
                self.present(imagePicker,animated: true,completion: nil)
            }
        }
        
        let photoLibrary = UIAlertAction(title: NSLocalizedString("相簿", comment: ""), style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                self.present (imagePicker , animated: true ,completion: nil)
            }
        }
        photoSource.addAction(camerAction)
        photoSource.addAction(photoLibrary)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil)
        photoSource.addAction(cancelAction)
        present(photoSource, animated: true, completion: nil)
        
    }
    //酒的照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        buttonImage.setImage(image, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    //滑單View
    @IBAction func pickerDone(_ sender: UIButton) {
        disPalyPickerView(show: false)
    }
    
    
    @objc @IBAction func addPickerData(_ sender: UIButton) {
        if myPickerViewCollection.tag == 1{
            let wineIndex = self.myPickerView.selectedRow(inComponent: 0)
            let volumnIndex = self.myPickerView.selectedRow(inComponent: 1)
            let unitIndex = self.myPickerView.selectedRow(inComponent: 2)
            
            print("\(wineIndex) \(volumnIndex) \(unitIndex)")
            //for Coredata
            let wineDetail = "\(barBaseWines[wineIndex])\(number[volumnIndex])\(unit[unitIndex])"
            self.baseWineArray.append(wineDetail)
            //for tableView
            if !self.showBaseWine.contains(barBaseWines[wineIndex]) {
                self.showBaseWine.append("\(barBaseWines[wineIndex])  ")
                self.princeImages.append(images[barBaseWines[wineIndex]]!)
                self.myPrinceCollectionView.reloadData()
            }
            
        }else if myPickerViewCollection.tag == 2{
            let wineIndex = self.myPickerView.selectedRow(inComponent: 0)
            let volumnIndex = self.myPickerView.selectedRow(inComponent: 1)
            let unitIndex = self.myPickerView.selectedRow(inComponent: 2)
            
            print("\(wineIndex) \(volumnIndex) \(unitIndex)")
            let wineDetail = "\(liqueurWine[wineIndex])\(number[volumnIndex])\(unit[unitIndex])"
            self.baseWineArray.append(wineDetail)
            
        }else if myPickerViewCollection.tag == 3{
            let wineIndex = self.myPickerView.selectedRow(inComponent: 0)
            let volumnIndex = self.myPickerView.selectedRow(inComponent: 1)
            let unitIndex = self.myPickerView.selectedRow(inComponent: 2)
            
            print("\(wineIndex) \(volumnIndex) \(unitIndex)")
            let wineDetail = "\(otherWine[wineIndex])\(number[volumnIndex])\(unit[unitIndex])"
            self.baseWineArray.append(wineDetail)
            
        }
        myTableView.reloadData()
    }
    
    @IBAction func barBaseWine(_ sender: UIButton) {
        disPalyPickerView(show: true)
        myPickerViewCollection.tag = 1
        myPickerView.reloadAllComponents()
    }
    
    @IBAction func liqueurWine(_ sender: UIButton) {
        disPalyPickerView(show: true)
        myPickerViewCollection.tag = 2
        myPickerView.reloadAllComponents()
    }
    
    @IBAction func otherWine(_ sender: UIButton) {
        disPalyPickerView(show: true)
        myPickerViewCollection.tag = 3
        myPickerView.reloadAllComponents()
    }
    
    //跳出視窗手動輸入其他材料
    @IBAction func material(_ sender: UIButton) {
        let controller = UIAlertController(title: "", message: NSLocalizedString("需要增加的材料", comment: ""), preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("檸檬汁15mL", comment: "")
            textField.keyboardType = UIKeyboardType.default
        }
        let addAction = UIAlertAction(title: NSLocalizedString("加入", comment: ""), style: .default) { (action) in
            let dataWin = controller.textFields?[0].text
            self.baseWineArray.append(dataWin ?? "")
            self.myTableView.reloadData()
        }
        controller.addAction(addAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    
    
    //自訂PickerView視窗 大小跟動畫
    func disPalyPickerView(show:Bool){
        for bottomDone in view.constraints{
            if bottomDone.identifier == "done"{
                bottomDone.constant = (show) ? -10 : 200
                break
            }
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    //叉叉取消畫面
    @IBAction func backHome(segue:UIStoryboardSegue){
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if self.wine == nil {
//            self.wine = BartendingData(context: CoreDataHelper.shared.managedObjectContext())
//        }
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myPickerView.delegate = self
        myPickerView.dataSource = self
        myTableView.reloadData()
        myPickerView.reloadAllComponents()
    }
    
    
    
    //跳出PickerView
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(myPickerViewCollection)
        myPickerViewCollection.translatesAutoresizingMaskIntoConstraints = false
        myPickerViewCollection.heightAnchor.constraint(equalToConstant: 150).isActive = true
        myPickerViewCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        myPickerViewCollection.trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: -10).isActive = true
        let bottomDone = myPickerViewCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 150 )
        bottomDone.identifier = "done"
        bottomDone.isActive = true
        
        myPickerViewCollection.layer.cornerRadius = 10
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if myLableField.text == ""  {
            let alertController = UIAlertController(title: "", message: NSLocalizedString("調酒名稱未填寫", comment: ""), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        if self.wine == nil {
            self.wine = BartendingData(context: CoreDataHelper.shared.managedObjectContext())
        }
        guard let wine = self.wine else { return }
        
        wine.barTendingWinName = myLableField.text!
        wine.dataWinList = self.showBaseWine
        wine.baseWineArray = self.baseWineArray
        wine.princeImages = self.princeImages
        
        
        if self.wineImage {
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
            let fileName = "\(wine.winIDD).jpg"
            wine.barTendingImage = fileName
        let fileURL = documents.appendingPathComponent(fileName)
            if let imageData = self.buttonImage.currentImage?.jpegData(compressionQuality: 1){
            do {
                try imageData.write(to: fileURL, options: [.atomicWrite])
                wine.barTendingImage = fileName
            }catch{
                print("error saving photo \(error)")
                }
            }
        }
        
        self.delegte?.receiveDatasecond(data: wine)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
