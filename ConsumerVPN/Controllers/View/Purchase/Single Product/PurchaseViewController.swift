//
//  PurchaseViewController.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 10/11/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Foundation

class PurchaseViewController: BaseViewController {
	
	private var purchaseCoordinator: PurchaseCoordinator!
	
	var selectedPlan: Plan!
	
	@IBOutlet weak var logoImageView: NSImageView!
	@IBOutlet weak var titleLabel: NSTextField! {
		didSet {
			titleLabel.textColor = .white
			titleLabel.font = .boldSystemFont(ofSize: 25)
			titleLabel.stringValue = selectedPlan.localizedTitle
		}
	}
	@IBOutlet weak var subtitleLabel: NSTextField! {
		didSet {
			subtitleLabel.textColor = .white
			subtitleLabel.stringValue = selectedPlan.localizedTitle
		}
	}
	
	@IBOutlet weak var bulletPointsBackground: CustomButton! {
		didSet {
			bulletPointsBackground.isEnabled = false
			bulletPointsBackground.backgroundColor = NSColor.gray.withAlphaComponent(0.25)
			bulletPointsBackground.cornerRadius = 8.0
		}
	}
	@IBOutlet weak var topBulletPointLabel: NSTextField! {
		didSet {
			topBulletPointLabel.textColor = .white
			topBulletPointLabel.stringValue = Theme.singleIAPPoint1
		}
	}
	@IBOutlet weak var topBulletPointImageView: NSImageView! {
		didSet {
			topBulletPointImageView.themed()
		}
	}
	@IBOutlet weak var midTopBulletPointLabel: NSTextField! {
		didSet {
			midTopBulletPointLabel.textColor = .white
			midTopBulletPointLabel.stringValue = Theme.singleIAPPoint2
		}
	}
	@IBOutlet weak var midTopBulletPointImageView: NSImageView! {
		didSet {
			midTopBulletPointImageView.themed()
		}
	}
	@IBOutlet weak var midBottomBulletPointLabel: NSTextField! {
		didSet {
			midBottomBulletPointLabel.textColor = .white
			midBottomBulletPointLabel.stringValue = Theme.singleIAPPoint3
		}
	}
	@IBOutlet weak var midBottomBulletPointImageView: NSImageView! {
		didSet {
			midBottomBulletPointImageView.themed()
		}
	}
	@IBOutlet weak var bottomBulletPointLabel: NSTextField! {
		didSet {
			bottomBulletPointLabel.textColor = .white
			bottomBulletPointLabel.stringValue = Theme.singleIAPPoint4
		}
	}
	@IBOutlet weak var bottomBulletPointImageView: NSImageView! {
		didSet {
			bottomBulletPointImageView.themed()
		}
	}
	@IBOutlet weak var priceLabel: NSTextField! {
		didSet {
			priceLabel.textColor = .white
			priceLabel.font = .boldSystemFont(ofSize: 32)
			priceLabel.stringValue = selectedPlan.price.stringValue
		}
	}
	@IBOutlet weak var subscribeNowButton: CustomButton! {
		didSet {
			subscribeNowButton.buttonText = Theme.singleIAPSubscribeButtonText
			subscribeNowButton.fontSize = 20
			subscribeNowButton.backgroundColor = .red
			subscribeNowButton.cornerRadius = 3.0
		}
	}
	
	@IBOutlet weak var subscriptionTitleLabel: NSTextField! {
		didSet {
			subscriptionTitleLabel.textColor = .white
			subscriptionTitleLabel.stringValue = Theme.singleIAPSubscriptionDetailsTitle
		}
	}
	@IBOutlet weak var subscriptionDetailsLabel: NSTextField! {
		didSet {
			subscriptionDetailsLabel.textColor = .gray
			subscriptionDetailsLabel.stringValue = Theme.singleIAPSubscriptionDetailsText
		}
	}
	
	class func newWith(apiManager: VPNAPIManager, purchaseCoordinator: PurchaseCoordinator) -> PurchaseViewController {
		let loginStoryboard = NSStoryboard(name: "Purchase", bundle: nil)
		let purchaseViewController = loginStoryboard.instantiateController(withIdentifier: "PurchaseViewController") as! PurchaseViewController
		purchaseViewController.apiManager = apiManager
		purchaseViewController.vpnConfiguration = apiManager.vpnConfiguration
		purchaseViewController.purchaseCoordinator = purchaseCoordinator
		return purchaseViewController
	}
	
	@IBAction func back(_ sender: Any) {
		NotificationCenter.default.post(name: .init("CancelPurchase"), object: nil)
	}
	
	@IBAction func subscribe(_ sender: Any) {
		purchaseCoordinator.purchaseWithCachedInfo(product: selectedPlan) { result in
			switch result {
			case .success(let didPurchase):
				guard let email = self.purchaseCoordinator.cachedEmail, let password = self.purchaseCoordinator.cachedPassword else { return }
				self.apiManager.login(withUsername: email, password: password)
				break
				
			case .failure(let error):
				let alert = NSAlert()
				alert.messageText = NSLocalizedString("LoginFailedGeneral", comment: "LoginFailedGeneral")
				alert.informativeText = error.localizedDescription
				if let window = self.view.window {
					alert.beginSheetModal(for: window, completionHandler: nil)
				}
			}
		}
	}
}

