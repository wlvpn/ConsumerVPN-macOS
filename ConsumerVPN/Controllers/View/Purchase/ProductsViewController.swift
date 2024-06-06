//
//  ProductsViewController.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 10/7/20.
//  Copyright © 2020 WLVPN. All rights reserved.
//

import Cocoa

class ProductsViewController : BaseViewController {
	
	private enum PlanViews : Int {
		case topLeft = 10
		case topRight = 11
		case bottomLeft = 20
		case bottomRight = 21
	}
	
	private var activePlans = [Plan]()
	private var purchaseCoordinator: PurchaseCoordinator!
	
	@IBOutlet weak var upgradeToTitleLabel: NSTextField! {
		didSet {
			upgradeToTitleLabel.textColor = NSColor.loginViewText
			upgradeToTitleLabel.stringValue = Theme.iapUpgradeLabel
		}
	}
	@IBOutlet weak var premiumTitleLabel: NSTextField! {
		didSet {
			premiumTitleLabel.textColor = NSColor.loginButton
			premiumTitleLabel.stringValue = Theme.iapPremiumLabel
		}
	}
	@IBOutlet weak var subtitleLabel: NSTextField! {
		didSet {
			subtitleLabel.textColor = NSColor.loginViewText
			subtitleLabel.stringValue = Theme.iapSubtitle
		}
	}
	@IBOutlet weak var bulletPointFirstImageView: NSImageView! {
		didSet {
			bulletPointFirstImageView.themed()
		}
	}
	@IBOutlet weak var bulletPointSecondImageView: NSImageView! {
		didSet {
			bulletPointSecondImageView.themed()
		}
	}
	@IBOutlet weak var bulletPointThirdImageView: NSImageView! {
		didSet {
			bulletPointThirdImageView.themed()
		}
	}
	@IBOutlet weak var bulletPointFirstLabel: NSTextField! {
		didSet {
			bulletPointFirstLabel.textColor = NSColor.loginViewText
			bulletPointFirstLabel.stringValue = Theme.iapPoint1
		}
	}
	@IBOutlet weak var bulletPointSecondLabel: NSTextField! {
		didSet {
			bulletPointSecondLabel.textColor = NSColor.loginViewText
			bulletPointSecondLabel.stringValue = Theme.iapPoint2
		}
	}
	@IBOutlet weak var bulletPointThirdLabel: NSTextField! {
		didSet {
			bulletPointThirdLabel.textColor = NSColor.loginViewText
			bulletPointThirdLabel.stringValue = Theme.iapPoint3
		}
	}
	
	// MARK: Plan Views
	
	@IBOutlet weak var loadingView: NSProgressIndicator!
	
	@IBOutlet weak var plansStackView: NSStackView!
	@IBOutlet weak var topLeftStackView: NSStackView!
	@IBOutlet weak var topRightStackView: NSStackView!
	@IBOutlet weak var bottomLeftStackView: NSStackView!
	@IBOutlet weak var bottomRightStackView: NSStackView!
	
	@IBOutlet weak var topLeftPlanTitle: NSTextField! {
		didSet {
			topLeftPlanTitle.priceTitleStyle()
		}
	}
	@IBOutlet weak var topLeftPlanSubtitle: NSTextField! {
		didSet {
			topLeftPlanSubtitle.priceSubtitleStyle()
		}
	}
	@IBOutlet weak var topLeftPlanPrice: NSTextField! {
		didSet {
			topLeftPlanPrice.priceAmountStyle()
		}
	}
	@IBOutlet weak var topLeftPlanButton: CustomButton! {
		didSet {
			topLeftPlanButton.style()
		}
	}
	
	@IBOutlet weak var topRightPlanTitle: NSTextField! {
		didSet {
			topRightPlanTitle.priceTitleStyle()
		}
	}
	@IBOutlet weak var topRightPlanSubtitle: NSTextField! {
		didSet {
			topRightPlanSubtitle.priceSubtitleStyle()
		}
	}
	@IBOutlet weak var topRightPlanPrice: NSTextField! {
		didSet {
			topRightPlanPrice.priceAmountStyle()
		}
	}
	@IBOutlet weak var topRightPlanButton: CustomButton! {
		didSet {
			topRightPlanButton.style()
		}
	}
	
