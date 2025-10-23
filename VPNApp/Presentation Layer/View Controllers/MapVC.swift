//
//  MapVC.swift
//  VPNApp
//
//  Created by Munib Hamza on 03/08/2023.
//

import UIKit
import MapKit

class MapVC: BaseClass {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        addMarkers()
    }
    
    func addMarkers() {
        for i in 0..<allServersList.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate = allServersList[i].coordinates
            annotation.title = allServersList[i].countryName
            mapView.addAnnotation(annotation)
            
            if allServersList[i].isSelected {
                allServersList[i].isSelected = true
                mapView.selectAnnotation(annotation, animated: true)
                let initialRegion = MKCoordinateRegion(center: allServersList[i].coordinates, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
                mapView.setRegion(initialRegion, animated: true)
            }
        }
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let name = annotation.title {
            for i in 0..<allServersList.count {
                allServersList[i].isSelected = false
            }
            let index = allServersList.firstIndex(where: {$0.countryName == name ?? ""})
            allServersList[index!].isSelected = true
        }
        print("Annotation selected")
    
    }
}
