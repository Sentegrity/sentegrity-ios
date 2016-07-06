
### Sentegrity For Good - Production User Interface Changes

- [ ] iPad support

Does this already exist or work? Can make sure the GUI looks OK? 


### Sentegrity For Good - Production Features Additions
  
- [x] Create new trustfactor for unencrypted wifi networks 

Now that we have the NetworkExtension/Hotspot entitlment from Apple, we need to add it as a TF. This means add it to the policy (under "system security" classification and sublcass of "WiFi"). We can just call it "unencrypted wifi". The TF will then use the NetworkExtension API and perform the following call to detect if the current connection is "secured" or not. This is all we are able to tell, I don't know that we can tell if its WPA/WEP, etc - just that it is secured.  The following is how I think this call works:

<NetworkExtension/NetworkExtension.h>
for(NEHotspotNetwork *hotspotNetwork in [NEHotspotHelper supportedNetworkInterfaces]) {
NSString *ssid = hotspotNetwork.SSID;
NSString *bssid = hotspotNetwork.BSSID;
BOOL secure = hotspotNetwork.secure;
BOOL autoJoined = hotspotNetwork.autoJoined;
double signalStrength = hotspotNetwork.signalStrength;
}

- [x] Perform a policy update right when Good activation completes (prior to first run if possible)

Currently, the bundled policy will run a few times because we don't make an attempt to do an update out of the gate. We should probably try to do an update right when the user finished creating their password. This way, we may never run the bundled policy. This is also an issue because the bundled policy gets outdated quick (as it pertains to things like OS version checks)

- [x] Move password requirements to policy instead of hardcoded

These are the values like length, requireUpper, requireComplex, requireAlpha

- [ ] Create watchdog to monitor the core detection thread that runs analysis inside Good

I've been experiencing a lot of "never extending analysis" where it just won't finish. None of our internal core detection time/expiration will work if an individual TF hangs (because it won't return). Therefore, we need some mechanism from outside of the Core Detection threat to monitor if analysis is taking longer than say 5 seconds. If this is the case then we return the default Core Detection results (look at the try/catch for core detection and how it returns dummy results that just prompt for a password)

- [ ] Upload suggestion information in addition to issues

Currently, only issues are uploaded. It's come to our realization that we also need suggestions to be uploaded as part of the JSON policy update process. This should be a small tweak.

- [x] Put routing information into a block

Similiar to netstat, the syscal used for routing information should be put into a block and called within the activity dispatcher. Look at how Sentegrity_Activity_Dispatcher.m calls its startNetstat() function that ultimatly calls the sharedDataset function for NetStat_Info getTCPConnections inside of a block.  getTCPConnections is what makes the syscall and it appears that if we call these syscalls inside a block it may prevent the hang. I'm looking to do the same with the routing dataset that also used syscalls.


### Sentegrity For Good - Production Security Features (not ready for implementation)
  
- [ ] Modify application tamper rule 

Include functionality that triggers this rule if CFNetworking fails because the certificate returned from the server did not match the pinned certificate. CFNetworking run history uploads don't happen everytime, therefore this condition cannot be checked everytime.

- [ ] Employ policies encrypted with device salt

The web service will use the device salt sent in the first upload attempt to encrypt future policy downloads. The app will then decrypt them using the stored device salt. The original policy distributed within the bundle (the policy which is used by the app momentarily, prior to first update) will remain unencrypted. After the first policy update, the web service will receive the device salt in the requeust and be able to use that to encrypt any policies that are returned in the response. The app will then write this encrypted policy to disk. We will need to make a slight change prior to policy parsing where the app decrypts it first using the device salt stored in the startup file.

- [ ] Employ encrypted memory for user password and transparent authentication keys

  https://github.com/project-imas/memory-security
  
- [ ] Use device salt to self destruct

During each startup of Core Detection a function call should then be made to a honeypot function isDeviceJailbroken(). This function should be set to perform a basic (fake but obvious) Jailbreak check, always return YES and return nil. If the function returns "NO" then we should replace the device salt in the startup file (and currently used one) with a newly generated one. This essentially operates as a mechanism to indirectly destory the entire assertion store without actually deleting the file itself. By changing the device salt (deleting it) none of the old assertions can ever be recreated again and the next time core detection runs it will produce a 0 score. The objective for any further integrity checks or self-protect should be to destory this salt. Doing so also protects user TrustFactor hashes from being brute forced offline.


