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
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
+ (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
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
	};

	NSDictionary *connectionOptions = @{
		kVPNManagerUsernameExtensionKey: suffix,
		kVPNManagerBrandNameKey: brandName,
	};

	id <VPNAPIAdapterProtocol> productAdapter = [[V3APIAdapter alloc] initWithOptions:apiOptions];
	id <VPNConnectionAdapterProtocol> connectionAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];;

	// Initialize the API Manager
	NSDictionary *apiManagerOptions = @{
		kBundleNameKey: bundleID,
		kVPNServiceNameKey: brandName,
		kBrandNameKey: brandName,
		kVPNDefaultProtocolKey: [NSNumber numberWithInteger:VPNProtocolIKEv2],
		kCityPOPHostname: @"wlvpn.com",
	};

	VPNAPIManager *apiManager = [[VPNAPIManager alloc] initWithAPIAdapter:productAdapter
														connectionAdapter:connectionAdapter
															   andOptions:apiManagerOptions];

	return apiManager;
}

@end
