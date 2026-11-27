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
    }

    override func drawSelection(in dirtyRect: NSRect) {
        guard selectionHighlightStyle != .none else { return }
        NSColor.serverListMouseOverBackground.setFill()
        bounds.fill()
    }

    override func drawSeparator(in dirtyRect: NSRect) {
        let horizontalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 2.0
        let separatorY = isFlipped ? bounds.maxY - separatorHeight : bounds.minY
        let separatorRect = NSRect(
            x: bounds.origin.x + horizontalInset,
            y: separatorY,
            width: max(0.0, bounds.width - (horizontalInset * 2.0)),
            height: separatorHeight
        )

        NSColor.serverListHeader.set()
        separatorRect.fill()
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
    fileprivate enum ServerListMode {
        case locations
        case dedicatedServers
    }
    
    fileprivate struct DedicatedServerEntry {
        let city: City
        let server: Server
    }
    private static var persistedSortDescriptors: [NSSortDescriptor] = []
    
    class func newWith(apiManager: VPNAPIManager) -> ServerViewController {
        let serversStoryboard = NSStoryboard(name: "Servers", bundle: nil)
        let serverViewController = serversStoryboard.instantiateController(withIdentifier: "ServerViewController") as! ServerViewController
        serverViewController.apiManager = apiManager
        return serverViewController
    }

    //MARK: - Properties
    @IBOutlet weak var backgroundView: ColorView!
	@IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var locationsServersButton: NSButton!
    @IBOutlet weak var dedicatedServersButton: NSButton!

    var presentedTableData : [City] = []
    fileprivate var originalTableData : [City] = []
    fileprivate var originalDedicatedServersData: [DedicatedServerEntry] = []
    fileprivate var presentedDedicatedServersData: [DedicatedServerEntry] = []
    fileprivate var serverListMode: ServerListMode = .locations
    private var defaultSortDescriptorPrototypes: [NSUserInterfaceItemIdentifier: NSSortDescriptor] = [:]
    private lazy var maintenanceServerIcon: NSImage? = {
        guard let baseImage = NSImage(named: "server_off") else {
            return nil
        }
        return makeTintedImage(baseImage, tintColor: .systemRed)
    }()
    
    @IBOutlet weak fileprivate var tableView: NSTableView!
    weak var delegate: ConnectViewDelegate?
    
    //MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeWindow()
        
        NotificationCenter.default.addObserver(for: self)
        
        configureViewProperties()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        searchField.stringValue = ""
        serverListMode = .dedicatedServers
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
    
    deinit {
        NotificationCenter.default.removeObserver(for: self)
    }
    
    //MARK: - Utility Methods
    
    /// Prepares the window properties for initial load.
    private func themeWindow() {
        backgroundView.backgroundColor = NSColor.primaryBackground
    }
    
    //MARK: - View Configuration
    
    /// Configures view properties and registers table cell view xibs.
    fileprivate func configureViewProperties() {

        searchField.maximumRecents = 0
        searchField.sendsSearchStringImmediately = true
        searchField.textColor = .searchTextColor
        searchField.backgroundColor = .searchBackgroundColor
        
        updateModeButtonsAppearance()
        
        let headerBackgroundColor = NSColor.serverListHeader

        let backgroundColor = NSColor.primaryBackground

        tableView.delegate = self
        tableView.dataSource = self
		
        tableView.backgroundColor = backgroundColor
        tableView.enclosingScrollView?.backgroundColor = backgroundColor
        tableView.gridColor = NSColor.serverListHeader
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
            if let sortDescriptorPrototype = tableColumn.sortDescriptorPrototype {
                defaultSortDescriptorPrototypes[tableColumn.identifier] = sortDescriptorPrototype
            }

            let headerCell = CustomColorHeaderCell(textCell: NSLocalizedString(tableColumn.headerCell.stringValue, comment: ""))

            headerCell.cellColor = headerBackgroundColor
            headerCell.fontColor = NSColor.serverListHeaderText
            headerCell.sortArrowColor = NSColor.serverListHeaderText
            headerCell.separatorColor = NSColor.serverListRowDivider
            headerCell.fontSize = Theme.serverListHeaderFontSize
            headerCell.fontWeight = .regular

			tableColumn.headerCell = headerCell
        }

        if !ServerViewController.persistedSortDescriptors.isEmpty {
            tableView.sortDescriptors = ServerViewController.persistedSortDescriptors
        }
        
        updateColumnHeaders()
    }
    
    //MARK: - Configure Data Source
    
    /// Fetches all the city managed objects from the core data store and builds
    /// the table data source. Begins pinging all the cities.
