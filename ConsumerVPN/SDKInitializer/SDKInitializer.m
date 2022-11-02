//
//  SDKInitializer.m
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

@import VPNKit;
@import VPNV3APIAdapter;

#import "AppConstants.h"
#import "SDKInitializer.h"

@implementation SDKInitializer

#pragma mark - Init 

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param configName The VPN configuration name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
+ (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
													  apiKey:(NSString *)apiKey
												   andSuffix:(NSString *)suffix {

	NSString *bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	
	// The directory the application uses to store the Core Data store file.
	// This code uses a directory named <brandName> in the user's Application Support directory.
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																   inDomains:NSUserDomainMask] lastObject];
	
	appSupportURL = [appSupportURL URLByAppendingPathComponent:bundleID];
	
	NSURL *coreDataURL = [appSupportURL URLByAppendingPathComponent:@"DataStore.sqlite"];

	NSDictionary *apiOptions = @{
		kV3ApiKey: apiKey,
		kV3CoreDataURL: coreDataURL,
		kV3ServiceNameKey: @"ConsumerVPN",
	};

	V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiOptions];

	NSDictionary *connectionOptions = @{
		kVPNManagerUsernameExtensionKey: suffix,
		kVPNManagerBrandNameKey: brandName,
        kVPNManagerConfigurationNameKey: configName,
		kIKEv2KeychainServiceName: apiAdapter.passwordServiceName
	};

	NEVPNManagerAdapter *connectionAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];;

	// Initialize the API Manager
	NSDictionary *apiManagerOptions = @{
		kBundleNameKey: bundleID,
		kVPNDefaultProtocolKey: [NSNumber numberWithInteger:VPNProtocolIKEv2],
		kCityPOPHostname: @"wlvpn.com",
		kBundleNameKey: brandName,
	};

	VPNAPIManager *apiManager = [[VPNAPIManager alloc] initWithAPIAdapter:apiAdapter
														connectionAdapter:connectionAdapter
															   andOptions:apiManagerOptions];

	return apiManager;
}

@end
