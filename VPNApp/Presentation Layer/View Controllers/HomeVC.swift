//
//  HomeVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 12/04/2023.
//

import UIKit
import Lottie
import NetworkExtension
import GoogleMobileAds

class HomeVC: BaseClass {
    
    @IBOutlet weak var powerBtn: UIButton!
    @IBOutlet weak var adVu: GADBannerView!
    @IBOutlet weak var serverBtn: UIButton!
    @IBOutlet weak var globeImgView: UIImageView!
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var animatedView: UIView!

    private var animationView: LottieAnimationView?
    var popRecognizer: InteractivePopRecognizer?
    var providerManager: NETunnelProviderManager!
    let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    var timer = Timer()
    var isSubscribed = false
    
    var selectedServer = allServersList.first
    
    @IBOutlet weak var powerImgVu: UIImageView!
    
    var powerOnImg = UIImage(named: "powerOn")
    var powerOffImg = UIImage(named: "powerOff")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .large
        self.view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkOnAppear()
//        isSubscribed =  IAPService.instance.isSubscriptionActive()

        selectedServer = allServersList.first(where: {$0.isSelected})
        globeImgView.image = UIImage(named: selectedServer!.countryName.lowercased())
        serverBtn.setTitle(selectedServer?.countryName, for: .normal)
        if selectedServer?.serverId == "" {
            let automatic = selectedServer!
            allServersList.removeFirst()
            selectedServer = allServersList.randomElement()
            allServersList.insert(automatic, at: 0)
        }

