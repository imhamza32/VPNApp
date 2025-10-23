//
//  AboutUs.swift
//  VPNApp
//
//  Created by Munib Hamza on 13/04/2023.
//

import UIKit
import MessageUI

class AboutUs: UIViewController {
    
    @IBOutlet weak var remainingCoins: UILabel!
    @IBOutlet weak var getPremiumPressed: UIView!
    @IBOutlet weak var premiumLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPremiumPressed.addTap { [weak self] in
            if IAPService.instance.isSubscriptionActive() {
                self?.showAlert(message: "You are already subscribed to premium. You can check details under subscriptions section in settings. ")
            } else {
                self?.pushVC(id: BuyPremiumVC.id)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        remainingCoins.text = "\(DataManager.shared.totalRemainingCoins)"
        if IAPService.instance.isSubscriptionActive() {
            premiumLbl.text = "Subscribed to premium"
        } else {
            premiumLbl.text = "Get Premium"
        }
    }
    
    @IBAction func exchangeCoinsPressed(_ sender: Any) {
        showTwoBtnAlert(title: AC.Alert, message: "Are you sure to exchange current points with free VPN sessions?", yesBtn: "Confirm", noBtn: "Cancel") { yes in
            if yes {
                let message = DataManager.shared.exchangeCoins()
                self.remainingCoins.text = "\(DataManager.shared.totalRemainingCoins)"
                self.delay(1.0) {
                    self.showAlert(message: message)
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        popController()
    }
    
    @IBAction func termsTapped(_ sender: Any) {
        let vc = getRef(identifier: WebViewController.id) as! WebViewController
        vc.urlToLoad = .terms
        push(vc: vc)
    }
    
    @IBAction func privacyTapped(_ sender: Any) {
        let vc = getRef(identifier: WebViewController.id) as! WebViewController
        vc.urlToLoad = .privacy
        push(vc: vc)
    }
    
    @IBAction func contactTapped(_ sender: Any) {
        sendEmail()
    }
}
extension AboutUs : MFMailComposeViewControllerDelegate {
    
    func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            
            mail.title = "Support - VPN Fast Unlimited Proxy"
            mail.setToRecipients(["support@vpnproxy.com"])
            
            mail.setSubject("Support")
            mail.setMessageBody("\n\n\nPlease send us your issue in a detail, we're happy to learn from you :)", isHTML: false)
            self.present(mail, animated: true, completion: nil)
            
        } else {
            // show failure alert
            showMailServiceErrorAlert()
            return
        }
    }
    
    func showMailServiceErrorAlert(){
        self.showAlert(title: "Error", message: "Mail services are not available")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}
