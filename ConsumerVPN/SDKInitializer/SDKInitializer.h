//
//  SDKInitializer.h
//  WhiteLabelVPN
//
//  Created by Zeph Cohen on 9/30/16.
//  Copyright © 2016 WLVPN. All rights reserved.
//

@import Foundation;
@import VPNKit;

@interface SDKInitializer : NSObject

@property (nonatomic, assign) BOOL usingOpenVPN;

/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager readyh to use
 */
+ (nonnull VPNAPIManager*) initializeAPIManagerWithBrandName:(NSString *_Nonnull)brandName
													  apiKey:(NSString *_Nonnull)apiKey
												   andSuffix:(NSString *_Nonnull)suffix;

@end
