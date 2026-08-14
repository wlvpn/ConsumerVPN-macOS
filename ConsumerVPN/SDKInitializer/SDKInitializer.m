//
//  SDKInitializer.m
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

@import Foundation;
@import VPNKit;
@import VPNV3APIAdapter;

#import "AppConstants.h"
#import "SDKInitializer.h"
#import "ConsumerVPN-Swift.h"

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
                                                      suffix:(NSString *)suffix {
    
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
    
    // Create adapters
    
    NEVPNManagerAdapter *neVPNAdapter = [self createNEVPNManagerAdapter:brandName
                                                           extensionKey:suffix
                                                                service:apiAdapter.passwordServiceName];
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:4];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInteger:VPNProtocolIKEv2];
    
    // Order is important
    if (@available(macOS 10.13, *)) {
        WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName bundleIdentifier:bundleID apiKey:apiKey];
        if (wireGuardAdapter) {
            [adapters addObject: wireGuardAdapter];
            defaultProtocol = [NSNumber numberWithInteger:VPNProtocolWireGuard];
        }
    }
    
    [adapters addObject: neVPNAdapter];
                                                          
    OpenVPNAdapter* openVPNAdapter =  [self createOpenVPNAdapterAdapterWithBrandName:brandName bundleIdentifier:bundleID suffix:suffix];
    
    if (openVPNAdapter) {
        [adapters addObject:openVPNAdapter];
        defaultProtocol = [NSNumber numberWithInteger:VPNProtocolOpenVPN];
    }
    
	// Initialize the API Manager
	NSDictionary *apiManagerOptions = @{
		kBundleNameKey:         bundleID,
		kVPNDefaultProtocolKey: defaultProtocol,
		kCityPOPHostname:       @"wlvpn.com",
		kBundleNameKey:         brandName
	};
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc]
                                 initWithAPIAdapter:apiAdapter
                                 connectionAdapters:adapters
                                 andOptions:apiManagerOptions];
    
    // Ensures that connections are not killed off when the app dies during an active connection
    [apiManager.vpnConfiguration setStayConnectedOnQuit:YES];
    
    
	return apiManager;
}

//MARK: - NEVPNManager Adapter

- (OpenVPNAdapter *)createOpenVPNAdapterAdapterWithBrandName:(NSString *)brandName
                                            bundleIdentifier:(NSString *)bundleIdentifier
                                                      suffix:(NSString *)suffix {
    
    OpenVPNAdapterConfiguration *configuration =
    [[OpenVPNAdapterConfiguration alloc] initWithBrandName:brandName
                                         configurationName:brandName
                                                 useAPIKey:NO
                                        useSystemExtension:YES
                                                    apiURL:@"https://api.wlvpn.com/v3/"
                                                 backupURL:@[]
                                                    apiKey:@""
                                             extensionName:[bundleIdentifier stringByAppendingString:@".openvpnextension"]
                                                  reseller: suffix];
    
    
    if ([configuration validate] != OpenVPNAdapterConfigurationErrorNone) {
        NSLog(@"OpenVPN Configuration not valid");
        return nil;
    }
    
    return [[OpenVPNAdapter alloc] initWithConfiguration:configuration];
}

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
                                                   apiKey:(NSString *)apiKey {
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];

    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.extensionName = [NSString stringWithFormat:@"%@.network-extension", bundleIdentifier];
    wgConfig.apiKey = apiKey;
    
    // Quantum Resistence
    wgConfig.quantumResistanceEnabled = NO;
    wgConfig.allowDisconnectOnQuantumResistanceFailure = YES;
    
#if TARGET_OS_OSX
    wgConfig.clientManagesSystemExtension = NO;
#endif
    
    if ([wgConfig validate] != WireGuardAdapterConfigurationErrorNone) {
        NSLog(@"Wireguard Configuration not valid");
        return nil;
    }

    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}

@end
