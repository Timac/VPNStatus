# VPNStatus
VPNStatus, a replacement for macOS builtin VPN Status

# Blog post
[https://blog.timac.org/2018/0719-vpnstatus/](https://blog.timac.org/2018/0719-vpnstatus/)

# Description
VPNStatus, an application that replicates some functionalities of macOS built-in VPN status menu:

- list the VPN services and their status
- connect to a VPN service
- disconnect from a VPN service
- possibility to auto connect to a VPN service if the application is running

# Retry Delay

VPNStatus tries to reconnect to the VPN every 120s by default. You can change this value using a secret preference. To change the retry delay to 30s:

- Quit VPNStatus
- Run this command in a Terminal window:

```
defaults write org.timac.VPNStatus AlwaysConnectedRetryDelay -int 30
```

# Ignored SSIDs

VPNStatus can optionally ignore one or more SSIDs, such that services are **not** autoconnected when the current Wi-Fi SSID is on the ignored list.

To set the list of ignored SSIDs:

- Quit VPNStatus
- Run this command in a Terminal window:

```
defaults write org.timac.VPNStatus IgnoredSSIDs "OneSSID,SecondSSID,Third SSID"
```

With the above example, if the current Wi-Fi network SSID is `OneSSID`, `SecondSSID`, or `Third SSID`, then the VPN will **not** autoconnect.

If the Wi-Fi network SSID is, say, `FourthSSID`, the VPN service **will** autoconnect, because it is not on the list.

Note that SSIDs **are** case-sensitive.
