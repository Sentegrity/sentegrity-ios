### Sentegrity Application TODO List

- [ ] startup file (runHistory) object upload 

We need to a crude mechanism to upload the startup file to our server after every X number of core detection runs or time has passed since last upload. This will likely involve a couple additional policy settings and data points to be recorded in the startup file.

For example, the following two policy settings would be required:
"statusUploadRunFrequency": 5 (runs)
"statusUploadTimeFrequency": 7 (days) 

The following new data point should be recorded in the startup file:
"runCountAtLastUpload": 231 (runCount when last upload was done)
"dateTimeOfLastUpload": timestamp (timestamp during last upload was done)

"statusUploadRunFrequency" would be the policy setting that indicates after how many runs the runHistory objects should be uploaded. "statusUploadTimeFrequency" would indicate after how many weeks it should upload. After Core Detection completes and the startup file is updated, we would check the current "runCount" (in startup file) compared to "runCountAtLastUpload". If this exceed "statusUploadRunFrequency" then we perform upload. If this requirement is meet then we continue to check the current time against "dateTimeOfLastUpload" stored in the startup file and see if the difference exceeds the number of days outlined in "statusUploadTimeFrequency". If it does then we upload. The checking of time frequency if the run frequency is meet is to prevent a situation where Sentegrity is not used often and we would not get many uploads. Therefore, we want to ensure that we get at least one upload every week. 

Once the current runHistoryObjects are uplaoded we can delete them from the startup file.
  
### Core Detection TODO List

### TrustFactor TODO List

- [ ] create new BLE connected TrustFactor

Currently we have trustfactors for classic Bluetooth and scanning BLE. There is a third class of devices that we have yet to capture. These are currently connected BLE devices. Connected BLE devices do not show up in scan. This is true for devices like the apple watch. Currently Sentegrity cannot detect a connected Apple Watch. I think it makes sense to afford more weight to Bluetooth devices that are known to be paired, such as the existing classic Bluetooth and a new "connectedBLE" rule. We can then lower the weight associated with identifying unpaired devices through the Bluetooth Scanning BLE run. 

We need to create a new TrustFactor called "blePaired" which should follow the same mechanism as the other BLE rules. You will need to create a new policy section for the TrustFactor but this can be done by simply copy/pasting the BLE scanning rule and changing the identifier. You will then need to add the data capture in the activity dispatcher, add a dataset in TrustFactor_DataSet and finally create the new TrustFactor implementation under TrustFactor_Dispatch_Bluetooth.

See the following reference for how to retreive connected BLE devices, its fully supported by Apple APIs: https://developer.apple.com/library/ios/documentation/CoreBluetooth/Reference/CBCentralManager_Class/

I beleive a call like this will do the trick: CBCentralManager retrieveConnectedPeripherals


### Good Integration Pilot TODO list

- [ ] Create screens

See email about TAF storyboard 

### Future Good Integration Production TODO list
  
- [ ] Employ encrypted memory for user password and transparent authentication keys

  https://github.com/project-imas/memory-security
  
- [ ] Use device salt to self destruct

During each startup of Core Detection a function call should then be made to a honeypot function isDeviceJailbroken(). This function should be set to perform a basic (fake but obvious) Jailbreak check, always return YES and return nil. If the function returns "NO" then we should replace the device salt in the startup file (and currently used one) with a newly generated one. This essentially operates as a mechanism to indirectly destory the entire assertion store without actually deleting the file itself. By changing the device salt (deleting it) none of the old assertions can ever be recreated again and the next time core detection runs it will produce a 0 score. The objective for any further integrity checks or self-protect should be to destory this salt. Doing so also protects user TrustFactor hashes from being brute forced offline.

- [ ] Create new "State" TrustFactor

The purpose of this TrustFactor is to simply identify what is happening on the device at the point of Sentegrity running. We can likely put this TrustFactor inside TrustFactor_Dispatch_Activity. I already created a helper class (Sentegrity_TrustFactor_Dataset_StatusBar) that provides this information in a dictionary. You can access this inside the TrustFactor by calling the "getStatusBar" function inside Sentegrity_TrustFactor_Dataset. WiFi and Celluar TrustFactors currently do this for signal strengths, take a look at those to get an idea (I think this is the "approximate locatio" rule Obviously, you don't need all the values from this helper for this particular TrustFactor. The following can be used, and any others that make sense. Feel free to add to these if you want to explore any additional data that can be identified: "isNavigating", "isOnCall", "isTethering", "isBackingUp", and "isAirplaneMode". If none of these states are present we can simply return "none" or something of that nature. You will need to add a new TrustFactor to the policy, you can probably add it somewhere in the middle of the policy. The policy is executed sequentially, therefore we usually reserve Bluetooth, location, etc and other slow TrustFactors for the end of the policy. This provides maximum amount of time for the activity dispatch datasets to start collecting data prior to that data being needed by the TrustFactor. 

