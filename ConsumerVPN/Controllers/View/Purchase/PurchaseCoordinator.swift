//
//  RevenueCatInteractor.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 2/11/20.
//  Copyright © 2020 NetProtect. All rights reserved.
//

import Foundation
import Purchases

protocol PurchaseCoordinator {
	var productIdentifiers: [String] { get }
	var cachedEmail: String? { get set }
	var cachedPassword: String? { get set }
	
	func fetch(completion: @escaping (Result<[Plan], PurchaseFailureReason>) -> Void)
	func purchaseWithCachedInfo(product: Plan, completion: @escaping (Result<Bool, PurchaseFailureReason>) -> Void)
	func purchase(product: Plan, username: String, password: String?, completion: @escaping  (Result<Bool, PurchaseFailureReason>) -> Void)
}

struct Plan {
	fileprivate let skProduct: SKProduct
	
	let localizedTitle: String
	let localizedSubtitle: String
	let price: NSDecimalNumber
	
	init(product: SKProduct) {
		skProduct = product
		localizedTitle = product.localizedTitle
		localizedSubtitle = product.localizedDescription
		price = product.price
	}
}

enum PurchaseFailureReason : Error {
	case invalidStateEmptyProducts
	case userCancelled
	case purchase(Error)
	case invalidStateTransactionNotFound
	case invalidStateTransactionStateNotPurchased
	case invalidStateNoPurchaserInfo
	case invalidStateNoEntitlementsWithPurchase
	case missingUserInfo
}

class RevenueCatCoordinator : NSObject {
	
	let apiKey: String
	private(set) var userID: String?
	let debug: Bool
	
	private(set) var productIdentifiers: [String]
	
	// Temp storage from sign up screen for when purchasing
	var cachedEmail: String?
	var cachedPassword: String?
	
	init(apiKey: String, debug: Bool, productIdentifiers: [String]) {
		self.apiKey = apiKey
		self.debug = debug
		self.productIdentifiers = productIdentifiers
		
		Purchases.configure(withAPIKey: apiKey)
		Purchases.debugLogsEnabled = debug
	}
}

// MARK: - RevenueCat Logic

extension RevenueCatCoordinator : PurchaseCoordinator {
	
	func fetch(completion: @escaping (Result<[Plan], PurchaseFailureReason>) -> Void) {
		Purchases.shared.products(productIdentifiers) { products in
			
			let plans = products.compactMap { Plan(product: $0) }
			guard !plans.isEmpty else {
				completion(.failure(.invalidStateEmptyProducts))
				return
			}
			
			completion(.success(plans))
		}
	}
	
	func purchaseWithCachedInfo(product: Plan, completion: @escaping (Result<Bool, PurchaseFailureReason>) -> Void) {
		guard let email = cachedEmail, let password = cachedPassword else {
			completion(.failure(.missingUserInfo))
			return
		}
		purchase(product: product, username: email, password: password, completion: completion)
	}
	
	func purchase(product: Plan, username: String, password: String?, completion: @escaping (Result<Bool, PurchaseFailureReason>) -> Void) {
		
		Purchases.shared.setEmail(username)
		
		if let password = password {
			Purchases.shared.setAttributes(["password": password])
		}
		
		Purchases.shared.purchaseProduct(product.skProduct) { possibleTransaction, possiblePurchaserInfo, possibleError, userCancelled in
			
			guard !userCancelled else {
				completion(.failure(.userCancelled))
				return
			}
			
			guard possibleError == nil else {
				completion(.failure(.purchase(possibleError!)))
				return
			}
			
			guard let transaction = possibleTransaction else {
				completion(.failure(.invalidStateTransactionNotFound))
				return
			}
			
			guard case .purchased = transaction.transactionState else {
				completion(.failure(.invalidStateTransactionStateNotPurchased))
				return
			}
			
			guard let purchaserInfo = possiblePurchaserInfo else {
				completion(.failure(.invalidStateNoPurchaserInfo))
				return
			}
			
			guard let _ = purchaserInfo.entitlements.active.first else {
				completion(.failure(.invalidStateNoEntitlementsWithPurchase))
				return
			}
			
			completion(.success(true))
		}
	}
}
