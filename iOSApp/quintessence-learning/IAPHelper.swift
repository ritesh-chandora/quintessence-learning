//
//  IAPHelper.swift
//  quintessence-learning
//
//  Created by Eric Feng on 8/9/17.
//  Copyright © 2017 Eric Feng. All rights reserved.
//

import UIKit
import StoreKit
class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    static let shared = IAPHelper()
    
    var productID:NSSet = NSSet(object: "string")
    var productsRequest:SKProductsRequest = SKProductsRequest()
    var products = [String: SKProduct]()
    
    var purchaseCompleted: ((Bool, String?) -> Void)?
    
    //retrieves products from iTunes
    func requestProductsWithIdentifiers(productIdentifiers: NSSet){
        let prodIdentifiers = NSSet(objects: Common.PREMIUM_ID)
        productsRequest = SKProductsRequest(productIdentifiers: prodIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    //delegate method
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            products[product.productIdentifier] = product
        }
    }
    
    //handles purchasing
    func beginPurchaseFor(productID: String, purchaseSucceeded:@escaping (Bool, String?)->Void){
        if (SKPaymentQueue.canMakePayments()){
            if let product = products[productID] {
                purchaseCompleted = purchaseSucceeded
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                
            } else {
                purchaseSucceeded(false, "Product not found!")
            }
        } else {
            purchaseSucceeded(false, "User is not authorized to make purchases!")
        }
    }
   
    //purchase response
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    if let receiptURL = Bundle.main.appStoreReceiptURL,
                        FileManager.default.fileExists(atPath: receiptURL.path) {
                        purchaseCompleted!(true, nil)
                        self.receiptValidation()
                    } else {
                    //purchase successful but none received
                    let request = SKReceiptRefreshRequest(receiptProperties: nil)
                    request.delegate = self
                    request.start()
                    
                    if let _ = purchaseCompleted {
                        purchaseCompleted!(true, nil)
                    }
                }
            break
                
            case .failed:
                if let _ = purchaseCompleted {
                    if let _ = transaction.error {
                        purchaseCompleted!(false, transaction.error?.localizedDescription)
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
                
            default:
                break
            }
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            purchaseCompleted!(true, nil)
            self.receiptValidation()
        } else {
            purchaseCompleted!(false, "Could not validate receipt!")
        }
    }
    
    //thanks stack overflow for this wonderful implementation of app store receipt validation!!!
    func receiptValidation() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                
                let receiptString = receiptData.base64EncodedString(options: [])
                let dict = ["receipt-data" : receiptString, "password" : PrivateConstants.premiumKey] as [String : Any]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    
                    if let sandboxURL = Foundation.URL(string:"https://sandbox.itunes.apple.com/verifyReceipt") {
                        var request = URLRequest(url: sandboxURL)
                        request.httpMethod = "POST"
                        request.httpBody = jsonData
                        let session = URLSession(configuration: URLSessionConfiguration.default)
                        let task = session.dataTask(with: request) { data, response, error in
                            if let receivedData = data,
                                let httpResponse = response as? HTTPURLResponse,
                                error == nil,
                                httpResponse.statusCode == 200 {
                                do {
                                    if let jsonResponse = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                                        
                                        print(jsonResponse)
                                        
                                        
                                    } else { print("Failed to cast serialized JSON to Dictionary<String, AnyObject>") }
                                }
                                catch { print("Couldn't serialize JSON with error: " + error.localizedDescription) }
                            }
                        }
                        task.resume()
                    } else { print("Couldn't convert string into URL. Check for special characters.") }
                }
                catch { print("Couldn't create JSON with error: " + error.localizedDescription) }
            }
            catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }
    
    func expirationDateFromResponse(jsonReponse: NSDictionary) -> Date? {
        if let receiptInfo = jsonReponse["latest_receipt_info"] as? NSArray {
            let lastReceipt = receiptInfo.lastObject as! NSDictionary
            var formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let expirationDate = formatter.date(from: lastReceipt["expires_date"] as! String) as! Date
            return expirationDate
            
        } else {
            return nil
        }
    }
    
}
