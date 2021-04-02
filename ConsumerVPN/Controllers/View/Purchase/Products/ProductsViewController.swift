//
//  ProductsViewController.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 10/7/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Cocoa

class PurchaseViewController: BaseViewController {
	
	private var purchaseCoordinator: PurchaseCoordinator!
	
	@IBOutlet weak var logoImageView: NSImageView!
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var subtitleLabel: NSTextField!
	
	@IBOutlet weak var topBulletPointLabel: NSTextField!
	@IBOutlet weak var topBulletPointImageView: NSImageView!
	@IBOutlet weak var midTopBulletPointLabel: NSTextField!
	@IBOutlet weak var midTopBulletPointImageView: NSImageView!
	@IBOutlet weak var midBottomBulletPointLabel: NSTextField!
	@IBOutlet weak var midBottomBulletPointImageView: NSImageView!
	@IBOutlet weak var bottomBulletPointLabel: NSTextField!
	@IBOutlet weak var bottomBulletPointImageView: NSImageView!
	@IBOutlet weak var priceLabel: NSTextField!
	
	@IBOutlet weak var subscriptionTitleLabel: NSTextField!
	@IBOutlet weak var subscriptionDetailsLabel: NSTextField!
	
	class func newWith(apiManager: VPNAPIManager) -> PurchaseViewController {
		let loginStoryboard = NSStoryboard(name: "Products", bundle: nil)
		let purchaseViewController = loginStoryboard.instantiateController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
		purchaseViewController.apiManager = apiManager
		purchaseViewController.vpnConfiguration = apiManager.vpnConfiguration
		purchaseViewController.purchaseCoordinator = RevenueCatCoordinator(apiKey: "oMFIwRWyLahCLWYvknUvmnkCLkVEyySD",
																		   debug: true,
																		   productIdentifiers: ["1MONTHSUB, 1YEARVPN"])
		
		return purchaseViewController
	}
}
