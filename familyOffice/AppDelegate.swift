//
//  AppDelegate.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 03/01/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import ReSwift


let store = Store<AppState>(
    reducer: appReducer,
    state: nil,
    middleware: [realmMiddleware] )
var notificationarray = [NotificationModel]()
var pendingNotification : NotificationModel!
let Userdefault = UserDefaults.standard
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 8.0, *){
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
            connectToFcm()
        }
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            let not = NotificationModel(dic: notification)
            pendingNotification = not
        }
        
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (notifications) in
            notifications.enumerated().forEach({ (index, notification) in
                let not = NotificationModel(notifiaction: notification)
                notificationarray.append(not)
            })
        })
        if notificationarray.count > 0 {
             rManager.saveObjects(objs: notificationarray)
        }
       
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        application.registerForRemoteNotifications()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)
        
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let not = NotificationModel(dic: userInfo)
        
        rManager.save(objs: not)
        let state = UIApplication.shared.applicationState
        
        if pendingNotification == nil, state == .inactive {
            gotoNotification(not)
            
        }
        
    }
    var top: UIViewController? {
        get {
            return topViewController()
        }
    }
    
    
    func topViewController(from viewController: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let tabBarViewController = viewController as? UITabBarController {
            return topViewController(from: tabBarViewController.selectedViewController)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        } else if let presentedViewController = viewController?.presentedViewController {
            return topViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                       accessToken: (authentication?.accessToken)!)
        store.dispatch( AuthSvc(.loginWithCredentials(credential: credential)))
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("-------------------------")
        print(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    @objc func tokenRefreshNotification(_ notification: NSNotification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            Userdefault.set(refreshedToken, forKey: "token")
            service.NOTIFICATION_SERVICE.token = refreshedToken
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(String(describing: error))")
              
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
}
