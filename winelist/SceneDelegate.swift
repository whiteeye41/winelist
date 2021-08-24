//
//  SceneDelegate.swift
//  winelist
//
//  Created by cosima on 2020/5/17.
//  Copyright © 2020 cosima. All rights reserved.
//

import UIKit
import Foundation
import LocalAuthentication

class SceneDelegate: UIResponder, UIWindowSceneDelegate{

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        faceID()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func faceID(){
            if UserDefaults.standard.bool(forKey: "senderswitch") {
                let context = LAContext()
                context.localizedCancelTitle = "Cancel"
                var error: NSError?
                if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                    
                    let reason = "Log in to your account"
                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                        if success {
                            DispatchQueue.main.async { [unowned self] in
    //                             self.showMessage(title: "驗證成功", message: nil)
                            }
                        } else {
                            exit(0)
                            DispatchQueue.main.async { [unowned self] in
                                self.showMessage(title: "驗證失敗", message: error?.localizedDescription)
                            }
                        }
                    }
                } else {
                    showMessage(title: "失敗", message: error?.localizedDescription)
                }
                
            }else if UserDefaults.standard.bool(forKey: "senderswitch"){
            }
        }
        
        func showMessage(title: String?, message: String?) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
        }
    }

