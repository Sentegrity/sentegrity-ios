### Sentegrity Application TODO List
  
### Transparent Authentication TODO list

- [ ] Modify default.store (assertion store) to store transparent authentication keys and new object

Need to create a new object and file similiar to "storedTrustFactorObjects" that gets mapped out of default.store at the same time the other objects are (by th parser that parses the assertion store). This object can be called "transparentAuthenticationObject". In order for this to work, we also need to make some changes to the default.store, currently the assertion store contains two JSON objects "appID" and "storedTrustFactorObjects" we should add an object called "storedTransparentKeys" that contains an array of objects each with a "hitCount", "created", "decayMetric", etc.. value. The code to make updates to these objects (like we do for storedTrustFactorObjects) will need to be created as well, but its all the same that we already have. Take a look at how the assertion store is currently handled and you will see its not hard to add a new object/class to be mapped out of the store. You will need to add some dummy data to the assertion store (dummy "storedTransprentKeys" objects) for testing purposes. This is probably a lot of copy/paste.

which can look like the below:

"storedTransparentKeys" : [
{
  "hitCount": 1
  "created" : 1455490264
  "decayMetric" : 0.07
  "hash" : [blob]
  "encryptedPassword" : [blob]
  "iv" : [blob]
},
{
  "hitCount": 3
  "created" : 1455490264
  "decayMetric" : 0.07
  "hash" : [blob]
  "encryptedPassword" : [blob]
  "iv" : [blob]
},
[etc..]

]

We'll need to map this to the created object. These objects will be searched during protectMode to determine if there is a match from the key derived from the computationResults.transparentAuthenticationTrustFactors combined output. Jason will take care of this last part. It's not clear exactly when we will update the store with new transparent objects, TBD as somewhere in protectMode when transparent authentication is attempted. This depends on the Good Integration, but regardless - this first part of modifying the assertion store to contain "transparentAuthenticationObject"

  
### Core Detection TODO List

- [ ] Generate and use device salt

During first run after installation, generate random device salt and store it in the startup file in raw format. Currently just a dummy salt is stored in the startup file. Nick  recently completed the startup file, you should be ableto see the code somewhere. This salt should then be used for all assertion generation by appending it to the raw TrustFactor data prior to hashing (assertion creation). This can probably be done inside each TrustFactorOutputObject's setAssertionObjectsFromOutput which is called inside Sentegrity_TrustFactor_Dispatcher.

I'm not sure what the best method for determining first run is, but reinstallation should be considered "first run". I.e., keychain may not be the best method, perhaps writing a dummy file?


### TrustFactor TODO List

- [ ] Create new "State" TrustFactor

The purpose of this TrustFactor is to simply identify what is happening on the device at the point of Sentegrity running. We can likely put this TrustFactor inside TrustFactor_Dispatch_Activity. I already created a helper class (Sentegrity_TrustFactor_Dataset_StatusBar) that provides this information in a dictionary. You can access this inside the TrustFactor by calling the "getStatusBar" function inside Sentegrity_TrustFactor_Dataset. WiFi and Celluar TrustFactors currently do this for signal strengths, take a look at those to get an idea (I think this is the "approximate locatio" rule Obviously, you don't need all the values from this helper for this particular TrustFactor. The following can be used, and any others that make sense. Feel free to add to these if you want to explore any additional data that can be identified: "isNavigating", "isOnCall", "isTethering", "isBackingUp", and "isAirplaneMode". If none of these states are present we can simply return "none" or something of that nature. You will need to add a new TrustFactor to the policy, you can probably add it somewhere in the middle of the policy. The policy is executed sequentially, therefore we usually reserve Bluetooth, location, etc and other slow TrustFactors for the end of the policy. This provides maximum amount of time for the activity dispatch datasets to start collecting data prior to that data being needed by the TrustFactor. 

### Good Integration Pilot TODO list

- [ ] Policy download

Prior to core detection running, initiate an async HTTPs download of a new policy file located on app1.sentegrity.com/services/policyupdate. Once downloaded the policy checksum should be checked (simple sha1). Implement the following SSL certificate pinning mechanism: https://github.com/project-imas/ssl-conservatory

- [ ] startup file upload download

We need to a crude mechanism to upload the startup file to our server after every X number of core detection runs or time has passed since last upload. This will likely involve a couple additional policy settings and data points to be recorded in the startup file.

For example, the following two policy settings would be required:
"statusUploadRunFrequency": 5 (runs)
"statusUploadTimeFrequency": 7 (days) 

The following new data point should be recorded in the startup file:
"runCountAtLastUpload": 231 (runCount when last upload was done)
"dateTimeOfLastUpload": timestamp (timestamp during last upload was done)

"statusUploadRunFrequency" would be the policy setting that indicates after how many runs the startup file should be uploaded. "statusUploadTimeFrequency" would indicate after how many weeks it should upload. After Core Detection completes and the startup file is updated, we would check the current "runCount" (in startup file) compared to "runCountAtLastUpload". If this exceed "statusUploadRunFrequency" then we perform upload. If this requirement is meet then we continue to check the current time against "dateTimeOfLastUpload" stored in the startup file and see if the difference exceeds the number of days outlined in "statusUploadTimeFrequency". If it does then we upload. The checking of time frequency if the run frequency is meet is to prevent a situation where Sentegrity is not used often and we would not get many uploads. Therefore, we want to ensure that we get at least one upload every week. 

### Future Good Integration Production TODO list
  
- [ ] Employ encrypted memory for user password and transparent authentication keys

  https://github.com/project-imas/memory-security
  
- [ ] Use device salt to self destruct

During each startup of Core Detection a function call should then be made to a honeypot function isDeviceJailbroken(). This function should be set to perform a basic (fake but obvious) Jailbreak check, always return YES and return nil. If the function returns "NO" then we should replace the device salt in the startup file (and currently used one) with a newly generated one. This essentially operates as a mechanism to indirectly destory the entire assertion store without actually deleting the file itself. By changing the device salt (deleting it) none of the old assertions can ever be recreated again and the next time core detection runs it will produce a 0 score. The objective for any further integrity checks or self-protect should be to destory this salt. Doing so also protects user TrustFactor hashes from being brute forced offline.

