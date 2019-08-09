//
//  FilterOptionModel.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/27/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

//MARK: - Sort Option

enum SortOption: Int {
    case  city, country, serverCount, ping
}

//MARK: - Ping Range

struct PingRange {
    
    let min: UInt
    let max: UInt
    let displayText: String
    let option : Int
    
    /// Defines the options for Any PingRange between 0 and Int.max
    static let anyRange = PingRange(min: 0, max: UInt.max, displayText: NSLocalizedString("PingAny", comment: "Any"), option : 0)
    
    /// Defines the options for <50 PingRange between 0 and 49
    static let lessThanFifty = PingRange(min:0, max: 49, displayText: NSLocalizedString("PingLessThanFifty", comment: "Less Than Fifty"), option : 1)
    
    /// Defines the options for 50-100 PingRange between 50 and 100
    static let betweenFiftyAndOneHundred = PingRange(min: 50, max: 100, displayText: NSLocalizedString("PingFiftyThroughHundred", comment: "Fifty Through One Hundred"), option: 2)
    
    /// Defines the options for 100-200 PingRange between 100 and 200
    static let betweenOneHundredAndTwoHundred = PingRange(min: 100, max: 200, displayText: NSLocalizedString("PingHundredThroughTwoHundred", comment: "One Hundred Through Two Hundred"), option : 3)
    
    /// Defines the options for >200 PingRange between 201 and Int.max
    static let greaterThanTwoHundred = PingRange(min: 201, max: UInt.max, displayText: NSLocalizedString("PingGreaterThanTwoHundred", comment: "Greater Than Two Hundred"), option : 4)
}

//MARK: - Filter Option Model

class FilterOptionModel {
    
    internal let pingRange : PingRange?
    internal let sortOption : SortOption?
    
    internal var isAppliedAsFilter = false 
    
    //MARK: - Init
    
    init (pingRange : PingRange?, sortOption : SortOption?) {
        self.pingRange = pingRange
        self.sortOption = sortOption
    }
}

// MARK: - CustomStringConvertible

extension SortOption: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .city:
            return "City"
        case .country:
            return "Country"
        case .serverCount:
            return "Server"
        case .ping:
            return "Ping"
        }
    }
}

// MARK: - Equatable

extension PingRange: Equatable {
    static func ==(left: PingRange, right: PingRange) -> Bool {
        return left.min == right.min &&
            left.max == right.max &&
            left.displayText == right.displayText
    }
    
    static func !=(left: PingRange, right: PingRange) -> Bool {
        return !(left == right)
    }
}

