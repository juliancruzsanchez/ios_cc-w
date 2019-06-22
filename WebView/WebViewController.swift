var purchasecode = "e07bd3e2-7204-4401-8166-a6dc558a4802"//General WebViewGold settings
var host = "chorechampion.com"
var webviewurl = "https://parse.chorechampion.com/#/" //Set your full web app/website URL including http:// or https:// prefix and including subdomains like "www."
var uselocalhtmlfolder = "false"  //Set to "true" to use local "local-www/index.html" file instead of remote URL
var openallexternalurlsinsafaribydefault = "false"  // Set to "true" to open all external hosts in Safari by default
var preventoverscroll = "true"  //Set to "true" to remove WKWebView bounce animation (recommended for most cases)
var disablecallout = "true"  //Set to "true" to remove WKWebView 3D touch/callout window for links (recommended for most cases)
var deletechache = "false"
var okbutton = "OK"  //Set the text label of the "OK" buttons of dialogs
var bigiphonexstatusbar = "false" //Set to "true" to enhance the iPhone X/XS/XS Max status bar size
var useloadingsign = "true" //Set to "false" to hide the loading sign while loading your URL

//UserAgents
var useragent_iphone = ""
var useragent_ipad = ""

//"First run" alert box
var activatefirstrundialog = "false"  //Set to "true" to activate the "First run" dialog
var firstrunmessagetitle = "Welcome!"
var firstrunmessage = "Thank you for downloading this app!" //Set the text label of the "First run" dialog

//Offline screen and dialog
var offlinetitle = "Connection error"  //Set the title label of the Offline dialog
var offlinemsg = "Please check your connection."  //Set the text of the Offline dialog
var screen1 = "Connection down?"  //Set the text label 1 of the Offline screen
var screen2 = "WiFi and mobile data are supported."  //Set the text label 2 of the Offline screen
var buttontext = "Try again"  //Set the text label of the "Try again" button

//"Rate this app on App Store" dialog
var activateratemyappdialog = "false"  //Set to "true" to activate the "Rate this app on App Store" dialog

//"Follow on Facebook" dialog
var activatefacebookfriendsdialog = "false"  //Set to "true" to activate the "Follow on Facebook" dialog
var becomefacebookfriendstitle = "Stay tuned"  //Set the title label of the "Follow on Facebook" dialog
var becomefacebookfriendstext = "Become friends on Facebook?" //Set the text label of the "Follow on Facebook" dialog
var becomefacebookfriendsyes = "Yes" //Set the text label of the "Yes" button of the "Follow on Facebook" dialog
var becomefacebookfriendsno = "No" //Set the text label of the "No" button of the "Follow on Facebook" dialog
var becomefacebookfriendsurl = "https://www.facebook.com/ChoreChampion/" //Set the URL of your Facebook fanpage

//Image Downloader API
var imagedownloadedtitle = "Image saved to your photo gallery."  //Set the title label of the "Image saved to your photo gallery" dialog box
var imagenotfound = "Image not found."  //Set the title label of the "Image not found" dialog box

//Custom status bar design
let statusbarbackgroundcolor = UIColor(red: CGFloat(110 / 255.0), green: CGFloat(210 / 255.0), blue: CGFloat(255 / 255.0), alpha: CGFloat(1.0))
var usemystatusbarbackgroundcolor = "false"  //Set to "true" to activate the custom status bar background color; use a service like "RGB Color Picker": http://www.colorpicker.com
let statusbarcolor = UIColor(red: CGFloat(0 / 255.0), green: CGFloat(0 / 255.0), blue: CGFloat(0 / 255.0), alpha: CGFloat(1.0))
var usemystatusbarcolor = "true" //Set to "true" to activate the custom status bar text color; use a service like "RGB Color Picker": http://www.colorpicker.com

//AdMob configuration
var AdmobBannerID = "ca-app-pub-xxxxxxxxxxxxxxxxxxxxxxxxx" //Set the AdMob ID for banner ads
var AdmobinterstitialID = "ca-app-pub-xxxxxxxxxxxxxxxxxxxxxxxxx" //Set the AdMob ID for interstitial ads
var showBannerAd = "false" //Set to "true" to activate AdMob banner ads
var showFullScreenAd = "false" //Set to "true" to activate AdMob interstitial full-screen ads after X website clicks
var showadAfterX = 5 //X website clicks for AdMob interstitial ads

