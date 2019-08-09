//
//  CityDisplayModel.swift
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/16/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

import Foundation

class CellDisplayModel {
    
    //MARK: - Properties 
    
    var city : City
    var flagImage : NSImage
    var cityDisplayName : String
    var serverInformationSubtitle : String
    var averageServerLoadSubtitle : String
    var selected = false
    var server : Server?

    //MARK: - Init
    
    init(city : City) {
        
        self.city = city
        flagImage = self.city.country!.flagImage
        cityDisplayName = "\(city.name!), \(city.country!.countryID!)"
        serverInformationSubtitle = ""
        averageServerLoadSubtitle = ""
        
        if let servers = self.city.servers {
            let serverCount = String.localizedStringWithFormat(NSLocalizedString("%d server(s)", comment: "Indicates server count singular or plural"), servers.count)
            serverInformationSubtitle = "\(serverCount)"
            averageServerLoadSubtitle = "\(computeAverageServerLoad(servers: Array(servers)))% load"
        }
    }
    
    init (server : Server) {
        city = server.city!
        self.server = server
        flagImage = city.country!.flagImage
        cityDisplayName = "\(city.country!.name!), \(city.country!.countryID!)"
        serverInformationSubtitle = ""
        averageServerLoadSubtitle = ""
    }
    
    /// Helper method to compute the average capacity accross
    /// all the servers.
    fileprivate func computeAverageServerLoad(servers : [Server]) -> Int {
        
        var totalCapacity : Int = 0
        var averageCapacity : Int = 0
        
        for server in servers {
             totalCapacity += server.capacity!.intValue
        }
        
        averageCapacity = totalCapacity / servers.count
        
        return averageCapacity
    }
}
