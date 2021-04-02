//
//  ServerViewController.swift
//  WhiteLabelVPN
//
//  Created by Zephaniah Cohen on 9/15/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation
import AppKit

class ServerRowView: NSTableRowView {
	override func draw(_ dirtyRect: NSRect) {
	    super.draw(dirtyRect)

        if isSelected == true {
			NSColor.serverListMouseOverBackground.set()
			dirtyRect.fill()
        }
    }
}

class ServerWindowController : NSWindowController {
    class func newWith(apiManager: VPNAPIManager) -> ServerWindowController {
        let serversStoryboard = NSStoryboard(name: "Servers", bundle: nil)
        let serversWindowController = serversStoryboard.instantiateController(withIdentifier: "ServerWindowController") as! ServerWindowController
        let serversViewController = serversWindowController.contentViewController as! ServerViewController
        serversViewController.apiManager = apiManager
        return serversWindowController
    }
}

class ServerViewController : BaseViewController {
    
    class func newWith(apiManager: VPNAPIManager) -> ServerViewController {
        let serversStoryboard = NSStoryboard(name: "Servers", bundle: nil)
        let serverViewController = serversStoryboard.instantiateController(withIdentifier: "ServerViewController") as! ServerViewController
        serverViewController.apiManager = apiManager
        serverViewController.vpnConfiguration = apiManager.vpnConfiguration
        
        return serverViewController
    }

    //MARK: - Properties

	@IBOutlet weak var searchField: NSSearchField!

    var presentedTableData : [City] = []
    fileprivate var originalTableData : [City] = []

    @IBOutlet weak fileprivate var tableView: NSTableView!
    
    //MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(for: self)
        