fileprivate func configureDataSource() {
    var cities = ApiManagerHelper.shared.fetchCities()
    var dedicatedServers = ApiManagerHelper.shared.fetchServersWithDedicatedIPs()

    presentedTableData.removeAll()
    originalTableData.removeAll()
    originalDedicatedServersData.removeAll()
    presentedDedicatedServersData.removeAll()

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

    dedicatedServers = dedicatedServers.sorted { lhs, rhs in
        let leftHost = lhs.hostname ?? lhs.ipAddress ?? ""
        let rightHost = rhs.hostname ?? rhs.ipAddress ?? ""
        return leftHost.localizedCaseInsensitiveCompare(rightHost) == .orderedAscending
    }

    originalDedicatedServersData = dedicatedServers.compactMap { server in
        guard let city = cityForDedicatedServer(server) else {
            return nil
        }
        return DedicatedServerEntry(city: city, server: server)
    }

    let hasDedicatedServers = !originalDedicatedServersData.isEmpty
    dedicatedServersButton.isHidden = !hasDedicatedServers
    if !hasDedicatedServers {
        serverListMode = .locations
    }

    updateModeButtonsAppearance()
    updateColumnHeaders()

    switch serverListMode {
    case .locations:
        originalTableData = cities
        presentedTableData = originalTableData
        if !tableView.sortDescriptors.isEmpty {
            let citiesAsMutableArray = NSMutableArray(array: originalTableData)
            citiesAsMutableArray.sort(using: tableView.sortDescriptors)
            presentedTableData = citiesAsMutableArray as! [City]
            originalTableData = presentedTableData
        }
    case .dedicatedServers:
        presentedDedicatedServersData = originalDedicatedServersData
        if !tableView.sortDescriptors.isEmpty {
            sortDedicatedEntries(using: tableView.sortDescriptors)
        }
    }

    reloadDataOnMainThread()

}

    //MARK: - Search Management

