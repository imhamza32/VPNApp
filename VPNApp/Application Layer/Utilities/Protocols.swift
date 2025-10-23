//
//  Protocols.swift
//  QCard
//
//  Created by Munib Hamza on 27/08/2021.
//

import Foundation

protocol TextBackProtocol {
    func textReceived(text: String)
}
protocol LinkAdded {
    func linkReceived(text: String, platform: String)
}
protocol LinkDeleted {
    func deleteLink(platform: String)
}
protocol getDate {
    func getSelectedDate(_ date: String)
}
