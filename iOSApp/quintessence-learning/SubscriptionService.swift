/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import StoreKit

class SubscriptionService: UIViewController {
  
  static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
  static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
  static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
  static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
  
  
  static let shared = SubscriptionService()
  
    var products = [String:SKProduct]()
    
  var hasReceiptData: Bool?
  
  var currentSessionId: String? {
    didSet {
      NotificationCenter.default.post(name: SubscriptionService.sessionIdSetNotification, object: currentSessionId)
    }
  }
  
  var currentSubscription: PaidSubscription?
  
  func loadSubscriptionOptions() {
    let productIDs = Set([Common.PREMIUM_ID])
    
    let request = SKProductsRequest(productIdentifiers: productIDs)
    request.delegate = self
    request.start()
    }
    
  func purchase(product: String) {
    
    let payment = SKPayment(product: products[product]!)
    SKPaymentQueue.default().add(payment)
  }
  
  func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
    if let receiptData = loadReceipt() {
      SelfieService.shared.upload(receipt: receiptData) { [weak self] (result) in
        guard let strongSelf = self else { return }
        switch result {
        case .success(let result):
          strongSelf.currentSessionId = result.sessionId
          strongSelf.currentSubscription = result.currentSubscription
          completion?(true)
        case .failure(let error):
          print("🚫 Receipt Upload Failed: \(error)")
          completion?(false)
        }
      }
    }
  }
  
  func loadReceipt() -> Data?{
    guard let url = Bundle.main.appStoreReceiptURL else {
      SubscriptionService.shared.hasReceiptData = false
        return nil
    }
    
    do {
      let data = try Data(contentsOf: url)
        SelfieService.shared.upload(receipt: data, completion: { (result) in
            if (Common.expireDate <= Date().timeIntervalSince1970){
                SubscriptionService.shared.hasReceiptData = false
            } else {
                SubscriptionService.shared.hasReceiptData = true
            }
        })
        return data
    } catch {
      print("Error loading receipt data: \(error.localizedDescription)")
      SubscriptionService.shared.hasReceiptData = false
        return nil
    }
  }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("hello \(response.products)")
        for product in response.products {
            products[product.productIdentifier] = product
        }
    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    if request is SKProductsRequest {
      print("Subscription Options Failed Loading: \(error.localizedDescription)")
    }
  }