@IBAction func updateFilter(_ sender: NSSearchField) {
    let searchText : String = String(sender.stringValue)

    if searchText.count > 0 {
        switch serverListMode {
        case .locations:
            presentedTableData = filterArrayFor(filterCriteria: searchText, dataSourceToFilter: originalTableData)
        case .dedicatedServers:
            presentedDedicatedServersData = filterDedicatedEntries(filterCriteria: searchText, dataSourceToFilter: originalDedicatedServersData)
        }
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
    switch serverListMode {
    case .locations:
        presentedTableData.removeAll()
        presentedTableData += originalTableData
    case .dedicatedServers:
        presentedDedicatedServersData.removeAll()
        presentedDedicatedServersData += originalDedicatedServersData
    }

    reloadDataOnMainThread()
}

	@IBAction func rowClicked(_ sender: NSTableView) {
        if sender.clickedRow != -1 {
            clickAction()
        }
	}
	
	@IBAction func rowDoubleClicked(_ sender: NSTableView) {
		if sender.clickedRow != -1 {
			clickAction()
		}
	}

func clickAction() {
    guard tableView.selectedRow > -1 else {
        return
    }

    switch serverListMode {
    case .locations:
        if includesFastestRow && self.tableView.selectedRow == 0 {
            ApiManagerHelper.shared.resetServer()
        } else {
            let dataRowIndex = includesFastestRow ? self.tableView.selectedRow - 1 : self.tableView.selectedRow
            guard let selectedCity = self.presentedTableData[safe: dataRowIndex] else {
                return
            }

            if selectedCity.servers?.first?.maintenance == true {
                displayMaintenanceAlert()
                return
            }

            ApiManagerHelper.shared.selectServerWith(city: selectedCity)
        }
    case .dedicatedServers:
        guard let selectedEntry = self.presentedDedicatedServersData[safe: self.tableView.selectedRow] else {
            return
        }

        if selectedEntry.server.maintenance == true {
            displayMaintenanceAlert()
            return
        }

        ApiManagerHelper.shared.setServer(selectedEntry.server)
        ApiManagerHelper.shared.setCity(selectedEntry.city)
        ApiManagerHelper.shared.setCoutnry(selectedEntry.city.country)
    }

    if ApiManagerHelper.shared.isOnDemandEnabled {
        ApiManagerHelper.shared.synchronizeConfiguration()
    } else {
        self.delegate?.didSelectConnect()
    }

    self.view.window?.close()

}

    private func displayMaintenanceAlert() {
        guard let window = view.window else { return }

        let alert = NSAlert()
        alert.messageText = NSLocalizedString("ServerMaintenanceAlertTitle", comment: "Maintenance alert title")
        alert.informativeText = NSLocalizedString("ServerMaintenanceAlertMessage", comment: "Maintenance alert message")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("ServerMaintenanceAlertClose", comment: "Maintenance alert close button"))
        alert.beginSheetModal(for: window, completionHandler: nil)
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

    let selectedRow: Int
    switch serverListMode {
    case .locations:
        if let cityIndex = presentedTableData.firstIndex(where: { $0 == ApiManagerHelper.shared.getCity() }) {
            selectedRow = cityIndex + (includesFastestRow ? 1 : 0)
        } else if includesFastestRow {
            selectedRow = 0
        } else if !presentedTableData.isEmpty {
            selectedRow = 0
        } else {
            selectedRow = -1
        }
    case .dedicatedServers:
        if let currentServer = ApiManagerHelper.shared.vpnConfiguration?.server,
           let selectedIndex = presentedDedicatedServersData.firstIndex(where: { $0.server == currentServer }) {
            selectedRow = selectedIndex
        } else if let currentCity = ApiManagerHelper.shared.getCity(),
                  let selectedIndex = presentedDedicatedServersData.firstIndex(where: { $0.city == currentCity }) {
            selectedRow = selectedIndex
        } else if !presentedDedicatedServersData.isEmpty {
            selectedRow = 0
        } else {
            selectedRow = -1
        }
    }

    if selectedRow >= 0 {
        let indexSet: IndexSet = [selectedRow]
        tableView.scrollRowToVisible(selectedRow)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    } else {
        tableView.deselectAll(nil)
    }
}

    @IBAction func dedicatedButtonClicked(_ sender: NSButton) {
        switchToMode(.dedicatedServers)
    }

    @IBAction func locationsButtonClicked(_ sender: NSButton) {
        switchToMode(.locations)
    }

    private var includesFastestRow: Bool {
        return serverListMode == .locations
    }

    private func switchToMode(_ mode: ServerListMode) {
        let modeChanged = (serverListMode != mode)
        serverListMode = mode
        updateModeButtonsAppearance()
        
        guard modeChanged else { return }
        updateColumnHeaders()
        configureDataSource()
        updateFilter(searchField)
    }

    private func updateModeButtonsAppearance() {
        applyStyle(for: locationsServersButton, selected: serverListMode == .locations)
        applyStyle(for: dedicatedServersButton, selected: serverListMode == .dedicatedServers)
    }

    private func applyStyle(for button: NSButton, selected: Bool) {
        button.state = selected ? .on : .off
        if #available(macOS 10.14, *) {
            button.bezelColor = selected ? .systemBlue : .searchBackgroundColor
        } else {
            button.bezelColor = selected ? NSColor(calibratedRed: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0) : .searchBackgroundColor
        }
    }

    private func updateColumnHeaders() {
        let countryHeaderTitle: String
        let cityHeaderTitle: String

        switch serverListMode {
        case .locations:
            countryHeaderTitle = "Country"
            cityHeaderTitle = "City"
        case .dedicatedServers:
            countryHeaderTitle = "Server"
            cityHeaderTitle = "IP Address"
        }

        setHeaderTitle(countryHeaderTitle, forColumnIdentifier: "countryColumn")
        setHeaderTitle(cityHeaderTitle, forColumnIdentifier: "cityColumn")
        updateSortingAvailability()
        tableView.headerView?.needsDisplay = true
    }

    private func updateSortingAvailability() {
        let countryColumnIdentifier = NSUserInterfaceItemIdentifier("countryColumn")
        let cityColumnIdentifier = NSUserInterfaceItemIdentifier("cityColumn")

        guard
            let countryColumn = tableView.tableColumns.first(where: { $0.identifier == countryColumnIdentifier }),
            let cityColumn = tableView.tableColumns.first(where: { $0.identifier == cityColumnIdentifier })
        else {
            return
        }

        if let countrySortDescriptor = defaultSortDescriptorPrototypes[countryColumnIdentifier] {
            countryColumn.sortDescriptorPrototype = countrySortDescriptor
        }

        let citySortKey = defaultSortDescriptorPrototypes[cityColumnIdentifier]?.key

        switch serverListMode {
        case .locations:
            cityColumn.sortDescriptorPrototype = defaultSortDescriptorPrototypes[cityColumnIdentifier]
            (countryColumn.headerCell as? CustomColorHeaderCell)?.showsSortIndicator = true
            (cityColumn.headerCell as? CustomColorHeaderCell)?.showsSortIndicator = true
        case .dedicatedServers:
            cityColumn.sortDescriptorPrototype = nil
            (countryColumn.headerCell as? CustomColorHeaderCell)?.showsSortIndicator = true
            (cityColumn.headerCell as? CustomColorHeaderCell)?.showsSortIndicator = false

            if let citySortKey {
                let sortDescriptorsWithoutCity = tableView.sortDescriptors.filter { $0.key != citySortKey }
                if sortDescriptorsWithoutCity.count != tableView.sortDescriptors.count {
                    tableView.sortDescriptors = sortDescriptorsWithoutCity
                    ServerViewController.persistedSortDescriptors = sortDescriptorsWithoutCity
                }
            }
        }
    }

    private func setHeaderTitle(_ title: String, forColumnIdentifier identifier: String) {
        let nsIdentifier = NSUserInterfaceItemIdentifier(identifier)
        guard let column = tableView.tableColumns.first(where: { $0.identifier == nsIdentifier }) else {
            return
        }
        column.headerCell.stringValue = title
    }

