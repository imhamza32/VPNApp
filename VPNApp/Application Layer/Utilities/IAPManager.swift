//
//  IAPManager.swift
//  PumpkinPal
//
//  Created by Munib Hamza on 28/05/2023.
//

import Foundation
import StoreKit

protocol IAPServiceDelegate {
    func iapProductsLoaded()
    func purchaseCompleted(status : Bool, params : [String : Any])
}

class IAPService: SKReceiptRefreshRequest, SKProductsRequestDelegate {
    
    static let instance = IAPService()
    
    var iapDelegate: IAPServiceDelegate?
    var fetchCount = 0
    var products = [SKProduct]()
    var productIds = Set<String>()
    var productRequest = SKProductsRequest()
    
    var verifyReceiptApiResponse = 0
    
    var expirationDate: Date?
    
    var nonConsumablePurchaseWasMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")
    var params = [String:Any]()
    
    public func loadProducts() {
        productIdToStringSet()
        requestProducts(forIds: productIds)
    }
    
    private func productIdToStringSet() {
        let ids = [PackagesIdentifiers.monthly.rawValue, PackagesIdentifiers.yearly.rawValue]
        for id in ids {
            productIds.insert(id)
        }
    }
    
    private func requestProducts(forIds ids: Set<String>) {
        productRequest.cancel()
        productRequest = SKProductsRequest(productIdentifiers: ids)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        
        if products.count == 0 && fetchCount < 5 {
            fetchCount = fetchCount + 1
            requestProducts(forIds: productIds)
        } else {
            iapDelegate?.iapProductsLoaded()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
        sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
    }
    
    public func attemptPurchaseForItemWith(productIndex: IAPProduct, delegate : IAPServiceDelegate) {
        self.iapDelegate = delegate
        guard products.count > 0 else {
            iapDelegate?.purchaseCompleted(status: false, params: [:])
            return
        }
        let product = products[productIndex.rawValue]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restorePurchases(delegate : IAPServiceDelegate) {
        self.iapDelegate = delegate
        print("Restore purchases")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: – SKReceiptRefreshRequest Delegate Method
    func requestDidFinish(_ request: SKRequest) {
        debugPrint("requestDidFinish")
        uploadReceipt { response, valid in
            debugPrint("Subscription Receipt Valid")
            if self.isSubscriptionActive() {
                self.setNonConsumablePurchase(true, forTransaction: nil)
            } else {
                debugPrint("Subscription Expired")
                self.setNonConsumablePurchase(false, forTransaction: nil)
            }
            return
        } failure: { valid in
            self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: false)
        }
        
    }
    
    public func isSubscriptionActive() -> Bool {
        reloadExpiryDate()
        let now = Date()
        guard let expirationDate = expirationDate else { return false }
        debugPrint("TIME REMAINING: \(expirationDate.timeIntervalSinceNow / 60) minutes.")
        debugPrint("EXPIRATION DATE: \(expirationDate)")
        if now.isLessThan(expirationDate) {
            return true
        } else {
            return false
        }
    }
    
    private func uploadReceipt(success: @escaping (_ response: Dictionary<String, Any>, Bool) -> Void,
                               failure: @escaping (Bool) -> Void) {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() else {
            debugPrint("No receipt url")
            failure(false)
            return
        }
        print("Uploading Recepiet")
        let body = [
            "receipt-data": receipt,
            "password": Constants.appSecret
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let devurl = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        let liveurl = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: liveurl)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            print("Uploading Recepiet Complete")
            if let error = error {
                debugPrint(error)
                failure(false)
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                print(json)
                
                if let status = json["status"] as? Int{
                    self.verifyReceiptApiResponse = status
                }
                
                if self.verifyReceiptApiResponse == 21007 || self.verifyReceiptApiResponse == 21002 {
                    var request = URLRequest(url: devurl)
                    request.httpMethod = "POST"
                    request.httpBody = bodyData
                    
                    let devtask = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
                        if let error = error {
                            debugPrint(error)
                            failure(false)
                        } else if let responseData = responseData {
                            do {
                                let newJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                                let newExpirationDate = self.expirationDateFromResponse(jsonResponse: newJSON)
                                self.setExpiration(forDate: newExpirationDate ?? Date())
                                debugPrint("NEW EXPIRATION DATE: ", newExpirationDate ?? Date())
                                self.verifyReceiptApiResponse = 0
                                success(json, true)
                            } catch (let error) {
                                print(error.localizedDescription)
                                failure(false)
                            }
                        }
                    }
                    devtask.resume()
                    
                }  else if self.verifyReceiptApiResponse == 0 {
                    let newExpirationDate = self.expirationDateFromResponse(jsonResponse: json)
                    self.setExpiration(forDate: newExpirationDate ?? Date())
                    self.expirationDate = newExpirationDate
                    debugPrint("NEW EXPIRATION DATE: ", newExpirationDate ?? Date())
                    success(json, true)
                } else{
                    self.verifyReceiptApiResponse = 0
                    failure(false)
                }
            }
        }
        task.resume()
    }
    
    private func expirationDateFromResponse(jsonResponse: Dictionary<String, Any>) -> Date? {
        if let receiptInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.firstObject as! Dictionary<String, Any>
            debugPrint("Transection id", lastReceipt["transaction_id"] as! String)
            debugPrint("Is Trail period", lastReceipt["is_trial_period"] as! String)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            
            let expirationDate: Date = formatter.date(from: lastReceipt["expires_date_pst"] as! String) ?? Date()
            return expirationDate
        } else {
            return nil
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    BaseClass().showAlert(title: AC.Success, message: "Purchases Restored")
                }
                
