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
- Run this command line in a Terminal window:

```
defaults write org.timac.VPNStatus AlwaysConnectedRetryDelay -int 30
```