private func dedicatedIPAddressString(for server: Server) -> String {
    if let dedicatedIPAddress = server.value(forKey: "dedicatedIPAddress") as? String, !dedicatedIPAddress.isEmpty {
        return dedicatedIPAddress
    }

    return server.ipAddress ?? "No IP"
}

private func cityForDedicatedServer(_ server: Server) -> City? {
    if let city = server.value(forKey: "city") as? City {
        return city
    }
    if let cities = server.value(forKey: "cities") as? NSSet {
        return cities.anyObject() as? City
    }
    return nil
}

private func dedicatedServerName(for entry: DedicatedServerEntry) -> String {
    if let name = entry.city.name, !name.isEmpty {
        return name
    }
    if let hostname = entry.server.hostname, !hostname.isEmpty {
        return hostname
    }
    if let ipAddress = entry.server.ipAddress, !ipAddress.isEmpty {
        return ipAddress
    }
    return "Dedicated Server"
}

private func makeTintedImage(_ image: NSImage, tintColor: NSColor) -> NSImage {
    let tintedImage = NSImage(size: image.size)
    tintedImage.lockFocus()

    let imageRect = NSRect(origin: .zero, size: image.size)
    image.draw(in: imageRect)
    tintColor.set()
    imageRect.fill(using: .sourceAtop)

    tintedImage.unlockFocus()
    tintedImage.isTemplate = false
    return tintedImage
}

private func filterDedicatedEntries(filterCriteria: String, dataSourceToFilter: [DedicatedServerEntry]) -> [DedicatedServerEntry] {
    let query = filterCriteria.lowercased()
    return dataSourceToFilter.filter { entry in
        let cityName = (entry.city.name ?? "").lowercased()
        let countryID = (entry.city.country?.countryID ?? "").lowercased()
        let countryName = (entry.city.country?.name ?? "").lowercased()
        let host = (entry.server.hostname ?? "").lowercased()
        let ip = dedicatedIPAddressString(for: entry.server).lowercased()

        return cityName.contains(query) ||
            countryID.contains(query) ||
            countryName.contains(query) ||
            host.contains(query) ||
            ip.contains(query)
    }
}

private func sortDedicatedEntries(using sortDescriptors: [NSSortDescriptor]) {
    guard let descriptor = sortDescriptors.first else { return }

    let ascending = descriptor.ascending
    presentedDedicatedServersData.sort { lhs, rhs in
        let left = dedicatedServerName(for: lhs)
        let right = dedicatedServerName(for: rhs)
        if ascending {
            return left.localizedCaseInsensitiveCompare(right) == .orderedAscending
        }
        return left.localizedCaseInsensitiveCompare(right) == .orderedDescending
    }
}

}

//MARK: - Table View Delegate / Data Source

extension ServerViewController : NSTableViewDelegate, NSTableViewDataSource {
	fileprivate enum CellIdentifiers {
		static let CountryCell = "countryCell"
		static let CityCell = "cityCell"
	}
	
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row == -1 {
            return false
        }
        
        return true
    }
    
func numberOfRows(in tableView: NSTableView) -> Int {
    switch serverListMode {
    case .locations:
        return presentedTableData.count + (includesFastestRow ? 1 : 0)
    case .dedicatedServers:
        return presentedDedicatedServersData.count
    }
}
	