            case .failed:
                sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
                break
            case .purchasing:
                debugPrint("Purchasing...")
                break
            @unknown default:
                sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: nil)
                break
            }
        }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //        sendNotificationFor(status: .restored, withIdentifier: nil, orBoolean: nil)
        //        setNonConsumablePurchase(true, forTransaction: nil)
        debugPrint("paymentQueueRestoreCompletedTransactionsFinished")
        uploadReceipt { response, valid in
            debugPrint("Subscription Receipt Valid")
            if self.isSubscriptionActive() {
                
                let receiptInfo: NSArray = response["latest_receipt_info"] as? NSArray ?? NSArray()
                let lastReceipt = receiptInfo.firstObject as! Dictionary<String, Any>
                var dict = ["transaction_id": lastReceipt["transaction_id"] as! String,
                            "is_expired" : "false",
                            "is_trial_period" : Bool(lastReceipt["is_trial_period"] as! String) ?? Bool()] as [String : Any]
                if lastReceipt["product_id"] as! String == PackagesIdentifiers.monthly.rawValue{
                    dict["membership_type"] = PackagesIdentifiers.monthly.rawValue
                }else if lastReceipt["product_id"] as! String == PackagesIdentifiers.yearly.rawValue{
                    dict["membership_type"] = PackagesIdentifiers.yearly.rawValue
                }
                dict["membership_expiry_date"] = "\(self.expirationDate ?? Date())"
                //                    self.authModel.verifyAppleSubscription(params: dict) { (successMessage) in
                self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: true)
                self.setNonConsumablePurchase(true, forTransaction: nil)
                //                    } onFailure: { (errorMessage) in
                //                        DispatchQueue.main.async {
                
                //                        }
                //                    }
            } else {
                debugPrint("Subscription Expired")
                _ = ["is_expired": "true",
                            "membership_type" : "",
                            "transaction_id": "",
                            "membership_expiry_date" : "\(self.expirationDate ?? Date())",
                            "is_trial_period" : false] as [String : Any]
                //                    self.authModel.verifyAppleSubscription(params: dict) { (successMessage) in
                self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: false)
                self.setNonConsumablePurchase(false, forTransaction: nil)
                //                    } onFailure: { (errorMessage) in
                //                    }
            }
            
            return
        } failure: { valid in
            
            self.sendNotificationFor(status: .subscribed, withIdentifier: nil, orBoolean: false)
            self.setNonConsumablePurchase(false, forTransaction: nil)
            
            return
        }
        
    }
    
    func complete(transaction: SKPaymentTransaction) {
        debugPrint("Purchase was successful!")
        uploadReceipt { response, valid in
            debugPrint("Subscription Receipt Valid")
            if self.isSubscriptionActive() {
//                let receiptInfo: NSArray = response["latest_receipt_info"] as? NSArray ?? NSArray()
//                let lastReceipt = receiptInfo.firstObject as! Dictionary<String, Any>
                var dict : [String:Any] = ["subscription_id": "1234567r"
//                                            lastReceipt["original_transaction_id"] as? String ?? ""
                ]
                
//                if lastReceipt["product_id"] as? String == PackagesIdentifiers.monthly.rawValue{
                    dict["subscription_type"] = "monthly"
//                }else if lastReceipt["product_id"] as? String == PackagesIdentifiers.yearly.rawValue{
//                    dict["subscription_type"] = "yearly"
//                }
                self.params = dict
                switch transaction.payment.productIdentifier {
                case PackagesIdentifiers.monthly.rawValue:
                    self.sendNotificationFor(status: .subscribed, withIdentifier: PackagesIdentifiers.monthly.rawValue, orBoolean: true)
                    self.setNonConsumablePurchase(true, forTransaction: transaction)
                    break
                case PackagesIdentifiers.yearly.rawValue:
                    self.sendNotificationFor(status: .subscribed, withIdentifier: PackagesIdentifiers.yearly.rawValue, orBoolean: true)
                    self.setNonConsumablePurchase(true, forTransaction: transaction)
                    break
                default:
                    break
                }
            } else {
                self.sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: false)
                self.setNonConsumablePurchase(false, forTransaction: nil)
            }
            return
        } failure: { valid in
            self.sendNotificationFor(status: .failed, withIdentifier: nil, orBoolean: false)
            self.setNonConsumablePurchase(false, forTransaction: nil)
        }
    }
    
    func setNonConsumablePurchase(_ status: Bool, forTransaction transaction: SKPaymentTransaction?) {
        UserDefaults.standard.set(status, forKey: "nonConsumablePurchaseWasMade")
    }
    
    func setExpiration(forDate date: Date) {
        UserDefaults.standard.set(date, forKey: "expirationDate")
    }
    
    func reloadExpiryDate() {
        expirationDate = UserDefaults.standard.value(forKey: "expirationDate") as? Date
    }
    
    func sendNotificationFor(status: PurchaseStatus, withIdentifier identifier: String?, orBoolean bool: Bool?) {
        DispatchQueue.main.async { [self] in
            switch status {
            case .purchased:
                iapDelegate?.purchaseCompleted(status: bool ?? true, params: params)
                break
            case .subscribed:
                iapDelegate?.purchaseCompleted(status: bool ?? true, params: params)
                break
            case .restored:
                iapDelegate?.purchaseCompleted(status: bool ?? true, params: params)
                break
            case .failed:
                iapDelegate?.purchaseCompleted(status: bool ?? false, params: [:])
                break
            }
        }
    }
    
}

extension Date {
    public func isLessThan(_ subscriptionDate: Date) -> Bool {
        if self.timeIntervalSince(subscriptionDate) < subscriptionDate.timeIntervalSinceNow {
            return true
        } else {
            return false
        }
    }
}
