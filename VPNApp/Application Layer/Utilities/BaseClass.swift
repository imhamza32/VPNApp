//
//  BaseClass.swift
//  BaseClass
//
//  Created by Munib Hamza on 16/08/2021.
//

import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class BaseClass: UIViewController, UINavigationControllerDelegate {
        
    private var interstitial: GADInterstitialAd?
    var adDismissed : (() -> ())? = nil

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "AccentColor")
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAds()
    }
    
    func setupAds() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: instertialId,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            
        })
    }
    
    // MARK: show ad
    func showAd() -> Bool  {
        if interstitial != nil {
            interstitial!.present(fromRootViewController: self)
            return true
        } else {
            print("Ad wasn't ready")
            return false
        }
    }
    func addRefreshControl(to tableView: UITableView) {
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        print("Override this method to add custom functionality")
    }
}

extension UIViewController {
    
    // MARK: - ALERTS
    func presentPopover(_ parentViewController: UIViewController, _ viewController: UIViewController, sender: UIView, size: CGSize) {
        viewController.preferredContentSize = size
        viewController.modalPresentationStyle = .popover
        if let pres = viewController.presentationController {
            pres.delegate = parentViewController
        }
        parentViewController.present(viewController, animated: true)
        if let pop = viewController.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }
    }
    
    func showAlert(title: String = AC.Alert, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, onSuccess closure: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .`default`, handler: { _ in
            closure()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTwoBtnAlert (title: String, message: String,yesBtn:String,noBtn:String, onSuccess success: @escaping (Bool) -> Void) {
        
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: yesBtn, style: .default, handler: { (action) -> Void in
            
            print("Yes button click...")
            success(true)
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: noBtn, style: .cancel) { (action) -> Void in
            print("Cancel button click...")
            success(false)
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension BaseClass:  GADFullScreenContentDelegate {
    
    // MARK: Function For Google
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        adDismissed?()
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        setupAds()
        adDismissed?()
    }
    
}