func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let tableColumn else { return nil }

    var image: NSImage?
    var text: String = ""
    var cellIdentifier: String = ""
    var isDedicatedServerInMaintenance = false
    let isCountryColumn = tableColumn.identifier.rawValue == "countryColumn"
    let isCityColumn = tableColumn.identifier.rawValue == "cityColumn"

    if includesFastestRow && row == 0 {
        if isCountryColumn {
            image = NSImage(named: "Fastest Available")
            text = NSLocalizedString("FastestAvailable", comment: "Fastest Available Text")
            cellIdentifier = CellIdentifiers.CountryCell
        } else if isCityColumn {
            text = ""
            cellIdentifier = CellIdentifiers.CityCell
        }
    } else {
        switch serverListMode {
        case .locations:
            let actualRow = includesFastestRow ? row - 1 : row
            guard let city = presentedTableData[safe: actualRow] else {
                return nil
            }

            if isCountryColumn {
                image = city.country?.flagImage
                text = city.country?.name ?? ""
                cellIdentifier = CellIdentifiers.CountryCell
            } else if isCityColumn {
                text = city.name ?? ""
                cellIdentifier = CellIdentifiers.CityCell
            }
        case .dedicatedServers:
            guard let entry = presentedDedicatedServersData[safe: row] else {
                return nil
            }

            isDedicatedServerInMaintenance = entry.server.maintenance == true
            image = entry.city.country?.flagImage

            if isCountryColumn {
                text = dedicatedServerName(for: entry)
                cellIdentifier = CellIdentifiers.CountryCell
            } else if isCityColumn {
                text = dedicatedIPAddressString(for: entry.server)
                cellIdentifier = CellIdentifiers.CityCell
            }
        }

    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = text
        cell.imageView?.image = image ?? nil
        cell.imageView?.wantsLayer = true

        cell.imageView?.layer?.cornerRadius = 5.0
        cell.imageView?.layer?.masksToBounds = true

        if isDedicatedServerInMaintenance {
            cell.textField?.textColor = .systemRed
            cell.imageView?.image = maintenanceServerIcon ?? NSImage(named: "server_off")
            if #available(macOS 10.14, *) {
                cell.imageView?.contentTintColor = nil
            }
        } else {
            if #available(macOS 10.14, *) {
                cell.imageView?.contentTintColor = nil
            }
            cell.textField?.textColor = cellIdentifier == CellIdentifiers.CountryCell ? NSColor.serverCountryText : NSColor.serverCityText
        }
        return cell
    }

    return nil
}
	
	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let myCustomView = ServerRowView()
        return myCustomView
    }

func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
    ServerViewController.persistedSortDescriptors = tableView.sortDescriptors

    switch serverListMode {
    case .locations:
        let citiesAsMutableArray = NSMutableArray(array: originalTableData)
        citiesAsMutableArray.sort(using: tableView.sortDescriptors)
        presentedTableData = citiesAsMutableArray as! [City]
    case .dedicatedServers:
        sortDedicatedEntries(using: tableView.sortDescriptors)
    }

    tableView.reloadData()
    self.scrollTableToVPNConfiguration()
}
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = .primaryBackground
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
    
    func statusAccountFetchDedicatedIPServersSucceeded(_ notification: Notification) {
        
    }
    
    func statusAccountFetchDedicatedIPServersFailed(_ notification: Notification) {
        guard let error = notification.object as? NSError else {
            return
        }

        debugPrint("\(#function) [fetched] - \(error.localizedDescription)")

        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("DedicatedIPServersNotFetchedTitle", comment: "Dedicated IP fetch failed title")
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.addButton(withTitle: NSLocalizedString("DedicatedIPServersNotFetchedOk", comment: "Dedicated IP fetch failed OK button"))

            if let window = self.view.window {
                alert.beginSheetModal(for: window, completionHandler: nil)
            } else {
                alert.runModal()
            }
        }
    }
}

//MARK: - VPNConfigurationStatusReporting
extension ServerViewController: VPNConfigurationStatusReporting {
    
    func statusCurrentCityDidChange(_ notification: Notification) {
        self.view.window?.close()
    }
    
    func updateConfigurationBegin(_ notification: Notification) {
        self.searchField.isEnabled = true
        self.tableView.isEnabled = false
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        self.searchField.isEnabled = true
        self.tableView.isEnabled = true
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        self.searchField.isEnabled = true
        self.tableView.isEnabled = true
    }
}

extension ServerViewController: VPNAccountStatusReporting {
    
    func statusLogoutWillBegin(_ notification: Notification) {
        self.view.window?.close()
    }
    
}
