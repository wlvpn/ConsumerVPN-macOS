#! /bin/sh

#   File:       Uninstall.sh
#
#   Contains:   Script to remove everything installed by the sample.
#
#   Written by: DTS
#
#   Copyright:  Copyright (c) 2012 Apple Inc. All Rights Reserved.
#
#   Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
#               ("Apple") in consideration of your agreement to the following terms, and your
#               use, installation, modification or redistribution of this Apple software
#               constitutes acceptance of these terms.  If you do not agree with these terms,
#               please do not use, install, modify or redistribute this Apple software.
#
#               In consideration of your agreement to abide by the following terms, and subject
#               to these terms, Apple grants you a personal, non-exclusive license, under Apple's
#               copyrights in this original Apple software (the "Apple Software"), to use,
#               reproduce, modify and redistribute the Apple Software, with or without
#               modifications, in source and/or binary forms; provided that if you redistribute
#               the Apple Software in its entirety and without modifications, you must retain
#               this notice and the following text and disclaimers in all such redistributions of
#               the Apple Software.  Neither the name, trademarks, service marks or logos of
#               Apple Computer, Inc. may be used to endorse or promote products derived from the
#               Apple Software without specific prior written permission from Apple.  Except as
#               expressly stated in this notice, no other rights or licenses, express or implied,
#               are granted by Apple herein, including but not limited to any patent rights that
#               may be infringed by your derivative works or by other works in which the Apple
#               Software may be incorporated.
#
#               The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
#               WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
#               WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#               PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
#               COMBINATION WITH YOUR PRODUCTS.
#
#               IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
#               CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
#               GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#               ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
#               OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
#               (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
#               ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This uninstalls everything installed by the sample.  It's useful when testing to ensure that 
# you start from scratch.
#
# This script must be run with root privileges. In the app, it is executed through
# AppleScript's "do shell script ... with administrator privileges" flow.

LAUNCH_DAEMON_PLIST="/Library/LaunchDaemons/com.consumervpn.osx.vpnhelper.plist"
HELPER_TOOL="/Library/PrivilegedHelperTools/com.consumervpn.osx.vpnhelper"
APP_SUPPORT_DIR="/Library/Application Support/com.consumervpn.osx.vpnhelper"

# Unload the launch daemon if it exists
if [ -f "${LAUNCH_DAEMON_PLIST}" ]; then
    launchctl unload "${LAUNCH_DAEMON_PLIST}" 2>/dev/null || true
fi

# Remove launch daemon plist
rm -f "${LAUNCH_DAEMON_PLIST}"

# Remove helper tool
rm -f "${HELPER_TOOL}"

# Remove application support directory
rm -rf "${APP_SUPPORT_DIR}"

exit 0
