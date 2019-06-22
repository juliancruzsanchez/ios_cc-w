//  OnlineAppCreator.com
//  WebViewGold for iOS // webviewgold.com

import Foundation
import UIKit

public struct Constants {
    
    //In-App Purchase API Settings (details can be configured in App Store Connect)
    static let AppBundleIdentifier = "com.webviewgold.app.IAP"
    static var IAPSharedSecret = "xyzxyzxyzxyzxyzxyzxyz"
    
    static let kAppDelegate         = UIApplication.shared.delegate as! AppDelegate
    static let kUserDefaults        = UserDefaults.standard
    static let kScreenWidth         = UIScreen.main.bounds.width
    static let kScreenHeight        = UIScreen.main.bounds.height
    static let kAppDisplayName      = UIApplication.appName
    static let kAppVersion          = UIApplication.shortVersionString
    static let kCountryCode         = UIApplication.countryCode
    static let kCalendar            = Calendar.current
    static let kDeviceType          = "ios"
    static let kSystemVersion       = UIDevice.current.systemVersion
    static let kModel               = UIDevice.current.model
    static let kDeviceId            = UIDevice.current.identifierForVendor!.uuidString
    
    //General OneSignal SDK options
    static let kPushEnabled         = false; //Set to true to activate the OneSignal push functionality (set App ID in AppDelegate.swift)
    static let kPushEnhanceUrl      = false; //Set to true if you want to extend WebView Main URL requests by ?onesignal_push_id=XYZ
    static let kPushReloadOnUserId  = false; //Set to true if WebView should be reloaded after receiving the UserID from OneSignal

}

public struct AlertMessage{
    static let dataMissing = "Something went wrong. Please try again."
}