        configureViewProperties()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        configureDataSource()
        if #available(OSX 10.12.2, *) {
            setTouchBarItems()
            self.touchBar = makeTouchBar()
        }
    }

	override func viewDidAppear() {
        super.viewDidAppear()
        
        //Scrolls to the specified table cell that matches the saved VPN configuration.
        scrollTableToVPNConfiguration()
		
		self.view.window?.makeFirstResponder(tableView)
    }
    
    //MARK: - View Configuration
    
    /// Configures view properties and registers table cell view xibs.
    fileprivate func configureViewProperties() {

        searchField.maximumRecents = 0
        searchField.sendsSearchStringImmediately = true

        let headerBackgroundColor = NSColor.serverListHeader

        let backgroundColor = NSColor.serverListBackground

        tableView.delegate = self
        tableView.dataSource = self
		
        tableView.backgroundColor = backgroundColor
        tableView.enclosingScrollView?.backgroundColor = backgroundColor
        tableView.gridColor = NSColor.serverListRowDivider
        tableView.rowHeight = 40.0

		var frame = tableView.headerView!.frame
		frame.size.height = Theme.serverListHeaderHeight
		tableView.headerView!.frame = frame
        
        let attrStr = NSMutableAttributedString(string: NSLocalizedString("Search", comment:"Search text"),
                                                attributes: [.foregroundColor: NSColor.searchTextColor])
        if let cell = self.searchField.cell as? NSSearchFieldCell {
            cell.textColor = .searchTextColor
            cell.placeholderAttributedString = attrStr
            // Pending icon tinting
        }
		
        for tableColumn in tableView.tableColumns {

            let headerCell = CustomColorHeaderCell(textCell: NSLocalizedString(tableColumn.headerCell.stringValue, comment: ""))

            headerCell.cellColor = headerBackgroundColor
            headerCell.fontColor = NSColor.serverListHeaderText
            headerCell.sortArrowColor = NSColor.serverListHeaderText
            headerCell.separatorColor = NSColor.serverListRowDivider
            headerCell.fontSize = Theme.serverListHeaderFontSize
            headerCell.fontWeight = .regular

			tableColumn.headerCell = headerCell
        }
    }
    
    //MARK: - Configure Data Source
    
    /// Fetches all the city managed objects from the core data store and builds
    /// the table data source. Begins pinging all the cities.
    fileprivate func configureDataSource() {
        
        guard var cities = apiManager.fetchAllCities() as? [City] , cities.count > 0 else {
            return
        }
        
        presentedTableData.removeAll()
        originalTableData.removeAll()
        
        //Sort by country name ascending alphabetically and by city name ascending
        //alphabetically.
        cities = cities.sorted(by: { (lhs, rhs) -> Bool in
            guard let leftCountryName = lhs.country?.localizedName, let rightCountryName = rhs.country?.localizedName else { return false }
            guard let leftCityName = lhs.name, let rightCityName = rhs.name else { return false }
            
            if leftCountryName == rightCountryName {
                return leftCityName < rightCityName
            } else {
                return leftCountryName > rightCountryName
            }
            
        })
		
		for city in cities {
            presentedTableData.append(city)
        }
        
        //Presented table data will be mutated and manipulated. Original table
        //data will always contain an original backing to our data in case we
        //need to restore presented table data from original table data.
        originalTableData += presentedTableData
        
        reloadDataOnMainThread()
	
    }

    //MARK: - Search Management

    @IBAction func updateFilter(_ sender: NSSearchField) {
        let searchText : String = String(sender.stringValue)

        if searchText.count > 0 {
            presentedTableData = filterArrayFor(filterCriteria: searchText, dataSourceToFilter: originalTableData)
        } else {
            restorePresentedData()
        }

        reloadDataOnMainThread()
    }

    /// Filters the original array data source and returns a new filtered array.
    /// Filters by city name, country name, server name.
    ///
    /// - Parameters:
    ///   - filterCriteria: The term to filter the array data source by.
    ///   - dataSourceToFilter: The original unfiltered data source.
    /// - Returns: A new filtered array.
    fileprivate func filterArrayFor(filterCriteria : String, dataSourceToFilter : [City]) -> [City] {
        
        return dataSourceToFilter.filter({ (city) -> Bool in
            
            guard let cityName = city.name,
                let countryID = city.country?.countryID,
                let countryName = city.country?.name else  {
                    return false
            }
            
            return cityName.lowercased().contains(filterCriteria.lowercased()) ||
                countryID.lowercased().contains(filterCriteria.lowercased()) ||
                countryName.lowercased().contains(filterCriteria.lowercased())
        })
    }
    
    /// Used to restore the original table data in the event that any filters were
    /// applied to the data source.
    func restorePresentedData() {
        //Restore the displayed data from our original data set.
        presentedTableData.removeAll()
        presentedTableData += originalTableData
        
        reloadDataOnMainThread()
    }

	@IBAction func rowClicked(_ sender: Any) {
        clickAction()
	}
	
	@IBAction func rowDoubleClicked(_ sender: NSTableView) {
		if sender.clickedRow != -1 {
			clickAction()
		}
	}

    func clickAction() {
        if tableView.selectedRow == 0 {
            apiManager.vpnConfiguration.country = nil
            apiManager.vpnConfiguration.city = nil
            apiManager.vpnConfiguration.server = nil
        } else if tableView.selectedRow > -1 {
            apiManager.vpnConfiguration.server = nil
            apiManager.vpnConfiguration.setCityAndCountry(presentedTableData[safe: tableView.selectedRow-1])
        }
    }
	
	//MARK: - Alert Dialog Management
    
    /// Displays an alert dialog with the appropriate configurations and presents the
    /// dialog as am odal sheet.
    ///
    /// - parameter alertText:          The alert text to display
    /// - parameter actionTitleMessage: The action button text
    /// - parameter nonActionTitle:     Optional non action button text
    /// - parameter handler:            Optional completion handler that returns the selected action/non-action choice.
    fileprivate func displayAlertDialog(alertMessageText alertText : String,  actionTitleMessage : String, nonActionTitle : String?, completionHandler handler : ((NSApplication.ModalResponse) -> Void)?) {
        
        if let window = view.window {
            let alert = NSAlert()
            alert.addButton(withTitle: actionTitleMessage)
            
            if let unwrappedNonActionTitle = nonActionTitle {
                alert.addButton(withTitle: unwrappedNonActionTitle)
            }
            
            alert.informativeText = alertText
            alert.alertStyle = NSAlert.Style.informational
            
            alert.beginSheetModal(for: window) { (selectedResponseCode) in
                handler?(selectedResponseCode)
            }
        }
    }

    //MARK: - Data/Scroll Management

    /// Reloads the table data on the main thread. Useful because pinging will
    /// work on a background thread and UI may appear to misbehave if not handled
    /// on the UI thread.
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollTableToVPNConfiguration()

        }
    }

    /// Looks up the index for the cell that matches the VPN configuration then
    /// computes the yCoordinate where this cell is located and animates the
    /// scrolling to that table cell.
    fileprivate func scrollTableToVPNConfiguration() {
        //Scroll to the row that matches the selected pop on the vpn configuration (if set)
		
		var theIndex : Int = -1
		
		if presentedTableData.firstIndex(where: { $0 == vpnConfiguration?.city }) != nil {
			theIndex = presentedTableData.firstIndex(where: { $0 == vpnConfiguration?.city })!
		}
		
		let indexSet: IndexSet = [theIndex+1]
		tableView.scrollRowToVisible(theIndex+1)
		tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }

}

