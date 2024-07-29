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
@import VPNV3APIAdapter;
@import VPNHelperAdapter;

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
 * @param priviligedHelper PrivilgedHelperTool for OpenVPN.
 *
 * @return An initialized VPNAPIManager ready to use
 */
- (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
													  apiKey:(NSString *)apiKey
                                                      suffix:(NSString *)suffix
                                            priviligedHelper:(VPNPrivilegedHelperManager *)privilegedHelperManager {
    
	NSString *bundleID = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	
	// The directory the application uses to store the Core Data store file.
	// This code uses a directory named <brandName> in the user's Application Support directory.
	NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																   inDomains:NSUserDomainMask] lastObject];
	
	appSupportURL = [appSupportURL URLByAppendingPathComponent:bundleID];
	
	NSURL *coreDataURL = [appSupportURL URLByAppendingPathComponent:@"DataStore.sqlite"];
    
    NSDictionary *apiAdapterOptions = @{
        kV3ApiKey:              apiKey,
        kV3CoreDataURL:         coreDataURL,
        kV3ServiceNameKey:      brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSBundle *openVPNBundle = [NSBundle bundleForClass:[VPNOpenVPNConnectionAdapter class]];
    NSString *certificatePath = [openVPNBundle pathForResource:@"wlvpn" ofType:@"crt"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    
    NSDictionary *connectionOptions = @{
        kVPNOpenVPNCertificatePath:         certificatePath,
        kVPNManagerUsernameExtensionKey:    suffix,
        kVPNManagerBrandNameKey:            brandName,
        kVPNManagerConfigurationNameKey:    configName,
        kVPNSharedSecretKey:                @"vpn",
        kVPNHelperDisableIPSec:             [NSNumber numberWithBool:YES],
        kVPNApplicationSupportDirectoryKey: applicationSupportDirectory,
        kIKEv2KeychainServiceName:          apiAdapter.passwordServiceName,
    };
    
    // Create adapters
    VPNOpenVPNConnectionAdapter *openVpnConnectionAdapter = [[VPNOpenVPNConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    VPNLegacyConnectionAdapter *legacyConnectionAdapter = [[VPNLegacyConnectionAdapter alloc] initWithOptions:connectionOptions andPrivilegedHelperManager:privilegedHelperManager];
    
    NEVPNManagerAdapter *neVPNAdapter = [self createNEVPNManagerAdapter:brandName
                                                           extensionKey:suffix
                                                                service:apiAdapter.passwordServiceName];
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:4];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInteger:VPNProtocolIKEv2];
    
    // Order is important
    if (@available(macOS 10.13, *)) {
        WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName bundleIdentifier:bundleID uuid:[apiAdapter getOption:kV3UUIDKey] apiKey:apiKey];
        [adapters addObject: wireGuardAdapter];
        defaultProtocol = [NSNumber numberWithInteger:VPNProtocolWireGuard];
    }
    
    [adapters addObject: openVpnConnectionAdapter];
    
    [adapters addObject: neVPNAdapter];
    
    [adapters addObject: legacyConnectionAdapter];
    
	// Initialize the API Manager
	NSDictionary *apiManagerOptions = @{
		kBundleNameKey:         bundleID,
		kVPNDefaultProtocolKey: defaultProtocol,
		kCityPOPHostname:       @"wlvpn.com",
		kBundleNameKey:         brandName,
	};
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc]
                                 initWithAPIAdapter:apiAdapter
                                 connectionAdapters:adapters
                                 andOptions:apiManagerOptions];

	return apiManager;
}

//MARK: - NEVPNManager Adapter

-(NEVPNManagerAdapter *)createNEVPNManagerAdapter:(NSString *)brandName
                                     extensionKey:(NSString *)extensionKey
                                          service:(NSString *)keychainService {
    
    NSDictionary * connectionOptions = @{kVPNManagerUsernameExtensionKey: extensionKey,
                                     kVPNManagerBrandNameKey: brandName,
                                              kIKEv2Hostname: @"vpn.wlvpn.com",
                                      kIKEv2RemoteIdentifier: @"vpn.wlvpn.com",
                                         kVPNSharedSecretKey: @"vpn",
                                   kIKEv2KeychainServiceName: keychainService};
    
    return [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
}

- (WireGuardAdapter *)createWireGuardAdapterWithBrandName:(NSString *)brandName
                                         bundleIdentifier:(NSString *)bundleIdentifier
                                                     uuid:(NSString *)uuid
                                                   apiKey:(NSString *)apiKey {
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];

    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid;
    wgConfig.extensionName = [NSString stringWithFormat:@"%@.network-extension", bundleIdentifier];
    wgConfig.apiKey = apiKey;

    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}

@end
