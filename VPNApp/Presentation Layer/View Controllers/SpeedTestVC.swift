//
//  SpeedTestVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 04/08/2023.
//

import UIKit

class SpeedTestVC: BaseClass {

    @IBOutlet weak var speedLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        InternetSpeedChecker().testInternetSpeed { [weak self] speed in
            guard let self else {return}
            DispatchQueue.main.async {
                self.speedLbl.text = speed ?? "No Internet"
            }
            
        }
        
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