//MARK: - Table View Delegate / Data Source

extension ServerViewController : NSTableViewDelegate, NSTableViewDataSource {
	fileprivate enum CellIdentifiers {
		static let FlagCell = "flagCell"
		static let CountryCell = "countryCell"
		static let CityCell = "cityCell"
	}
	
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // +1 for the best available row
        return (presentedTableData.count+1)
    }
	
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""

        if row == 0 {
			if tableColumn == tableView.tableColumns[0] {
				image = NSImage(named: "Fastest Available")
				text = ""
				cellIdentifier = CellIdentifiers.FlagCell
			} else if tableColumn == tableView.tableColumns[1] {
				text = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
				cellIdentifier = CellIdentifiers.CountryCell
			} else if tableColumn == tableView.tableColumns[2] {
				text = ""
				cellIdentifier = CellIdentifiers.CityCell
			}
        } else {
            let actualRow = row - 1
            guard let city = presentedTableData[safe: actualRow] else {
                return nil
            }

            if tableColumn == tableView.tableColumns[0] {
                image = city.country?.flagImage
                text = ""
                cellIdentifier = CellIdentifiers.FlagCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = (city.country?.name)!
                cellIdentifier = CellIdentifiers.CountryCell
            } else if tableColumn == tableView.tableColumns[2] {
                text = (city.name)!
                cellIdentifier = CellIdentifiers.CityCell
            }

        }

		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = text
			cell.imageView?.image = image ?? nil
			cell.imageView?.wantsLayer = true
			
			cell.imageView?.layer?.cornerRadius = 5.0
			cell.imageView?.layer?.masksToBounds = true
			
            cell.textField?.textColor = cellIdentifier == CellIdentifiers.CountryCell ? NSColor.serverCountryText : NSColor.serverCityText
			return cell
		}
		
		return nil
	}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let myCustomView = ServerRowView()
        return myCustomView
    }

    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let citiesAsMutableArray = NSMutableArray(array: originalTableData)

		citiesAsMutableArray.sort(using: tableView.sortDescriptors)
        presentedTableData = citiesAsMutableArray as! [City]

        tableView.reloadData()
        self.scrollTableToVPNConfiguration()
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = row % 2 == 0
            ? .serverSelectRow1
            : .serverSelectRow2
    }
}

//MARK: - Collection Extension

extension Collection {
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

//MARK: - Server Status Reporting Conformance

extension ServerViewController : VPNServerStatusReporting {
    func statusServerUpdateSucceeded(_ notification: Notification) {
        //Reload all data again for any changes that may have occurred to servers
        //from the API update.
        configureDataSource()
        updateFilter(searchField)
    }
}

extension ServerViewController: VPNConfigurationStatusReporting {
    func statusCurrentCityDidChange(_ notification: Notification) {
        self.view.window?.close()
    }
}