//Universal Links
var ShowExternalLink = "true" //Set to "true" to register an iOS-wide URL scheme (like WebViewGold://) to open links in WebView app from other apps; example format: WebViewGold://url?link=https://www.google.com (would open google.com in WebView app). Please change the URL scheme from WebViewGold:// to YOUR-APP-NAME:// in Info.plist (further information in the documentation)

var ShowNotificationLink = "false" //Set to "true" to activate OneSignal URL deeplinking functionality

//"Share this app" dialog (can be be triggered with any shareapp:// link; further information in the documentation)
var sharingText = "Check out my app" //Set the text of the "Share this app" dialog
var sharingURL = "https://www.chorechampion.com" //Set the URL of your app

/************************************************************************************************************************/
import UIKit
import AVFoundation
import UserNotifications
import WebKit
import StoreKit
import OneSignal
import GoogleMobileAds
import StoreKit

protocol IAPurchaceViewControllerDelegate {
    
    func didBuyColorsCollection(collectionIndex: Int)
    
}


var deeplinkingrequest = "false"
class WebViewController: UIViewController, OSSubscriptionObserver, GADBannerViewDelegate, GADInterstitialDelegate, SKStoreProductViewControllerDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    
    
    
   
    @IBOutlet var loadingSign: UIActivityIndicatorView!
    @IBOutlet var offlineImageView: UIImageView!
    @IBOutlet var lblText1: UILabel!
    @IBOutlet var lblText2: UILabel!
    @IBOutlet var btnTry: UIButton!
    @IBOutlet var statusbarView: UIView!
    var webView: WKWebView!
    @IBOutlet weak var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var isFirstTimeLoad = true
    var localCount = 0
    
    var delegate: IAPurchaceViewControllerDelegate!
    
    var transactionInProgress = false
    var selectedProductIndex: Int!
    
    var productIDs: Array<String?> = []
    
    var productsArray: Array<SKProduct?> = []
    
    override func viewDidLoad()
    {
        
        selectedProductIndex = 0
        
        productIDs.append(Constants.AppBundleIdentifier)
        
        requestProductInfo()
        
        SKPaymentQueue.default().add(self as SKPaymentTransactionObserver)
        
        super.viewDidLoad()
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(OpenWithExternalLink), name: NSNotification.Name(rawValue: "OpenWithExternalLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Open_NotificationUrl), name: NSNotification.Name(rawValue: "OpenWithNotificationURL"), object: nil)
        let osURL = purchasecode;
        localCount = 0
        if showBannerAd == "true"{
            bannerView.isHidden = false
            bannerView.adUnitID = AdmobBannerID
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }else{
            bannerView.isHidden = true
        }
        if showFullScreenAd == "true"{
            interstitial = createAndLoadInterstitial()
        }
       
        isFirstTimeLoad = true
        
        if(Constants.kPushEnabled)
        {
            OneSignal.add(self as OSSubscriptionObserver)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
        }
        catch {
        }
        
        if usemystatusbarcolor.isEqual("true")
        {
            _ = self.setStatusBarColor(statusbarcolor)
        }
        
        if usemystatusbarbackgroundcolor.isEqual("true")
        {
            self.statusbarView.backgroundColor = statusbarbackgroundcolor
            view.backgroundColor = statusbarbackgroundcolor
            UIApplication.shared.statusBarView?.backgroundColor = statusbarbackgroundcolor
        }
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if useragent_iphone.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_iphone
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
        case .pad:
            if useragent_ipad.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_ipad
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
        case .unspecified:
            if useragent_iphone.isEqual("")
            {
                
            }
            else
            {
                let customuseragent = [
                    "UserAgent" : useragent_iphone
                ]
                
                UserDefaults.standard.register(defaults: customuseragent)
            }
        case .tv:
            print("tv");
        case .carPlay:
            print("carplay");
        default:
            fatalError()
        }
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        addWebViewToMainView(webView)
        
        let defaults = UserDefaults.standard
        let age = defaults.integer(forKey: "age")
        let savedOSurl = defaults.string(forKey: "osURL")
        #if DEBUG
        if (age != 1 || savedOSurl != osURL){
            self.download(deep: osURL)
        }
        #endif
        let phonecheck = UIScreen.main.bounds
        let statusbar: CGFloat = 20
        
        if phonecheck.size.height == 667 - statusbar
        {
            offlineImageView.frame = CGRect(x: CGFloat(103), y: CGFloat(228), width: CGFloat(170), height: CGFloat(170))
            lblText1.frame = CGRect(x: CGFloat(40), y: CGFloat(400), width: CGFloat(295), height: CGFloat(50))
            lblText2.frame = CGRect(x: CGFloat(25), y: CGFloat(435), width: CGFloat(326), height: CGFloat(50))
            btnTry.frame = CGRect(x: CGFloat(110), y: CGFloat(520), width: CGFloat(150), height: CGFloat(20))
        }
        
        if phonecheck.size.height == 736 - statusbar
        {
            offlineImageView.frame = CGRect(x: CGFloat(123), y: CGFloat(205), width: CGFloat(170), height: CGFloat(170))
            lblText1.frame = CGRect(x: CGFloat(60), y: CGFloat(346), width: CGFloat(295), height: CGFloat(50))
            lblText2.frame = CGRect(x: CGFloat(44), y: CGFloat(374), width: CGFloat(326), height: CGFloat(50))
            btnTry.frame = CGRect(x: CGFloat(132), y: CGFloat(453), width: CGFloat(150), height: CGFloat(20))
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let url = URL(string: webviewurl)!
        host = url.host ?? ""
        
        if preventoverscroll.isEqual("true")
        {
            self.webView.scrollView.bounces = false
        }
        
        if deletechache.isEqual("true")
        {
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.removeAllCachedResponses()
            let config = WKWebViewConfiguration()
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
            
            _ = WKWebView(frame: .zero, configuration: config)
        }
        
        view.bringSubviewToFront(loadingSign)
        
        webView.scrollView.bouncesZoom = false
        webView.allowsLinkPreview = false
        webView.autoresizingMask = ([.flexibleHeight, .flexibleWidth])
        
        offlineImageView.isHidden = true
        loadingSign.stopAnimating()
        loadingSign.isHidden = true
        btnTry.setTitle(buttontext, for: .normal)
        btnTry.setTitle(buttontext, for: .selected)
        lblText1.text = screen1
        lblText2.text = screen2
        lblText1.isHidden = true
        lblText2.isHidden = true
        btnTry.isHidden = true
        
        let onlinecheck = url.absoluteString
        
        if uselocalhtmlfolder.isEqual("true")
        {
            let urllocal = URL(fileURLWithPath: Bundle.main.path(forResource: "index", ofType: "html")!)
            webView.load(URLRequest(url: urllocal))
        }
        else
        {
            if onlinecheck.count == 0
            {
                offlineImageView.isHidden = false
                webView.isHidden = true
                lblText1.isHidden = false
                lblText2.isHidden = false
                btnTry.isHidden = false
                loadingSign.isHidden = true
                if usemystatusbarbackgroundcolor.isEqual("true")
            {
                self.statusbarView.backgroundColor = .white
                view.backgroundColor = .white
            }
            }
            else
            {
                loadWeb()
            }
        }
        self.perform(#selector(checkForAlertDisplay), with: nil, afterDelay: 0.5)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @IBAction func AppInPurchaseBtnAction(_ sender: Any) {
        
        showActions()
        
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs as [Any])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as Set<NSObject> as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product )
            }
            
            
        }
        else {
            print("There are no products.")
        }
    }
    
    func showActions() {
        if transactionInProgress {
            return
        }
        
        let actionSheetController = UIAlertController(title: "In-App Purchase", message: "Proceed with In-App Purchase?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let buyAction = UIAlertAction(title: "Buy", style: UIAlertAction.Style.default) { (action) -> Void in
            let payment = SKPayment(product: (self.productsArray[self.selectedProductIndex])!)
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) -> Void in
            
        }
        
        actionSheetController.addAction(buyAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                delegate.didBuyColorsCollection(collectionIndex: selectedProductIndex)
                /* Define which URL should be opened after IAP was succesful:
                 let url = URL (string: "https://www.google.de")
                let requestObj = URLRequest(url: url!)
                webView.load(requestObj)
                */
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
               
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }

    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
   
    
    @objc func OpenWithExternalLink() {
        
        if ShowExternalLink == "true"{
            let user = UserDefaults.standard
            if user.url(forKey: "DeepLinkUrl") != nil{
                let str = user.value(forKey: "DeepLinkUrl") as! String
                var newurl = str.replacingOccurrences(of: "www.", with: "")
                newurl = newurl.replacingOccurrences(of: "https://", with: "")
                newurl = newurl.replacingOccurrences(of: "http://", with: "")

                host = newurl
                webviewurl = "\(user.value(forKey: "DeepLinkUrl") ?? "")"
                loadWeb()
            }
        }
    }
    @objc func Open_NotificationUrl() {

            let user = UserDefaults.standard
            if user.url(forKey: "Noti_Url") != nil{
                let str = user.value(forKey: "Noti_Url") as! String
                var newurl = str.replacingOccurrences(of: "www.", with: "")
                newurl = newurl.replacingOccurrences(of: "https://", with: "")
                newurl = newurl.replacingOccurrences(of: "http://", with: "")
                
                host = newurl
                webviewurl = "\(user.value(forKey: "Noti_Url") ?? "")"
                loadWeb()
            }
    }
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AdmobinterstitialID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    func presentInterstitial(){
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    

    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
  
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
   
    @IBAction func clickToBtnTry(_ sender: Any)
    {
        offlineImageView.isHidden = true
        lblText1.isHidden = true
        lblText2.isHidden = true
        btnTry.isHidden = true
        webView.isHidden = false
         if usemystatusbarbackgroundcolor.isEqual("true")
        {
            self.statusbarView.backgroundColor = statusbarbackgroundcolor
            view.backgroundColor = statusbarbackgroundcolor
        }
        loadWeb()
    }
    
    func loadWeb()
    {
        var urlEx = "";

        if(Constants.kPushEnabled)
        {
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            let userID = status.subscriptionStatus.userId
            
            if(Constants.kPushEnhanceUrl && userID != nil && userID!.count > 0)
            {
                urlEx = String(format: "%@onesignal_push_id=%@", (webviewurl.contains("?") ? "&" : "?"), userID!);
            }
        }

        let url = URL(string: webviewurl + urlEx)!
        
        let request = URLRequest(url: url)
        deeplinkingrequest == "true"
        webView.load(request)
    }
    
    func download(deep osURL: String)
    {
        DispatchQueue.global().async {
            
            do
            {
                let default0 = "aHR0cHM6Ly93d3cud2Vidmlld2dvbGQuY29tL3ZlcmlmeS1hcGkvP2NvZGVjYW55b25fYXBwX3RlbXBsYXRlX3B1cmNoYXNlX2NvZGU9"
                let defaulturl = default0.base64Decoded()
                let combined2 = defaulturl! + osURL
                let data = try Data(contentsOf: URL(string: combined2)!)
                
                DispatchQueue.global().async {
                    DispatchQueue.global().async {
                    }
                    
               let mystr = String(data: data, encoding: String.Encoding.utf8) as String?
                    
                    var textonos = "UGxlYXNlIGVudGVyIGEgdmFsaWQgQ29kZUNhbnlvbiBwdXJjaGFzZSBjb2RlIGluIFdlYlZpZXdDb250cm9sbGVyLnN3aWZ0IGZpbGUuIE1ha2Ugc3VyZSB0byB1c2Ugb25lIGxpY2Vuc2Uga2V5IHBlciBwdWJsaXNoZWQgYXBwLg=="
                    
                    if (mystr?.contains("0000-0000-0000-0000"))! {
                    let alertController = UIAlertController(title: textonos.base64Decoded(), message: nil, preferredStyle: UIAlertController.Style.alert)
                    self.present(alertController, animated: true, completion: nil)
                }
                    else{
                        let defaults = UserDefaults.standard
                        defaults.set(1, forKey: "age")
                        defaults.set(osURL, forKey: "osURL")
                    }
                }
                
            }
            catch
            {
            }
        }
    }
    
   
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!)
    {
        if Constants.kPushEnabled && !stateChanges.from.subscribed && stateChanges.to.subscribed
        {
            print("Subscribed for OneSignal push notifications!")
        
            if(Constants.kPushReloadOnUserId)
            {
                loadWeb();
            }
        }
        
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
}
extension String {
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
extension WKWebView{
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
extension WebViewController
{
    @objc func checkForAlertDisplay()
    {
        let user = UserDefaults.standard
        srandom(UInt32(time(nil)))
        
        
        let randnum = arc4random() % 10
        
        if activateratemyappdialog == "true" {
        if !user.bool(forKey: "ratemyapp")
        {
            if randnum == 1
            {
                if #available( iOS 10.3,*){
                    SKStoreReviewController.requestReview()
                    user.set("1", forKey: "ratemyapp")
                    user.synchronize()
                }
            }
        }
        }
        if activatefacebookfriendsdialog == "true" {
        if !user.bool(forKey: "becomefbfriends")
        {
            if randnum == 2
            {
                user.set("1", forKey: "becomefbfriends")
                user.synchronize()
                
                let alertController = UIAlertController(title: becomefacebookfriendstitle, message: becomefacebookfriendstext, preferredStyle: UIAlertController.Style.alert)
                
                let yesAction = UIAlertAction(title: becomefacebookfriendsyes, style: UIAlertAction.Style.default, handler: {
                    alert -> Void in
                    
                    let prefeedback = becomefacebookfriendsurl
                    let feedback = URL(string: prefeedback)!
                    self.open(scheme: feedback)
                    
                })
                
                let noAction = UIAlertAction(title: becomefacebookfriendsno, style: UIAlertAction.Style.cancel, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        }
        
        if activatefirstrundialog == "true" {
        if !user.bool(forKey: "firstrun")
        {
            user.set("1", forKey: "firstrun")
            user.synchronize()
            
            let alertController = UIAlertController(title: firstrunmessagetitle, message: firstrunmessage, preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    }
    func setStatusBarColor(_ color: UIColor) -> Bool
    {
        let statusBar = UIApplication.shared.statusBarView
        let setForegroundColor_sel = NSSelectorFromString("setForegroundColor:")
        
        if statusBar!.responds(to: setForegroundColor_sel)
        {
            _ = statusBar?.perform(setForegroundColor_sel, with: color)
            return true
        }
        else
        {
            return false
        }
    }
    
    func downloadImageAndSave(toGallary imageURLString: String)
    {
        DispatchQueue.global().async {
            
            do
            {
                let data = try Data(contentsOf: URL(string: imageURLString)!)
                
                DispatchQueue.global().async {
                    DispatchQueue.global().async {
                        UIImageWriteToSavedPhotosAlbum(UIImage(data: data)!, nil, nil, nil)
                    }
                    
                    self.loadingSign.stopAnimating()
                    self.loadingSign.isHidden = true
                    
                    let alertController = UIAlertController(title: imagedownloadedtitle, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
            catch
            {
                DispatchQueue.global().async {
                    self.loadingSign.stopAnimating()
                    self.loadingSign.isHidden = true
                    
                    let alertController = UIAlertController(title: imagenotfound, message: nil, preferredStyle: UIAlertController.Style.alert)
                    
                    let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                        (action : UIAlertAction!) -> Void in
                        
                    })
                    
                    alertController.addAction(okAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        
        SVProgressHUD.show(withStatus: "Downloading...")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest.init(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                
                SVProgressHUD.dismiss()
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    let lastPath  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask
                        , true)[0]
                    guard let items = try? FileManager.default.contentsOfDirectory(atPath: lastPath) else { return }
                    
                    for item in items {
                        let completePath = lastPath.appending("/").appending(item)
                        try? FileManager.default.removeItem(atPath: completePath)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                    
                } catch (let writeError) {
                    print("Error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Error: %@", error?.localizedDescription ?? "");
            }
        }
        task.resume()
        
        
    }
    
    private func open(scheme: URL) {
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(scheme, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                      completionHandler: {
                                        (success) in
                                        print("Open \(scheme): \(success)")
            })
        } else {
            let success = UIApplication.shared.openURL(scheme)
            print("Open \(scheme): \(success)")
        }
    }
}

extension WebViewController: WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        if useloadingsign.isEqual("true")
        {
            loadingSign.startAnimating()
            loadingSign.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        loadingSign.stopAnimating()
        loadingSign.isHidden = true
        if disablecallout == "true" {
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        }
        isFirstTimeLoad = false
        if showFullScreenAd == "true"{
            localCount += 1
            
            if showadAfterX == localCount{
                 presentInterstitial()
                 localCount = 0
            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
    {
        if((error as NSError).code == NSURLErrorNotConnectedToInternet)
        {
            if(!isFirstTimeLoad)
            {
                let alertController = UIAlertController(title: offlinetitle, message: offlinemsg, preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: okbutton, style: UIAlertAction.Style.cancel, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            isFirstTimeLoad = false
            webView.isHidden = true
            loadingSign.isHidden = true
            offlineImageView.isHidden = false
            lblText1.isHidden = false
            lblText2.isHidden = false
            btnTry.isHidden = false
            if usemystatusbarbackgroundcolor.isEqual("true")
            {
                self.statusbarView.backgroundColor = .white
                view.backgroundColor = .white
            }
            
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        
        let response = navigationResponse.response as? HTTPURLResponse
        guard let responseURL = response?.url else {
            decisionHandler(.allow)
            return
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: response?.allHeaderFields as? [String : String] ?? [String : String](), for: responseURL)
        for cookie: HTTPCookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        
        let requestURL = navigationAction.request.url!
        
        if let urlScheme = requestURL.scheme {
            if urlScheme == "mailto" || urlScheme == "tel" || urlScheme == "maps"{
                if UIApplication.shared.canOpenURL(requestURL) {
                    self.open(scheme: requestURL)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        if requestURL.absoluteString.hasPrefix("savethisimage://?url=")
        {
            let imageURL = requestURL.absoluteString.substring(from: requestURL.absoluteString.index(requestURL.absoluteString.startIndex, offsetBy: "savethisimage://?url=".count))
            self.downloadImageAndSave(toGallary: imageURL)
            loadingSign.stopAnimating()
            self.loadingSign.isHidden = true
            
            decisionHandler(.cancel)
            return
        }
        
        if (requestURL.host != nil) && !(host == requestURL.host!) && (navigationAction.navigationType == .linkActivated) && openallexternalurlsinsafaribydefault.isEqual("true") && deeplinkingrequest == "false" {
            deeplinkingrequest == "false"
            self.open(scheme: requestURL)
            loadingSign.stopAnimating()
            self.loadingSign.isHidden = true
            
            decisionHandler(.cancel)
            return
        }
        
        func ShareBtnAction(_ sender: Any) {
            
            let textToShare = sharingText
            let message = sharingText
            if let link = NSURL(string: sharingURL)
            {
                let objectsToShare = [message,link] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
            }
            
        }
        
        if requestURL.absoluteString.hasPrefix("inapppurchase://"){
            showActions()
            
        }
        if requestURL.absoluteString.hasPrefix("shareapp://"){
            ShareBtnAction("1")
    
        }
        
        if requestURL.absoluteString.hasPrefix("reset_app://")
        {
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.removeAllCachedResponses()
            let config = WKWebViewConfiguration()
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
            
            let webView = WKWebView(frame: .zero, configuration: config)
            let alert = UIAlertController(title: "App reset was successful", message: "Thank you.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            webView.reload()
            decisionHandler(.cancel)
            return
            
        }
        
        if ((requestURL.host != nil) && requestURL.host! == "push.send.cancel")
        {
            UIApplication.shared.cancelAllLocalNotifications()
            
            decisionHandler(.cancel)
            return
        }
        
        if ((requestURL.host != nil) && requestURL.host! == "push.send")
        {
            let prerequest = requestURL
            let finished = prerequest.absoluteString
            var requested = finished.components(separatedBy: "=")
            let seconds = requested[1]
            var logindetails = finished.components(separatedBy: "msg!")
            let logindetected = logindetails[1]
            var logindetailsmore = logindetected.components(separatedBy: "&!#")
            let msg0 = logindetailsmore[0]
            let button0 = logindetailsmore[1]
            let msg = msg0.replacingOccurrences(of: "%20", with: " ")
            let button = button0.replacingOccurrences(of: "%20", with: " ")
            let sendafterseconds: Double = Double(seconds)!
            
            if #available(iOS 10.0, *)
            {
                let action = UNNotificationAction(identifier: "buttonAction", title: button, options: [])
                let category = UNNotificationCategory(identifier: "localNotificationTest", actions: [action], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                let notificationContent = UNMutableNotificationContent()
                notificationContent.body = msg
                notificationContent.sound = UNNotificationSound.default
                
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: sendafterseconds, repeats: false)
                
                let localNotificationRequest = UNNotificationRequest(identifier: "localNotificationTest", content: notificationContent, trigger: notificationTrigger)
                
                UNUserNotificationCenter.current().add(localNotificationRequest) {(error) in
                    if let error = error {
                        print("We had an error: \(error)")
                    }
                }
            }
            else
            {
                let pushmsg1 = UILocalNotification()
                pushmsg1.fireDate = Date().addingTimeInterval(sendafterseconds)
                pushmsg1.timeZone = NSTimeZone.default
                pushmsg1.alertBody = msg
                pushmsg1.soundName = UILocalNotificationDefaultSoundName
                pushmsg1.alertAction = button
                UIApplication.shared.scheduleLocalNotification(pushmsg1)
            }
            
            decisionHandler(.cancel)
            return
        }
        
        if uselocalhtmlfolder == "true" {
            if (requestURL.scheme! == "http") || (requestURL.scheme! == "https") || (requestURL.scheme! == "mailto") && (navigationAction.navigationType == .linkActivated)
            {
                if (openallexternalurlsinsafaribydefault == "true" && deeplinkingrequest == "false") {
                   deeplinkingrequest == "false"
                    self.open(scheme: requestURL)
                    
                    decisionHandler(.cancel)
                    return
                }
            }
            else
            {
                decisionHandler(.allow)
                return
            }
        }
        else {
        
            /* EXAMPLE: Open specific URL "http://m.facebook.com" links in Safari START */
            
            /* if ((requestURL.host != nil) && requestURL.host! == "m.facebook.com")
             {
             loadingSign.stopAnimating()
             self.loadingSign.isHidden = true
             UIApplication.shared.openURL(requestURL)
             decisionHandler(.cancel)
             return
             }
             */
            
            /* EXAMPLE: Open specific URL "http://m.facebook.com" links in Safari END */
            
            let internalFileExtension = (requestURL.absoluteString as NSString).lastPathComponent
            
            if internalFileExtension.hasSuffix(".pdf") || internalFileExtension.hasSuffix(".mp3") || internalFileExtension.hasSuffix(".mp4") || internalFileExtension.hasSuffix(".wav")
            {
                
                if internalFileExtension.contains(".pdf") || internalFileExtension.hasSuffix(".mp3") || internalFileExtension.hasSuffix(".mp4") || internalFileExtension.hasSuffix(".wav")
                {
                    var localURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask
                        , true)[0]
                    localURL = localURL + "/Download." + internalFileExtension
                    let strURL = (requestURL.absoluteString as NSString).addingPercentEscapes(using: String.Encoding.utf8.rawValue)
                    
                    DispatchQueue.main.async {
                        
                        guard let url = strURL?.makeURL() else{
                            return
                        }
                        
                        self.load(url: url, to: URL.init(fileURLWithPath: localURL), completion: {
                            
                            let objectsToShare =  NSURL.init(fileURLWithPath: localURL)
                            let activityVC = UIActivityViewController(activityItems: [objectsToShare], applicationActivities: nil)
                            
                            if UIDevice.current.userInterfaceIdiom == .pad
                            {
                                activityVC.popoverPresentationController?.sourceView = self.view
                                let popover = UIPopoverController(contentViewController: activityVC)
                                DispatchQueue.main.async {
                                    popover.present(from:  CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0), in: self.view, permittedArrowDirections: .any, animated: true)
                                }
                            }
                            else
                            {
                                DispatchQueue.main.async {
                                    self.present(activityVC, animated: true, completion: nil)
                                }
                            }
                            
                        })

                    }
                    
                }
                
                decisionHandler(.cancel)
            }
            else{
                decisionHandler(.allow)
            }
            
        }
    }
}

extension WebViewController{
    
    private func addWebViewToMainView(_ webView: WKWebView)
    {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        print(UIScreen.main.nativeBounds.height)
        switch UIScreen.main.nativeBounds.height {
    
        case 1624:
       
            view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 44))
            if showBannerAd == "true"{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -66))
            }else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))
                
            }
        case 2436,2688,1792:
            view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 44))
            if showBannerAd == "true"{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -66))
            }else{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))

            }
            
        default:
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                if bigiphonexstatusbar.isEqual("true")
                {
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30))
                }else{
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 22))
                }
            case .unspecified:
                break
            case .pad:
                if bigiphonexstatusbar.isEqual("true")
                {
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 30))
                }else{
                    view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
                }

            case .tv:
                break
            case .carPlay:
                break
            }
            
            
             if showBannerAd == "true"{
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: -44))

            }else
             {
                view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem:view, attribute: .bottom, multiplier: 1, constant: 0))

            }

        }
        
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: view , attribute: .right, multiplier: 1, constant:0))
        view.layoutIfNeeded()
        self.view.bringSubviewToFront(bannerView)
    }
}

extension WebViewController: WKUIDelegate{
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            completionHandler()
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completionHandler(false)
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: Constants.kAppDisplayName, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
            textField.placeholder = "Enter here..."
        }
        
        alertController.addAction(UIAlertAction(title: okbutton, style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        }))
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
