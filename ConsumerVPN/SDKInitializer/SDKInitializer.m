//
//  SDKInitializer.m
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

@import VPNKit;
@import VPNV3APIAdapter;
@import VPKWireGuardAdapter;

#import "AppConstants.h"
#import "SDKInitializer.h"

@implementation SDKInitializer

+ (NSString *)baseURL {
    return @"https://api.wlvpn.com/v3/";
}

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
    
    NSDictionary *apiAdapterOptions = @{
        kV3BaseUrlKey:          [self baseURL],
        kV3AlternateUrlsKey:    @[],
        kV3ApiKey:              apiKey,
        kV3CoreDataURL:         coreDataURL,
        kV3ServiceNameKey:      brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSDictionary *connectionOptions = @{
        kVPNManagerUsernameExtensionKey: suffix,
        kVPNManagerBrandNameKey: brandName,
        kVPNManagerConfigurationNameKey: configName,
        kIKEv2KeychainServiceName: apiAdapter.passwordServiceName,
        kVPNSharedSecretKey: @"wlvpn",
    };
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:2];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInteger:VPNProtocolIKEv2];

    // Order is important

	NEVPNManagerAdapter *neVPNAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];;
    
    [adapters addObject:neVPNAdapter];
    
    if (@available(macOS 10.13, *)) {
        WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName bundleIdentifier:bundleID uuid:[apiAdapter getOption:kV3UUIDKey] apiKey:apiKey];
        [adapters addObject:wireGuardAdapter];
        
        defaultProtocol = [NSNumber numberWithInteger:VPNProtocolWireGuard];
    }
    
	// Initialize the API Manager
	NSDictionary *apiManagerOptions = @{
		kBundleNameKey: bundleID,
		kVPNDefaultProtocolKey: defaultProtocol,
		kCityPOPHostname: @"wlvpn.com",
		kBundleNameKey: brandName,
	};
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc]
                                 initWithAPIAdapter:apiAdapter
                                 connectionAdapters:adapters
                                 andOptions:apiManagerOptions];

	return apiManager;
}

+ (WireGuardAdapter *)createWireGuardAdapterWithBrandName:(NSString *)brandName
                                         bundleIdentifier:(NSString *)bundleIdentifier
                                                     uuid:(NSString *)uuid
                                                   apiKey:(NSString *)apiKey {
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];

    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid;
    wgConfig.extensionName = [NSString stringWithFormat:@"%@.network-extension", bundleIdentifier];
    wgConfig.apiURL = [NSString stringWithFormat:@"%@wireguard", [self baseURL]];
    wgConfig.apiKey = apiKey;
    wgConfig.backupURL = @[];

    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}

@end
