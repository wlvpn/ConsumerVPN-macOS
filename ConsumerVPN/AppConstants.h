//
//  AppConstants.h
//  VPNKit
//
//  Created by Kevin Hallmark on 3/23/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

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

#pragma mark - OpenVPN Constants

typedef NS_ENUM(NSInteger, OpenVPNProtocol) {
    udp,
    tcp
};

static NSString *kOpenVPNPort = @"kOpenVPNPort";
static NSString *kOpenVPNScrambleEnabled = @"kOpenVPNScrambleEnabled";
static NSString *kVPNIPV6LeakProtection = @"kVPNIPV6LeakProtection";
