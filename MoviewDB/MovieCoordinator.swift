//
//  Created by Ireneusz Sołek
//  

import UIKit

final class MovieCoordinator {
  private var window : UIWindow?
  private let rootViewController = UINavigationController()
  
  init(window : UIWindow?) {
    self.window = window
  }
  
  @discardableResult func start() -> UIViewController {
    rootViewController.pushViewController(MovieListViewController(coordinator: self), animated: false)
    self.window?.rootViewController = rootViewController
    self.window?.makeKeyAndVisible()
    return rootViewController
  }
}