	@IBOutlet weak var bottomLeftPlanTitle: NSTextField! {
		didSet {
			bottomLeftPlanTitle.priceTitleStyle()
		}
	}
	@IBOutlet weak var bottomLeftPlanSubtitle: NSTextField! {
		didSet {
			bottomLeftPlanSubtitle.priceSubtitleStyle()
		}
	}
	@IBOutlet weak var bottomLeftPlanPrice: NSTextField! {
		didSet {
			bottomLeftPlanPrice.priceAmountStyle()
		}
	}
	@IBOutlet weak var bottomLeftPlanButton: CustomButton! {
		didSet {
			bottomLeftPlanButton.style()
		}
	}
	
	@IBOutlet weak var bottomRightPlanTitle: NSTextField! {
		didSet {
			bottomRightPlanTitle.priceTitleStyle()
		}
	}
	@IBOutlet weak var bottomRightPlanSubtitle: NSTextField! {
		didSet {
			bottomRightPlanSubtitle.priceSubtitleStyle()
		}
	}
	@IBOutlet weak var bottomRightPlanPrice: NSTextField! {
		didSet {
			bottomRightPlanPrice.priceAmountStyle()
		}
	}
	@IBOutlet weak var bottomRightPlanButton: CustomButton! {
		didSet {
			bottomRightPlanButton.style()
		}
	}
	
	// Plans failed
	@IBOutlet weak var plansFailedStackView: NSStackView!
	@IBOutlet weak var plansFailedLabel: NSTextField! {
		didSet {
			plansFailedLabel.priceSubtitleStyle()
		}
	}
	@IBOutlet weak var plansFailedButton: NSButton!
	
	class func newWith(apiManager: VPNAPIManager, purchaseCoordinator: PurchaseCoordinator) -> ProductsViewController {
		let loginStoryboard = NSStoryboard(name: "Products", bundle: nil)
		let productsViewController = loginStoryboard.instantiateController(withIdentifier: "ProductsViewController") as! ProductsViewController
		productsViewController.apiManager = apiManager
		productsViewController.purchaseCoordinator = purchaseCoordinator
		return productsViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchProducts(self)
		
		setHidden(plan: .bottomRight, hidden: true)
		setHidden(plan: .bottomLeft, hidden: true)
		setHidden(plan: .topRight, hidden: true)
		setHidden(plan: .topLeft, hidden: true)
		
		loadingView.startAnimation(nil)
	}
	
	@IBAction func selectedProduct(_ sender: CustomButton) {
		
		var selectedPlan: Plan?

		switch sender.tag {
		case PlanViews.topLeft.rawValue:
			selectedPlan = activePlans.first

		case PlanViews.topRight.rawValue:
			selectedPlan = activePlans[1]

		case PlanViews.bottomLeft.rawValue:
			selectedPlan = activePlans[2]

		case PlanViews.bottomRight.rawValue:
			selectedPlan = activePlans[3]

		default:
			assert(false, "Invalid product selected. Check ProductsViewController.PlanViews enum.")
			return
		}
		
		if let selectedPlan = selectedPlan {
			NotificationCenter.default.post(name: .init("Selected Plan"),
											object: selectedPlan,
											userInfo: nil)
		}
	}
	
