//
//  main.m
//  VPNHelper
//
//  Created by Jyoti Gawali Katkar on 20/09/23.
//  Copyright © 2023 WLVPN. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VPNHelperService.h"

int main(int argc, const char * argv[]) {
#pragma unused(argc)
#pragma unused(argv)
    
    // We just create and start an instance of the main helper tool object and then
    // have it run the run loop forever.
    
    @autoreleasepool {
        
        VPNHelperService *m = [[VPNHelperService alloc] init];
        
        [m run];                // This never comes back...
    }
    
    return EXIT_FAILURE;        // ... so this should never be hit.
}
