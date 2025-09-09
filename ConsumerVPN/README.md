# ConsumerVPN for macOS

![Swift](https://img.shields.io/badge/swift-5.0-orange)
![Platform macOS](https://img.shields.io/badge/platform-macOS-lightgrey)
![Supports macOS](https://img.shields.io/badge/macOS-universal--binary-blue)
![Supports ARM](https://img.shields.io/badge/ARM-arm64-informational)
![Supports Intel](https://img.shields.io/badge/Intel-x86_64-informational)
![XCFramework Included](https://img.shields.io/badge/XCFramework-included-success)
[![VPNKit 7.1.1](https://img.shields.io/badge/VPNKit-7.1.1-brightgreen)](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/README.md)

ConsumerVPN is a ready-to-brand application built with Swift and the WLVPN VPN SDK. It provides a foundation for your own VPN app and serves as a complete guide for integrating the WLVPN VPN SDK.(VPNKit).

## Table of Contents

1. [Prerequisites](#1-prerequisites)
    - i.[System Requirements](#system-requirements)
    - ii.[Getting Started](#getting-started)
    - iii. [Tools Required](#tools-required) 
2. [Setup Instructions](#2-setup-instructions)
    - i. [Download the Project](#i-download-the-project)
    - ii [Initialize Theme Submodule](#ii-initialize-theme-submodule)
3. [Adding the WLVPN SDK (VPNKit)](#3-adding-the-wlvpn-sdk-vpnkit)
4. [Info.plist](#4-infoplist)
5. [Setting Up Framework Search Paths](#5-setting-up-framework-search-paths)
6. [Setting Up Permissions ](#6-setting-up-permissions-entitlements-and-capabilities)
7. [VPNKit Initializer](#7-vpnkit-initializer)
8. [WireGuard Integration](#8-wireguard-integration)
9. [OpenVPN Integration](#9-openvpn-integration)
10. [Key Files](#10-key-files)
11. [Customizing Your App's Look](#11-customizing-your-apps-look-theme-integration)
12. [Support](#12-support)

## 1. Prerequisites

### System Requirements

- macOS  10.15 +

### Getting Started

To build this app, you’ll need below account-specific details and the VPNKit SDK folder, both provided by your WLVPN account manager. For assistance, contact **support@wlvpn.com**.

- Account Name  
- Auth Suffix  
- API Key  
- openVPNToolBundleId

### Tools Required

- [Xcode](https://developer.apple.com/xcode/) version 13 or newer   

## 2. Setup Instructions

### i. Download the Project

1.  Open the **Terminal** app on your Mac.
2.  Copy and paste the following lines into the Terminal, pressing **Enter** after each line:

    ```bash
    git clone https://github.com/wlvpn/ConsumerVPN-macOS
    cd consumervpn-macos
    ```
    *What this does:*
    * `git clone ...` downloads the entire ConsumerVPN project from the internet to your computer.
    * `cd consumervpn-macos` moves you into the newly downloaded project folder in Terminal.

### ii. Initialize Theme Submodule

This project uses a "Theme" submodule to control the look and feel of your app (colors, fonts, etc.). You need to get these theme files ready.

1.  In the same Terminal window, copy and paste these lines and press **Enter** after each:

    ```bash
    git submodule init
    git submodule update
    ```
    *What this does:* These commands download the necessary theme files into your project.

## 3. Adding the WLVPN SDK (VPNKit)

For macOS app, you will need both the `.xcframework` files found inside the `VPNKit/XCFramework` subfolder, and the `VPNHelperAdapter.framework` located within the `VPNKit/macOS` subfolder.

### How to Add Them to Your Project:

1.  **Open your Xcode project:** Navigate to your macOS project folder and double-click your `.xcodeproj` or `.xcworkspace` file.
2.  **Drag and Drop Essential Files:**
    * Locate the `VPNKit` folder you received from your WLVPN account manager.
    * **Drag** all the `.xcframework` files from the `VPNKit/XCFramework` subfolder directly into the folder named **`SDK`** (or a similar grouping folder) visible in your Xcode Project Navigator (the left-hand panel in Xcode).
    * **Drag** the `VPNHelperAdapter.framework` file from the `VPNKit/macOS` subfolder directly into the same **`SDK`** (or similar) folder in your Xcode Project Navigator.
    * When a prompt appears for each drag-and-drop operation, ensure you check **"Copy items if needed"** and select your app target. This ensures the files are copied into your project.
3.  **Configure in Xcode:**
    * In Xcode, select your main app project in the Project Navigator (the very top item in the left panel).
    * Go to the **"General"** tab.
    * Scroll down to the section called **"Frameworks, Libraries, and Embedded Content."**
    * You should now see all the `.xcframework` files and `VPNHelperAdapter.framework` listed here. If any are missing, click the **"+" button** and add them manually.
    * For each of the listed frameworks, adjust the "Embed" setting as shown in the table below (assuming they should be "Embed & Sign" or "Do Not Embed" based on your project's needs, but for most frameworks that are not extensions, "Embed & Sign" is typical).

    | Framework or Extension                              | Embed Setting          |    
    |-----------------------------------------------------|------------------------|
    | com.wlvpn.macos.consumervpn.network-extension       | Embed Without Signing  |
    | NetworkExtension.framework                          | Do Not Embed           |
    | Security.framework                                  | Do Not Embed           |
    | ServiceManagement.framework                         | Do Not Embed           |
    | VPKWireGuardAdapter.xcframework                     | Embed & Sign           |
    | VPKWireGuardExtension.xcframework                   | Embed & Sign           |
    | VPNHelperAdapter.framework                          | Embed & Sign           |
    | VPNKit.xcframework                                  | Embed & Sign           |
    | VPNV3APIAdapter.xcframework                         | Embed & Sign           |

## 4. Info.plist

The **`Info.plist`** file is like an ID card for your app. It holds important settings and information. This project uses a shared `Info.plist` file located in the `Theme` directory to maintain configuration consistency across brands or environments.

    • CFBundleIdentifier – Typically set to $(PRODUCT_BUNDLE_IDENTIFIER) to ensure bundle uniqueness per target.
    • CFBundleShortVersionString and CFBundleVersion – Read from $(MARKETING_VERSION) and $(CURRENT_PROJECT_VERSION) to define the app’s version and build number.
    • LSMinimumSystemVersion – Uses $(MACOSX_DEPLOYMENT_TARGET) to specify the minimum macOS version supported by the app.
    • NSAppTransportSecurity – Enables arbitrary loads and sets exceptions (e.g., wlvpn.com) to allow insecure HTTP requests or legacy TLS, primarily for compatibility during development.
    • SMPrivilegedExecutables – Grants OpenVPN Command Line Helper tools elevated privileges using secure code-signing requirements; required for VPN extensions or privileged daemons.
    • CFBundlePackageType – Typically set to APPL to indicate this is a standard macOS application bundle.
    • NSPrincipalClass – Declares NSApplication as the app’s entry point.
    • NSMainNibFile – Points to the main interface file (e.g., MainMenu) used in traditional AppKit apps.
    • ITSAppUsesNonExemptEncryption – Set to false to declare that the app does not use non-exemptn encryption, satisfying App Store compliance.
    • LSApplicationCategoryType – Categorizes the app under macOS App Store listings, such as public.app-category.utilities.

## 5. Setting Up Framework Search Paths

You need to tell Xcode where to find the important framework files you've added.

1.  In Xcode, select your **app target** (not the project).
2.  Go to the **"Build Settings"** tab.
3.  Search for **"Framework Search Paths."**
4.  Double-click next to "Framework Search Paths" and click the **"+"** button.
5.  Add the following paths to both the **Debug** and **Release** configurations:

    | Path                                       | Recursion       |
    |--------------------------------------------|-----------------|
    | $(inherited)                               | non-recursive   |
    | $(PROJECT_DIR)/SDK                         | recursive       |
    | $(SRCROOT)/SDK                             | non-recursive   |

     *What this means:*  This tells Xcode to look for necessary framework files within the `SDK` folder that you placed directly inside your **macOS project's root directory**.

## 6. Setting Up Permissions (Entitlements and Capabilities)

Your app needs specific permissions (called **Entitlements** and **Capabilities**) to use certain macOS features, like connecting to a VPN. You must configure these in Xcode and ensure they correspond with your Apple Developer account settings and provisioning profiles.

1.  In Xcode, select your **Target**.
2.  Go to the **"Signing & Capabilities"** tab.
3.  Add and configure the following capabilities by clicking the **"+"** button next to "Capabilities" if they are not already present:

Configure the following capabilities in **Xcode > Target > Signing and Capabilities**. Ensure that all entitlements are declared in your provisioning profiles and Apple Developer portal for your macOS application.

| Capability                                 | Value / Details                                             |
| :----------------------------------------- | :---------------------------------------------------------- |
| App Transport Security Exception Domains   | `wlvpn.com`                                                 |
| Keychain Sharing                           | `com.wlvpn.macos.consumervpn`, `com.apple.managed.vpn.shared` |
| Network Extensions                         | Packet Tunnel                                               |
| System Extension                           | Enabled                                                     |

**Important Notes:**

* All **App Groups** and **Capabilities** you set here **must also be configured in your Apple Developer account** under "Identifiers."
* The permissions in your app's `Entitlements` file must perfectly match what's set up in your provisioning profile (which you manage in your Apple Developer account).

### Entitlements Configuration

The app uses a configured `.entitlements` file to declare system permissions, app group access, and VPN capabilities. In addition to `Info.plist` keys, ensure your `ConsumerVPN.entitlements` file includes the following settings:

The ConsumerVPN macOS app defines the following system capabilities to support VPN functionality, system extension installation, and secure network communication.

```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider-systemextension</string>
</array>
<key>com.apple.developer.networking.vpn.api</key>
<array>
    <string>allow-vpn</string>
</array>
<key>com.apple.developer.system-extension.install</key>
<true/>
<key>com.apple.security.app-sandbox</key>
<false/>
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.network.server</key>
<true/>
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)<your.app.bundle.id></string>
    <string>$(AppIdentifierPrefix)com.apple.managed.vpn.shared</string>
</array>
```

File Location:

```swift
ConsumerVPN/Resources/ConsumerVPN.entitlements
```

*What this does:* These lines tell macOS exactly what your app is allowed to do, such as using network extensions for VPN, installing and managing system extensions, making network connections, and securely sharing data via Keychain access groups with its own components or other system processes.

To verify this: Check under "Signing and Capabilities > Entitlements" in Xcode for both your main app and any associated extension targets

## 7. VPNKit Initializer

To get the VPN features working in your app, you'll need a class that handles the initial setup of `VPNKit`. In the `ConsumerVPN` example, this class is named `SDKInitializer`.

This `SDKInitializer` class (or whatever you choose to name your own initialization class) is the dedicated and organized place where you initialize VPNKit and set up all the essential information it needs to operate. Its core function is to instantiate and prepare the `VPNAPIManager` instance, which is the central component for all VPN-related operations like connecting, disconnecting, and retrieving server lists. Essentially, it sets up everything required to make secure VPN connections.

**Path:** `ConsumerVPN/SDKInitializer`

**Refer:** [Initializers](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/Initializers.md) 

## 8. WireGuard Integration

WireGuard,a modern and high-performance VPN protocol, integration on macOS is achieved through Apple's **Network Extension framework**, specifically by deploying a **Packet Tunnel Provider System Extension**.
This setup uses the `VPKWireGuardExtension.xcframework` and requires a dedicated Network Extension target in your project. Proper configuration of its `Info.plist` (including `NSSystemExtensionUsageDescription`) and specific macOS entitlements (like `com.apple.developer.networking.networkextension` for System Extensions and optional App Groups) are essential to manage secure, system-level VPN connections.

Refer: [WireGuard Integration](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/Wireguard.md)

## 9. OpenVPN Integration

OpenVPN integration on macOS is achieved through a privileged helper tool. This helper tool has a unique identifier, openVPNToolBundleId, which your main application uses to both initiate secure communication and to whitelist the helper for installation.
This architecture allows your main application to leverage a separate, elevated Command Line Tool to perform system-level VPN operations that require special permissions. It involves the VPNHelperAdapter.framework for secure communication between your app and the helper, and the vpnhelper XCFramework for the core OpenVPN logic within the helper. Secure installation and communication are primarily handled via Apple's SMJobBless mechanism and XPC services.

Refer: [OpenVPN Integration](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/OpenVPN%20Implementation.md)

## 10. Key Files

Import these in your bridging headers or module map:

```swift
@import VPNKit;
@import VPNV3APIAdapter;
@import VPNHelperAdapter;
```

## 11. Customizing Your App's Look (Theme Integration)

The **Theme** module is a [Git submodule](https://www.freecodecamp.org/news/how-to-use-git-submodules/) designed to provide a single, consistent source of truth for branding across your applications, including your **macOS app**.
This module allows you to share common branding elements like product names, brand names, URLs, and potentially color palettes and fonts, ensuring a unified look and feel without duplicating code. While general constants are directly applicable, UI-specific elements (like `UIColor` extensions or status bar styles) will require adaptation or macOS equivalents (`NSColor`) for native macOS user interfaces.
After running `git submodule update` to fetch the module, perform the following steps:
* Import shared theme resources (colors, fonts) into your macOS project.
* Link assets (images, styles) into the macOS app target.

Example:

```swift
let label = NSTextField(labelWithString: "Welcome")
label.textColor = Theme.primaryText
label.font = NSFont.systemFont(ofSize: Theme.serverListHeaderFontSize) 
```

Refer: [Theme Guide](https://github.com/wlvpn/ConsumerVPN-macOS-Theme/blob/main/Theme%20Guide.md)

## 12. Support

For technical support please contact:  
📧 **support@wlvpn.com** 
