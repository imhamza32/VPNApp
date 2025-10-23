//
//  BuyPremiumVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 13/04/2023.
//

import UIKit

class BuyPremiumVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    var planDetails : [(planType : String, price : String, selected : Bool, locationIndex : IAPProduct)] = [("Monthly", "12.99$/month", true, .monthlySub), ("Yearly", "79.99$/year", false, .yearlySub)]
    let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UINib(nibName: PremiumCell.id, bundle: nil), forCellReuseIdentifier: PremiumCell.id)
        tblView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .large
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.fixInView(self.view)

    }
    
    @IBAction func purchasePressed(_ sender: Any) {
        guard let plan = planDetails.first(where: {$0.selected}) else {
            showAlert(message: "Select any plan first.")
            return
        }
        activityIndicatorView.startAnimating()
        IAPService.instance.attemptPurchaseForItemWith(productIndex: plan.locationIndex, delegate: self)
    }
  
    @IBAction func restorePurchases(_ sender: Any) {
        IAPService.instance.restorePurchases(delegate: self)
        activityIndicatorView.startAnimating()
    }
    
    @IBAction func goBack(_ sender: Any) {
        popController()
    }
    
}

extension BuyPremiumVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return planDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PremiumCell.id, for: indexPath) as! PremiumCell
        cell.timeLbl.text = planDetails[indexPath.row].planType
        cell.priceLbl.text = planDetails[indexPath.row].price
        cell.checkImgVu.image = planDetails[indexPath.row].selected ? UIImage(named: "check") : UIImage(named: "uncheck")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        planDetails[indexPath.row].selected = true
        if let cell = tableView.cellForRow(at: indexPath) as? PremiumCell {
            cell.checkImgVu.image = planDetails[indexPath.row].selected ? UIImage(named: "check") : UIImage(named: "uncheck")
            }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        planDetails[indexPath.row].selected = false
        if let cell = tableView.cellForRow(at: indexPath) as? PremiumCell {
            cell.checkImgVu.image = planDetails[indexPath.row].selected ? UIImage(named: "check") : UIImage(named: "uncheck")
            }
        
    }
}

extension BuyPremiumVC : IAPServiceDelegate {
    func purchaseCompleted(status: Bool, params: [String : Any]) {
        print("Purchase Status", status)
        activityIndicatorView.stopAnimating()
        if status {
            print("Subscription completed")
            showAlert(title: AC.Success, message: "Your purchase was successfull. Enjoy the premium") {
                self.delay(1.0) { // To switch root and dismiss alert
                    let homeNav = self.getRef(identifier: "HomeNC")
                    self.view.window?.switchRootViewController(to: homeNav)
                }
                
            }
        } else {
            showAlert(title: AC.Error, message: "Could not complete the payment. Please try again")
        }
    }
    
    func iapProductsLoaded() {
        print("Products loaded")
    }
    
    
}
