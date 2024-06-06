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

static NSString *WLHideOnAppLaunch = @"HideOnStartup";
static NSString *WLLaunchOnSystemStartup = @"LaunchOnSystemStartup";

static NSString *WLDoNotAutomaticallyConnect = @"WLDoNotAutomaticallyConnect";
static NSString *WLConnectToLastConnectedServer = @"ConnectToLastConnectedServer";
static NSString *WLConnectToFastestServer = @"ConnectToFastestServer";
static NSString *WLConnectToFastestServerInCountry = @"ConnectToFastestServerInCountry";
static NSString *WLSelectedCountry = @"SelectedCountry";

#pragma mark - OnDemand Preference Notification

static NSString *WLOnDemandOptionChangedNotification = @"WLOnDemandOptionChangedNotification";

#pragma mark - LoginViewController Field Selection
static NSString *WLLoginFieldSelectionNotification = @"WLLoginFieldSelectionNotification";

#pragma mark - OpenVPN Helper Service Keys

static NSString *IPVOpenVPNInitialSetup   = @"IPVOpenVPNInitialSetup";
