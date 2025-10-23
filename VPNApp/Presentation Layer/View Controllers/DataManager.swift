//
//  DataManager.swift
//  VPNApp
//
//  Created by Munib Hamza on 21/07/2023.
//

import Foundation
class DataManager {
    
    static let shared = DataManager()
  
    private init() {}
    
    private let def = UserDefaults.standard
    
    var isOpeningDateSet : Bool {
        get {
            return def.bool(forKey: "isOpeningDateSet")
        } set {
            def.set(newValue, forKey: "isOpeningDateSet")
            if newValue {
                setFirstOpeningDate()
            }
        }
    }
    
    func oneMonthCompleted() -> Bool {
        let today = Date()
        return today.days(from: firstOpeningDate) > 30
    }
    
    var firstOpeningDate : Date {
        get {
            return def.value(forKey: "firstOpeningDate") as? Date ?? Date()
        }
    }
    
    private func setFirstOpeningDate() {
        def.set(Date(), forKey: "firstOpeningDate")
        
    }
    
    func startGeneratingCoins() {
        def.set(Date(), forKey: "startingTime")
    }
    
    func stopGeneratingCoins() -> String {
        var coinsGot = 0
        
        if let startTime = def.value(forKey: "startingTime") as? Date {
            let usedMinutes = Date().minutes(from: startTime)
            coinsGot = usedMinutes
            totalRemainingCoins = totalRemainingCoins + coinsGot
            def.set(nil, forKey: "startingTime")
        }
        
        if coinsGot == 0 {
            return "You have not got any coin from this session. Have long sessions to generate coins."
        } else {
            return "You have got \(coinsGot) coins from this session. Exchange coins for free VPN sessions."
        }
    }
    
    func exchangeCoins() -> String {
        var message = ""
        var winTime = 0
        let usedMinutes = totalRemainingCoins
        var remainingCoins = usedMinutes
        let hoursUsed = usedMinutes / 60
        for _ in 0..<hoursUsed {
            winTime = winTime + 10 // 10 minutes for each 60 coins
            remainingCoins = remainingCoins - 60
        }
        let remainingMin = usedMinutes % 60
        if remainingMin > 30 {
            winTime = winTime + 5 // 5 minutes for each 30 coins
            remainingCoins = remainingCoins - 30
        }
        totalRemainingCoins = remainingCoins

        if winTime > 0 {
            totalRemainingFreeTime = totalRemainingFreeTime + winTime
            if winTime < 60 {
                message =  "You have won \(winTime) minutes(s) free VPN session."
            } else {
                let hours =  winTime / 60
                let mins = winTime % 60
                if mins > 0 {
                    message = "You have won \(hours) hour(s) and \(mins) minute(s) free VPN session."
                } else {
                    message = "You have won \(hours) hour(s) free VPN session."
                }
            }
        } else {
            message = "Sorry! You are running short on coins. Have long sessions to generate more coins."
        }
        
        return message
    }
    
    var totalRemainingCoins : Int {
        get {
            return (def.value(forKey: "remainingFreeCoins") ?? 0) as! Int
        } set {
            def.set(newValue, forKey: "remainingFreeCoins")
        }
    }
    
    var totalRemainingFreeTime : Int {
        get {
            return (def.value(forKey: "totalRemainingFreeTime") ?? 0) as! Int
        } set {
            def.set(newValue, forKey: "totalRemainingFreeTime")
        }
    }
}
