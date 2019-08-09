//
//  AppConstants.h
//  VPNKit
//
//  Created by Kevin Hallmark on 3/23/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

#pragma mark - Server List Constants 

static CGFloat   kWLServerListRowHeight = 57;
static NSString *kWLServerListCityTableCellViewIdentifier = @"CityCell";
static NSString *kWLServerListServerTableCellViewIdentifier = @"ServerCell";

#pragma mark - General Preferences Constants 

static NSString *WLHideOnSystemStartup = @"HideOnStartup";

static NSString *WLDoNotAutomaticallyConnect = @"WLDoNotAutomaticallyConnect";
static NSString *WLConnectToLastConnectedServer = @"ConnectToLastConnectedServer";
static NSString *WLConnectToFastestServer = @"ConnectToFastestServer";
static NSString *WLConnectToFastestServerInCountry = @"ConnectToFastestServerInCountry";
static NSString *WLSelectedCountry = @"SelectedCountry";

#pragma mark - OnDemand Preference Notification

static NSString *WLOnDemandOptionChangedNotification = @"WLOnDemandOptionChangedNotification";
