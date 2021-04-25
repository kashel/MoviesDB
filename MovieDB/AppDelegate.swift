//
//  Created by Ireneusz Sołek
//  

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var movieCoordinator: MovieCoordinator!
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    movieCoordinator = MovieCoordinator(window: window)
    movieCoordinator.start()
    return true
  }

}

