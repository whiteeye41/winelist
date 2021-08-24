//
//  setViewController.swift
//  winelist
//
//  Created by cosima on 2020/5/28.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit
import LocalAuthentication
import StoreKit
import MessageUI
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import AuthenticationServices


public class setCell:UITableViewCell{
    
    
    @IBOutlet weak var setImage: UIImageView!
    
    @IBOutlet weak var setLabel: UILabel!
    
    @IBOutlet weak var setingSwitch: UISwitch!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var isSwitchHide = false {
        didSet{
            self.setingSwitch.isHidden = self.isSwitchHide
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

enum LoginType: String {
    case Facebook = "facebook"
    case SignInWithApple = "signInWithApple"
}

class SetViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        facebookLogin()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSet.count
    }
    
    func signInWithApple(view: UIView) {
        
        self.sign = SignInWithApple(defaultBtn: true, view: view)
        guard let sign = self.sign else { return }
        sign.appleReply = { (data) in
            
            guard let isLogin = data.isLogin else {
                guard let userId = data.userUUID else { return }
                MyDatabase.shared.getDataFromFirebase(userId: userId) {
                    let loginInfo = LoginInfo()
                    if data.name != "" {
                        MyDatabase.shared.saveNameAndIdToLocalAndFirebase(name: data.name, userId: userId, loginType: .SignInWithApple)
                        loginInfo.name = data.name
                    }
                    else {
                        loginInfo.name = UserDefaults.standard.string(forKey: "name")
                    }
                    loginInfo.id = userId
                    loginInfo.loginType = .SignInWithApple
                    MyDatabase.shared.saveNameAndIdToLocalAndFirebase(name:  loginInfo.name, userId:  loginInfo.id, loginType: loginInfo.loginType!)
                    self.loginInfo = loginInfo
                }
                return
            }
            if isLogin {
                let alertController = UIAlertController(title: "", message: NSLocalizedString("你已登入", comment: ""), preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "setCell" , for: indexPath) as! setCell
        cell.setLabel.text = dataSet[indexPath.row]
        
        switch indexPath.row {
        case 0:
            cell.setImage.image = UIImage(systemName: "faceid")
            cell.isSwitchHide = false
            if UserDefaults.standard.bool(forKey: "senderswitch") {
                cell.setingSwitch.isOn = true
            }else if UserDefaults.standard.bool(forKey: "senderswitch"){
                cell.setingSwitch.isOn = false
            }
            
            
        case 1:
            cell.setImage.image = UIImage(named:"facebook")
            cell.isSwitchHide = true
            cell.nameLabel.isHidden = true
            if let loginInfo = self.loginInfo {
                if loginInfo.loginType == .Facebook {
                    cell.nameLabel.text = loginInfo.name
                    cell.nameLabel.isHidden = false
                }
            }
            
        case 2:
            cell.setImage.image = UIImage(named:"appleicon")
            cell.isSwitchHide = true
            cell.nameLabel.isHidden = true
            self.signInWithApple(view: cell.contentView)
            if let loginInfo = self.loginInfo {
                if loginInfo.loginType == .SignInWithApple {
                    cell.nameLabel.text = loginInfo.name
                    cell.nameLabel.isHidden = false
                }
            }
            
        case 3:
            cell.setImage.image = UIImage(systemName: "checkmark.seal")
            cell.isSwitchHide = true
        case 4:
            cell.setImage.image = UIImage(systemName: "envelope")
            cell.isSwitchHide = true
        case 5:
            cell.setImage.image = UIImage(named: "logout")
            cell.isSwitchHide = true
        default:
            break
        }
        return cell
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var myImage: UIImageView!
    
    
    
    var context = LAContext()
    var dataSet: [String]!
    var sign: SignInWithApple?
    var loginInfo: LoginInfo? {
        didSet {
            MyDatabase.userID = self.loginInfo?.id
            self.tableView.reloadData()
        }
    }
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("設定", comment: "")
        self.myImage.image = UIImage(named: "Wineholic-1")
        self.tableView.delegate = self
        
        self.tableView.dataSource = self
        
        dataSet = []
        dataSet.append("FaceID/Touch ID")
        dataSet.append(NSLocalizedString("Facebook登入", comment: ""))
        dataSet.append("")
        dataSet.append(NSLocalizedString("評分", comment: ""))
        dataSet.append(NSLocalizedString("問題回報", comment: ""))
        dataSet.append(NSLocalizedString("登出", comment: ""))
        self.tableView.reloadData()
        self.observeAppleIDSessionChanges()
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.loginInfo = MyDatabase.shared.getLoginInfoFromLocal()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
        }else if indexPath.row == 1{
            if self.loginInfo?.name == nil {
                self.fblogin()
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
            let alertController = UIAlertController(title: "", message: NSLocalizedString("你已登入", comment: ""), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
//            if  (UserDefaults.standard.string(forKey: "signIn") == nil && UserDefaults.standard.string(forKey: "signIn2") == nil){
//                fblogin()
//                tableView.deselectRow(at: indexPath, animated: true)
//            }
//            else {
//                let alertController = UIAlertController(title: "", message: NSLocalizedString("你已登入", comment: ""), preferredStyle: .alert)
//                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(alertAction)
//                present(alertController, animated: true, completion: nil)
//                tableView.deselectRow(at: indexPath, animated: true)
//            }
        }else if indexPath.row == 2{
            tableView.deselectRow(at: indexPath, animated: true)
        }else if indexPath.row == 3{
            askForRating()
            //            SKStoreReviewController.requestReview()
            tableView.deselectRow(at: indexPath, animated: true)
        }else if indexPath.row == 4{
            support()
            tableView.deselectRow(at: indexPath, animated: true)
        }else if indexPath.row == 5{
            facebookOut()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    @IBAction func faceID(_ sender: UISwitch) {
        if sender.isOn == true{
            UserDefaults.standard.set(true, forKey: "senderswitch")
        }else if sender.isOn == false{
            UserDefaults.standard.set(false, forKey: "senderswitch")
        }
    }
    
    func fblogin(){
        LoginManager().logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if error != nil{
                return
            }
            print("attempt to fetch profile......")
            
            let parameters = ["fields": "email, name, picture.type(large)"]
            
            GraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
                connection, result, error -> Void in
                
                if error != nil {
                    print("登入失敗")
                    print("longinerror =\(error)")
                } else {
                    if let resultNew = result as? [String:Any]{
                        print("成功登入")
                        let email = resultNew["email"]  as! String
                        print(email)
                        
                        guard let fbID = resultNew["id"] as? String else { return }
                        
                        MyDatabase.shared.getDataFromFirebase(userId: fbID, complete: {})

                        if let name = resultNew["name"] as? String{
                            MyDatabase.shared.saveNameAndIdToLocalAndFirebase(name: name, userId: fbID, loginType: .Facebook)
                            let loginInfo = LoginInfo()
                            loginInfo.name = name
                            loginInfo.id = fbID
                            loginInfo.loginType = .Facebook
                            self.loginInfo = loginInfo
                        }
                        
                        if let picture = resultNew["picture"] as? NSDictionary,
                            let data = picture["data"] as? NSDictionary,
                            let url = data["url"] as? String {
                            print(url) //臉書大頭貼的url, 再放入imageView內秀出來
                        }
                    }
                }
            })
        }
    }
    
    var userName: String? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    func facebookLogin() {
//        print("attempt to fetch profile......")
//
//        let parameters = ["fields": "email, name, picture.type(large)"]
//
//        GraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
//            connection, result, error -> Void in
//
//            if error != nil {
//                print("登入失敗")
//                print("longinerror =\(error)")
//            } else {
//                if let resultNew = result as? [String:Any]{
//                    print("成功登入")
//                    let email = resultNew["email"]  as! String
//                    print(email)
//
//                    guard let fbID = resultNew["id"] as? String else { return }
//
//                    if let name = resultNew["name"] as? String{
//                        MyDatabase.shared.saveNameAndIdToLocalAndFirebase(name: name, userId: fbID, loginType: .Facebook)
//                        self.userName = name
//                    }
//
//                    if let picture = resultNew["picture"] as? NSDictionary,
//                        let data = picture["data"] as? NSDictionary,
//                        let url = data["url"] as? String {
//                        print(url) //臉書大頭貼的url, 再放入imageView內秀出來
//                    }
//                }
//            }
//        })
    }
    func facebookOut(){
//        if setCell().setLabel != nil{
//            UserDefaults.standard.set(true, forKey: "signIn")
//            UserDefaults.standard.set(true, forKey: "signIn2")
//        }else if setCell().setLabel == nil{
//            UserDefaults.standard.set(false, forKey: "signIn")
//            UserDefaults.standard.set(false, forKey: "signIn2")
//        }
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        LoginManager().logOut()
        self.userName = ""
        self.loginInfo = nil
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.removeObject(forKey: "loginType")
        
        UserDefaults.standard.removeObject(forKey: "signIn")
        UserDefaults.standard.removeObject(forKey: "signIn2")
    }
    
    
    //評分
    func askForRating(){
        let askController = UIAlertController(title: "Hello App User",message: "If you like this app,please rate in App Store. Thanks.",preferredStyle: .alert)
        let laterAction = UIAlertAction(title: NSLocalizedString("稍候再評", comment: ""),style: .default, handler: nil)
        askController.addAction(laterAction)
        let okAction = UIAlertAction(title: NSLocalizedString("我要評分", comment: ""), style: .default)
        { (action) -> Void in
//            let appID = "wineholic"
            let appURL =
                URL(string: "https://apps.apple.com/tw/app/wineholic/id1521495353")!
            UIApplication.shared.open(appURL, options: [:],completionHandler: { (success) in})
        }
        askController.addAction(okAction)
        self.present(askController, animated: true, completion: nil)
    }
    //郵件
    func support(){
        if (MFMailComposeViewController.canSendMail()){
            let alert = UIAlertController(title: "", message: NSLocalizedString("我希望收到你的來信,請通過E-mail寫信給我", comment: ""), preferredStyle: .alert)
            let email = UIAlertAction(title: NSLocalizedString("前往", comment: ""), style: .default, handler: { (action) -> Void in
                let mailController =  MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.title = "Problem report"//視窗開頭
                mailController.setSubject("Problem report")//郵件主旨
                //                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                //                let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                //                let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                //                mailController.setMessageBody(messageBody, isHTML: true)
                mailController.setToRecipients(["qwer1882123@gmail.com"])
                self.present(mailController, animated: true, completion: nil)
            })
            alert.addAction(email)
            self.present(alert, animated: true, completion: nil)
        }else{
            print("傳送失敗")
        }
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { (notification: Notification) in
            // Sign user in or out
            print("Sign user in or out...")
        }
    }
    
    //launchScreen
    private func launchScreenAnimation(){
        guard let launchScreen = UIStoryboard(name: "LaunchScreen", bundle:          nil).instantiateInitialViewController() else {return}
        self.view.addSubview(launchScreen.view)
    }
}


