//
//  SDKInitializer.h
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

@import Foundation;
@import VPNKit;
@import VPNHelperAdapter;

@interface SDKInitializer : NSObject

@property (nonatomic, assign) BOOL usingOpenVPN;

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
- (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *_Nonnull)brandName
                                                  configName:(NSString *_Nullable)configName
                                                      apiKey:(NSString *_Nonnull)apiKey
                                                      suffix:(NSString *_Nonnull)suffix
                                            priviligedHelper:(VPNPrivilegedHelperManager *_Nonnull)privilegedHelperManager;

@end
