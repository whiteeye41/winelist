//
//  BarSecondViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/20.
//  Copyright © 2020 cosima. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseAuth

protocol GetataFirst: class {
    func receiveData(data:Bar)
}

class BarSecondViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1){
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    @IBOutlet var barNameTextField :BarsUITextField!{
        didSet{
            barNameTextField.tag = 1
            barNameTextField.becomeFirstResponder()
            barNameTextField.delegate = self
        }
    }
    
    @IBOutlet var addTextField : BarsUITextField!{
        didSet{
            addTextField.tag = 2
            addTextField.becomeFirstResponder()
            addTextField.delegate = self
        }
    }
    
    @IBOutlet var winTextField : BarsUITextField!{
        didSet{
            winTextField.tag = 3
            winTextField.becomeFirstResponder()
            winTextField.delegate = self
        }
    }
    
    @IBOutlet var picTextField : BarsUITextField!{
        didSet{
            picTextField.tag = 4
            picTextField.becomeFirstResponder()
            picTextField.delegate = self
            picTextField.borderStyle = UITextField.BorderStyle.roundedRect
            picTextField.keyboardType = UIKeyboardType.decimalPad
            addDoneButtonOnKeyboard()
        }
    }
    
    @IBOutlet weak var dateTextField: BarsUITextField!{
        didSet{
            dateTextField.tag = 5
            dateTextField.becomeFirstResponder()
            dateTextField.delegate = self
//            let formattr = DateFormatter()
//            formattr.dateFormat = "yyyy/M/d HH:mm"
//            formattr.timeZone = NSTimeZone.local
//            let string = formattr.string(from: Date())
            let string = MyDatabase.shared.dateToString(date: Date())
            dateTextField.text = "\(string)"
            print("\(string)")
        }
    }
    

    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var barImage: UIImageView!
    
    weak var delegate : GetataFirst?
    var notifyto : BarListViewController?
    var isNewImage : Bool = false
    var textField:UITextField!
    var bartype:Bar?
    var address: String?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bartype = self.bartype {
            self.barNameTextField.text = bartype.barName
            self.addTextField.text = bartype.baraddress
            self.winTextField.text = bartype.win
            self.picTextField.text = String("\(bartype.pick)")
//            let formattr = DateFormatter()
//            formattr.dateStyle = .full
//            formattr.locale = Locale(identifier: NSLocalizedString("zh-TW", comment: ""))
//            self.dateTextField.text = MyDatabase.shared.dateToString(date: bartype.date!)
//            self.dateTextField.text = formattr.string(from: bartype.date!)
            if let date = bartype.date {
                self.dateTextField.text = MyDatabase.shared.dateToString(date: date)
            }
            
            self.barImage.image = bartype.image()
        }
        else {
            self.addTextField.text = self.address
        }
        addDoneButtonOnKeyboard()
    }
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
        self.picTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.picTextField.resignFirstResponder()
        }

    @IBAction func camera(_ sender: Any) {
        let photoSource = UIAlertController(title: nil, message: NSLocalizedString("選擇你的照片來源", comment: ""), preferredStyle: .actionSheet)
        
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
        
        let cancelAction = UIAlertAction(title:  NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil)
        photoSource.addAction(cancelAction)
        present(photoSource, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.barImage.image = image
        self.isNewImage = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        if barNameTextField.text == "" || addTextField.text == "" || winTextField.text == "" || picTextField.text == "" || dateTextField.text == "" {
            let alertController = UIAlertController(title: "", message: NSLocalizedString("請檢查其他欄位未填寫", comment: ""), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        if self.bartype == nil {
            self.bartype = Bar(context: CoreDataHelper.shared.managedObjectContext())
        }
        guard let bartype = self.bartype else { return }
        
        bartype.barName = barNameTextField.text!
        bartype.win = winTextField.text!
        bartype.baraddress = addTextField.text!
        bartype.pick = Int64(picTextField.text!)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: NSLocalizedString("zh-TW", comment: ""))
//        bartype.date = formattr.date(from: dateTextField.text!)
        bartype.date = dateFormatter.date(from: dateTextField.text!)

            if self.isNewImage {
            let homeURL = URL(fileURLWithPath: NSHomeDirectory())
            let documents = homeURL.appendingPathComponent("Documents")
            let fileName = "\(bartype.barID).jpg"
            bartype.imageName = fileName
            let fileURL = documents.appendingPathComponent(fileName)
            if let imageData = self.barImage.image?.jpegData(compressionQuality: 1){
                do {
                    try imageData.write(to: fileURL, options: [.atomicWrite])
                    bartype.imageName = fileName
                }catch{
                    print("error saving photo \(error)")
                    }
                }
            }

        self.delegate?.receiveData(data: bartype)
        self.navigationController?.popViewController(animated: true)
        print("barNameTextField: \(barNameTextField.text ?? "")")
        print("addTextField: \(addTextField.text ?? "")")
        print("winTextField: \(winTextField.text ?? "")")
        print("picTextField: \(picTextField.text ?? "")")
        print("dateTextField: \(dateTextField.text ?? "")")
        
        dismiss(animated: true, completion: nil)
    }
}
