//
//  SceneDelegate.swift
//  RxSwiftLearn
//
//  Created by Nguyễn Hồng Lĩnh on 04/05/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController =
            UINavigationController(rootViewController:
                                    CategoriesViewController(nibName: String(describing: CategoriesViewController.self),
                                                             bundle: nil))
            
        self.window?.makeKeyAndVisible()
    }


}