        adVu.isHidden = isSubscribed
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isSubscribed {
            let _ = self.showAd()
        }
    }
    @IBAction func premiumPressed(_ sender: Any) {
        self.pushVC(id: BuyPremiumVC.id)
    }
    
    @IBAction func speedPressed(_ sender: UIButton) {
        let vc = getRef(identifier: SpeedTestVC.id)
        presentPopover(self, vc, sender: sender, size: CGSize(width: 150, height: 100))
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        showShareActivity(url: "https://apps.apple.com/us/app/vpn-fast-unlimited-proxy/id6450241553") {}
    }
    
    @IBAction func mapPressed(_ sender: Any) {
        self.pushVC(id: MapVC.id)

    }
    @IBAction func powerBtnPressed(_ sender: Any) {
        if Constants.sharedDefault.bool(forKey: Constants.vpnStatusKey) {
            showTwoBtnAlert(title: AC.Alert, message: "Are you sure you want to disconnect to VPN.", yesBtn: "Yes", noBtn: "Cancel") { yes in
                if yes {
                    self.providerManager?.connection.stopVPNTunnel()
                    self.connectBtn.setTitle("Connect", for: .normal)
                    Constants.sharedDefault.set(false, forKey: Constants.vpnStatusKey)
                    let message = DataManager.shared.stopGeneratingCoins()

                    self.delay(1.0) {
                        self.showAlert(message: message)
                    }
                }
            }
        } else {
            
            if IAPService.instance.isSubscriptionActive() {
//                || !DataManager.shared.oneMonthCompleted() || DataManager.shared.totalRemainingFreeTime > 0 {
                
                if selectedServer != nil {} else {
                    selectedServer = allServersList.last
                }
                guard let selectedServer else {return}
                self.loadProviderManager {
                    self.activityIndicatorView.startAnimating()
                    print(selectedServer)
                    self.configureVPN(serverAddress: String(selectedServer.serverId.dropLast(4)), username: "zfzA9pY-VwKJh6Vw_RWIfZW1", password: "OSxVuIfTYWBKPIX1afZCUaph")
                }
                
            } else {
                self.showAlert(title: AC.Alert, message: "You need to buy premium to use the app.") {
                    self.pushVC(id: BuyPremiumVC.id)
                }
            }
        }
    }
    
    func checkOnAppear() {
        print("checking status")
        let connected = Constants.sharedDefault.bool(forKey: Constants.vpnStatusKey)
        
        if connected {
            powerImgVu.image = powerOffImg
            self.connectBtn.setTitle("Connected", for: .normal)
            self.activityIndicatorView.stopAnimating()
            timer.invalidate()
            print("VPN is connected!")
        } else {
            powerImgVu.image = powerOnImg
            self.connectBtn.setTitle("Connect", for: .normal)
        }
    }
    
    func setupUI() {
        
        adVu.adUnitID = bannerId
        adVu.rootViewController = self
        adVu.load(GADRequest())

        animationView = .init(name: "globe 1")
        animationView!.frame = animatedView.bounds
        animationView!.contentMode = .scaleAspectFit
        animationView!.loopMode = .loop
        animationView!.animationSpeed = 2.0
        animationView!.play()
        animationView?.fixInView(animatedView)
        setInteractiveRecognizer()
        activityIndicatorView.fixInView(self.view)
    }
    
    func startTimer(){
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    // called every time interval from the timer
    @objc func timerAction() {
        print("Connecting!")
        let connected = Constants.sharedDefault.bool(forKey: Constants.vpnStatusKey)
        
        if connected {
            self.connectBtn.setTitle("Connected", for: .normal)
            self.activityIndicatorView.stopAnimating()
            timer.invalidate()
            showAlert(title: AC.Success, message: "VPN is now connected. Surf safely!")
            print("VPN is now connected!")
            DataManager.shared.startGeneratingCoins()

        } else {
            self.connectBtn.setTitle("Connect", for: .normal)
        }
    }
    
    
    func loadProviderManager(completion:@escaping () -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if error == nil {
                self.providerManager = managers?.first ?? NETunnelProviderManager()
                completion()
            }
        }
    }
    
    
    func configureVPN(serverAddress: String, username: String, password: String) {
        guard let configData = self.readFile() else { return }
        self.providerManager?.loadFromPreferences { error in
            if error == nil {
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.username = username
                tunnelProtocol.serverAddress = serverAddress
                tunnelProtocol.providerBundleIdentifier = "app.vpnfast.com.VPNTunnel" // bundle id of the network extension target
                tunnelProtocol.providerConfiguration = ["ovpn": configData, "username": username, "password": password]
                tunnelProtocol.disconnectOnSleep = false
                self.providerManager.protocolConfiguration = tunnelProtocol
                self.providerManager.localizedDescription = "Fast VPN" // the title of the VPN profile which will appear on Settings
                self.providerManager.isEnabled = true
                self.providerManager.saveToPreferences(completionHandler: { (error) in
                    if error == nil  {
                        self.providerManager.loadFromPreferences(completionHandler: { (error) in
                            do {
                                try self.providerManager.connection.startVPNTunnel() // starts the VPN tunnel.
                                self.startTimer()

                            } catch let error {
                                print(error.localizedDescription)
                            }
                        })
                    } else {
                        print("Error occuredd",error as Any)
                    }
                })
            } else {
                print("Error occuredd again",error as Any)
            }
        }
    }
    
    func readFile() -> Data? {
        do {
            if let path = Bundle.main.path(forResource: selectedServer?.serverId, ofType: "ovpn") {
                
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .uncached)
            } else {
                print("Could not read file")
                showAlert(message: "Could not read file")
                activityIndicatorView.stopAnimating()
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    @IBAction func selectServerPressed(_ sender: Any) {
        if Constants.sharedDefault.bool(forKey: Constants.vpnStatusKey) {
            showAlert(message: "VPN is already connected.")
            return
        }
        pushVC(id: ServersListVC.id)
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        pushVC(id: AboutUs.id)
    }
    
    @IBAction func scanQrPressed(_ sender: Any) {
        pushVC(id: QRScannerController.id)
    }
    
    @IBAction func connectBtnPressed(_ sender: Any) {
        if Constants.sharedDefault.bool(forKey: Constants.vpnStatusKey) {
            showTwoBtnAlert(title: AC.Alert, message: "Are you sure you want to disconnect to VPN.", yesBtn: "Yes", noBtn: "Cancel") { yes in
                if yes {
                    self.providerManager?.connection.stopVPNTunnel()
                    self.connectBtn.setTitle("Connect", for: .normal)
                    Constants.sharedDefault.set(false, forKey: Constants.vpnStatusKey)
                    let message = DataManager.shared.stopGeneratingCoins()

                    self.delay(1.0) {
                        self.showAlert(message: message)
                    }
                }
            }
        } else {
            
            if IAPService.instance.isSubscriptionActive() {
//                || !DataManager.shared.oneMonthCompleted() || DataManager.shared.totalRemainingFreeTime > 0 {
                
                if selectedServer != nil {} else {
                    selectedServer = allServersList.last
                }
                guard let selectedServer else {return}
                self.loadProviderManager {
                    self.activityIndicatorView.startAnimating()
                    print(selectedServer)
                    self.configureVPN(serverAddress: String(selectedServer.serverId.dropLast(4)), username: "zfzA9pY-VwKJh6Vw_RWIfZW1", password: "OSxVuIfTYWBKPIX1afZCUaph")
                }
                
            } else {
                self.showAlert(title: AC.Alert, message: "You need to buy premium to use the app.") {
                    self.pushVC(id: BuyPremiumVC.id)
                }
            }
        }
    }
    
}