	@IBAction func fetchProducts(_ sender: Any) {
		
		purchaseCoordinator.fetch { result in
			DispatchQueue.main.async {
				self.loadingView.stopAnimation(nil)
				
				switch result {
				
				case .success(let plans):
					self.activePlans = plans
					self.plansFailedStackView.isHidden = true
					
					switch plans.count {
					case 0:
						self.plansFailedStackView.isHidden = false
						
					case 1:
						self.setHidden(plan: .topLeft, hidden: false)
						
					case 2:
						self.setHidden(plan: .topLeft, hidden: false)
						self.setHidden(plan: .topRight, hidden: false)
						
					case 3:
						self.setHidden(plan: .topLeft, hidden: false)
						self.setHidden(plan: .topRight, hidden: false)
						self.setHidden(plan: .bottomLeft, hidden: false)
						
					default:
						self.setHidden(plan: .topLeft, hidden: false)
						self.setHidden(plan: .topRight, hidden: false)
						self.setHidden(plan: .bottomLeft, hidden: false)
						self.setHidden(plan: .bottomRight, hidden: false)
					}
					
					
				case .failure(let error):
					self.plansFailedStackView.isHidden = false
					self.setHidden(plan: .bottomRight, hidden: true)
					self.setHidden(plan: .bottomLeft, hidden: true)
					self.setHidden(plan: .topRight, hidden: true)
					self.setHidden(plan: .topLeft, hidden: true)
					print(error)
				}
			}
		}
	}
	
	private func setHidden(plan: PlanViews, hidden: Bool) {
		switch plan {
		
		case .topLeft:
			topLeftStackView.isHidden = hidden
			topLeftPlanTitle.isHidden = hidden
			topLeftPlanSubtitle.isHidden = hidden
			topLeftPlanPrice.isHidden = hidden
			topLeftPlanButton.isHidden = hidden
			if activePlans.count >= 1 {
				let plan = activePlans[0]
				topLeftPlanTitle.stringValue = plan.localizedTitle
				topLeftPlanSubtitle.stringValue = plan.localizedSubtitle
				topLeftPlanPrice.stringValue = plan.price.stringValue
			}
			
		case .topRight:
			topRightStackView.isHidden = hidden
			topRightPlanTitle.isHidden = hidden
			topRightPlanSubtitle.isHidden = hidden
			topRightPlanPrice.isHidden = hidden
			topRightPlanButton.isHidden = hidden
			if activePlans.count >= 2 {
				let plan = activePlans[1]
				topLeftPlanTitle.stringValue = plan.localizedTitle
				topLeftPlanSubtitle.stringValue = plan.localizedSubtitle
				topLeftPlanPrice.stringValue = plan.price.stringValue
			}
			
		case .bottomLeft:
			bottomLeftStackView.isHidden = hidden
			bottomLeftPlanTitle.isHidden = hidden
			bottomLeftPlanSubtitle.isHidden = hidden
			bottomLeftPlanPrice.isHidden = hidden
			bottomLeftPlanButton.isHidden = hidden
			if activePlans.count >= 3 {
				let plan = activePlans[2]
				topLeftPlanTitle.stringValue = plan.localizedTitle
				topLeftPlanSubtitle.stringValue = plan.localizedSubtitle
				topLeftPlanPrice.stringValue = plan.price.stringValue
			}
			
		case .bottomRight:
			bottomRightStackView.isHidden = hidden
			bottomRightPlanTitle.isHidden = hidden
			bottomRightPlanSubtitle.isHidden = hidden
			bottomRightPlanPrice.isHidden = hidden
			bottomRightPlanButton.isHidden = hidden
			if activePlans.count >= 4 {
				let plan = activePlans[3]
				topLeftPlanTitle.stringValue = plan.localizedTitle
				topLeftPlanSubtitle.stringValue = plan.localizedSubtitle
				topLeftPlanPrice.stringValue = plan.price.stringValue
			}
		}
	}
}

extension CustomButton {
	fileprivate func style() {
		borderColor = .gray
		cornerRadius = 10.0
		borderWidth = 2.0
	}
}

extension NSTextField {
	fileprivate func priceTitleStyle() {
		textColor = .gray
		font = .boldSystemFont(ofSize: 20)
	}
	
	fileprivate func priceSubtitleStyle() {
		textColor = .gray
		maximumNumberOfLines = 2
	}
	
	fileprivate func priceAmountStyle() {
		textColor = .gray
		font = .boldSystemFont(ofSize: 20)
	}
}
