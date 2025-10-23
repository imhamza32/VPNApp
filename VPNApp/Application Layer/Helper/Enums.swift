//
//  Enums.swift
//  SoldLive BroadCaster
//
//  Created by Mubeen Asif on 06/05/2022.
//

import Foundation

struct enums{
    
    enum ServerMessages: String{
        case unauthorized   =   "Unauthorized, Might be missing token in the Request or session has been expired"
        case interestAdded = "Interest Linked Successfully"
        case interestRemoved = "Interest removed successfully"
        case parametersMissing  =   "Parameter are missing or not suitable"
    }
    
    enum DropAlerts: String {
        case internetConnection = "No internet connection."
    }
    
}

enum CustomError: Error {
    // Throw when an invalid password is entered
    case invalidURL
    case tokenExpired
    // Throw in all other cases
    case unexpected(code: Int)
}

// For each error type return the appropriate localized description
extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "The provided URL is not valid.",
                comment: "Invalid URL"
            )
        case .tokenExpired:
            return NSLocalizedString(
                "Session timeout. Please login again.",
                comment: "Session timeout"
            )
        case .unexpected(_):
            return NSLocalizedString(
                "An unexpected error occurred.",
                comment: "Unexpected Error"
            )
        }
    }
}


enum MembershipType: String {
    case monthly    =   "Monthly for $12.99"
    case yearly     =   "Yearly for $79.99"
}

enum IAPProduct: Int {
    case monthlySub = 0
    case yearlySub = 1
}

enum PurchaseStatus {
    case purchased
    case subscribed
    case restored
    case failed
}

enum PackagesIdentifiers: String {
    case monthly = "com.fastvpn.monthly"
    case yearly     = "com.fastvpn.yearly"
}
