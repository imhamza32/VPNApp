//
//  ServersListVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 12/04/2023.
//

import UIKit
import MapKit

class ServersListVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UINib(nibName: CountryCell.id, bundle: nil), forCellReuseIdentifier: CountryCell.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        allServersList.shuffle()
        var globeServer : (serverId: String, countryName: String, isSelected: Bool, coordinates : CLLocationCoordinate2D)? = nil
        for (i,server) in allServersList.enumerated() {
            if server.serverId == "" {
                globeServer = server
                allServersList.remove(at: i)
                break
            }
        }
        guard let globeServer else {return}
        allServersList.insert(globeServer, at: 0)
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        popController()
    }
}
extension ServersListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allServersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.id, for: indexPath) as! CountryCell
        cell.nameLbl.text = allServersList[indexPath.row].countryName.capitalized
        cell.imgVu.image = UIImage(named: "\(allServersList[indexPath.row].countryName.lowercased())")
        if allServersList[indexPath.row].isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        for i in 0..<allServersList.count {
            allServersList[i].isSelected = false
        }
        allServersList[indexPath.row].isSelected = true
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        allServersList[indexPath.row].isSelected = false
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
}
