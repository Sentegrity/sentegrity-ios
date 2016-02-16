### Sentegrity Application TODO List


### Core Detection TODO List

- [ ] Create a “startup” file to store temporary info by modifying the assertion store class to be universal

This should be a JSON file like the assertion store. I think we just need to create a  “startup” class for the mapper and then make the existing assertion store functionality a bit more flexible in that it can accept other files, etc. We need to have the file mapped into an object just like the policy is with the ability to “set” it as well. This is where we will store things such as “lastOSVersion”, crypto salts, and a few other persistent storage attributes we need for bootstrapping the app. 

We can do this by modify the existing I/O built into the assertion store class/mechanism and make that more of a helper for writing any I/O to a JSON file and reading it back into an object. Centralizing the I/O into one helper will help when we have to port all I/O to Good's special wrappers that encrypt data.

- [ ] OS Updated Check

Add new TF attribute “wipeOnUpdate” need to be added to each TF in the policy and all supporting TF object map classes. During baseline analysis if the iOS version is determined to have been new/upgraded (check it once at start? and compare based on startup file “lastOSVersion”?) then Baseline Analysis should check every TF for this attribute. If the attribute in policy for the current working TrustFactor is set to True then we delete the stored assertion object for this TF and create a new/blank one (this happens automatically by the assertion store object if it can’t find a matching store TF object). This can likely occur within baseline analysis where, as it is already, if it does not find a matching TF object in the store it will create it. The purpose of this is to ensure that we erase stored assertions for TrustFactors (mainly system TrustFactors) whose datapoints may change when an OS upgrade happens and could cause a false positive. For example, the file system monitoring rule should have its assertion store deleted such that it goes back into learning mode if a new OS is installed. This ensures that a change in file size isn't detected as malicious when the OS is merely updated.


- [ ] Identify why TFs hang when celluar or WiFi connection is lost or very low

UPDATE: Nick added timers to each TF, console now logs how long each TF takes. Solving this or narrowing down what is causing the problem is now just a matter of reproducing the problem while debugging the app. 

UPDATE: I noticed it happens inside the "Netstat" TrustFactors, this appears to have something to do with the Netstat API calls. Can someone see if it is something inside one of the TFs in TrustFactor_Dispatch_Netstat or where the dataset is created inside Sentegrity_TrustFactor_Dataset_Netstat

We discussed addressing this once the app is integrated into Good by killing the thread that Core Detection runs on if it hangs. Obviously, it would be nice to figure out the root cause. I have a feeling it has something to do w/ one of the APIs and TrustFactor dataset class related to WiFi or celluar. Sometimes putting the phone into airplane will cause Core Detection to change from hanging to done. This issue is not addressed by the Core Detection timeout as that timeout is internal to Core Detection to identify hardware (resource) constraints that are causing delays, not hangs. 

### TrustFactor TODO List

- [ ] Bluetooth classic does not work unless you re-launch the entire application

This is actually a big problem we've had for a while that needs to get fixed or users will certaintly notice something wrong.This is the TF that checks if a classic Bluetooth device is paired (unlikes the BLE 4.0 scanner TF). This is the only way to get paired device information and why we use the private API. It works great if you cold launch the app with a paired Bluetooth device connected, it gets a notification and can retrieve the MAC address for the connected device. For whatever reason, whenever you restart Core Detection (using the refresh button the dashboard), this TF never gets any notification about a connected device and therefore does not find it. Only when you close the app and re-open it will it work. You can see what I mean by breaking inside Sentegrity_Activity_Dispatcher inside - (void)receivedBluetoothNotification:(MDBluetoothNotification)bluetoothNotification where the notification comes from the private framework. It will fire fine on cold boot of the app but you will never see a notification again after that. I tried playing the register/unregister observer but it didn't seem to make any difference.


### Protect Mode TODO List


