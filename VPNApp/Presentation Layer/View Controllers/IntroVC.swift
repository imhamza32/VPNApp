//
//  IntroVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 26/06/2023.
//

import UIKit

class IntroVC: UIViewController {
    @IBOutlet weak var getPremiumVu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPremiumVu.addTap {
            self.pushVC(id: BuyPremiumVC.id)
        }
    }
    

    @IBAction func takeTour(_ sender: Any) {
        pushVC(id: HomeVC.id)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
