//
//  SignInWithApple.swift
//
//  Created by Gordan_Feng on 2020/3/24.
//

import UIKit
import AuthenticationServices
class SignInReply {
    var errorMessage: String?
    var userUUID: String?
    var name: String?
    var email: String?
    var isLogin: Bool?
}

@available(iOS 13.0, *)
class SignInWithApple: NSObject {
    
    var view: UIView?
    var controller: ASAuthorizationController?
    
    var appleReply: ((SignInReply) -> Void)?

    @objc init(defaultBtn: Bool = false, view: UIView? = nil) {
        super.init()
        self.getStart()
        
        if defaultBtn {
            self.view = view
            self.makeDefaultBtn()
        }
    }
    
    private func getStart() {
        let authorizationAppleIDRequest: ASAuthorizationAppleIDRequest = ASAuthorizationAppleIDProvider().createRequest()
        authorizationAppleIDRequest.requestedScopes = [.fullName, .email]
        self.controller = ASAuthorizationController(authorizationRequests: [authorizationAppleIDRequest])
        guard let controller = self.controller else { return }
        controller.delegate = self
    }
    
    @objc func signInAction() {
        if  (UserDefaults.standard.string(forKey: "name") == nil && UserDefaults.standard.string(forKey: "userID") == nil){
            if let controller = controller {
                controller.performRequests()
            }
        }else {
            let signData = SignInReply()
            signData.isLogin = true
            guard let appleReply = appleReply else { return }
            appleReply(signData)
        }
    }
    
    private func makeDefaultBtn() {
        if let view = view {
            let gr = UITapGestureRecognizer(target: self, action: #selector(signInAction))
            view.addGestureRecognizer(gr)

            let authAppleBtn: ASAuthorizationAppleIDButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle:.white)
            //view.frame = CGRect(x: 0, y:0, width: 180, height: 30)
            //authAppleBtn.frame = view.bounds
            authAppleBtn.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(authAppleBtn)
            authAppleBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            authAppleBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 80).isActive = true
        }
    }
}

@available(iOS 13.0, *)
extension SignInWithApple: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
//            let idToken = String(data: appleIDCredential.identityToken!, encoding: String.Encoding.utf8)
            let signReply = SignInReply()
            let newUserID = appleIDCredential.user.replace(target: ".", withString: "")
            signReply.userUUID = newUserID
            signReply.name = "\(appleIDCredential.fullName?.familyName ?? "")\(appleIDCredential.fullName?.givenName ?? "")"
            signReply.email = appleIDCredential.email
            guard let appleReply = appleReply else { return }
            appleReply(signReply)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let signInReply = SignInReply()
        
        switch (error) {
        case ASAuthorizationError.canceled:
            signInReply.errorMessage = "AppleReply登入取消"
            break
        case ASAuthorizationError.failed:
            signInReply.errorMessage = "AppleReply登入失敗"
            break
        case ASAuthorizationError.invalidResponse:
            signInReply.errorMessage = "AppleReply無效回應"
            break
        case ASAuthorizationError.notHandled:
            signInReply.errorMessage = "AppleReply未處理"
            break
        case ASAuthorizationError.unknown:
            signInReply.errorMessage = "AppleReply未知錯誤"
            break
        default:
            signInReply.errorMessage = "AppleReply未知錯誤"
            break
        }
        guard let appleReply = appleReply else { return }
        appleReply(signInReply)
        print("didCompleteWithError: \(error.localizedDescription)")
    }
}
