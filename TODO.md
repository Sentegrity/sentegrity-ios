### Sentegrity Application TODO List


### Good Integration Pilot TODO list

- [ ] Policy download

Prior to core detection running, initiate an async HTTPs download of a new policy file located on app1.sentegrity.com/services/policyupdate. Once downloaded the policy checksum should be checked (simple sha1). Implement the following SSL certificate pinning mechanism: https://github.com/project-imas/ssl-conservatory
  
### Transparent Authentication TODO list

- [ ] Modify default.store (assertion store) to store transparent authentication keys and new object

Need to create a new object and file similiar to "storedTrustFactorObjects" that gets mapped out of default.store at the same time the other objects are. This object can be called "transparentAuthenticationObject". We also need to make some changes to the default.store, currently the assertion store contains two JSON objects "appID" and "storedTrustFactorObjects" we should add an object called "storedTransparentKeys". The code to make updates to these objects (like we do for storedTrustFactorObjects will need to be created as well). This is probably a lot of copy/paste.

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

We'll need to map this to the created object. These objects will be searched during protectMode to determine if there is a match from the key derived from the computationResults.transparentAuthenticationTrustFactors combined output. Jason will take care of this last part. It's not clear exactly when we will update the store with new transparent objects, TBD as somewhere in protectMode when transparent authentication is attempted. 

  
### Core Detection TODO List

- [ ] Generate and use device salt

During first run after installation, generate random device salt and store it in the startup file in raw format. This salt should then be used for all assertion generation by appending it to the raw TrustFactor data prior to hashing (assertion creation), this takes place in dispatcher (I beleive) when the TrustFactor returns. I'm not sure what the best method for determining first run is, but reinstallation should be considered "first run". I.e., keychain may not be the best method, perhaps writing a dummy file?


### TrustFactor TODO List

### Protect Mode TODO List

### Future Good Integration Production TODO list
  
- [ ] Employ encrypted memory for user password and transparent authentication keys

  https://github.com/project-imas/memory-security
  
- [ ] Use device salt to self destruct

During each startup of Core Detection a function call should then be made to a honeypot function isDeviceJailbroken(). This function should be set to perform a basic (fake but obvious) Jailbreak check, always return YES and return nil. If the function returns "NO" then we should replace the device salt in the startup file (and currently used one) with a newly generated one. This essentially operates as a mechanism to indirectly destory the entire assertion store without actually deleting the file itself. By changing the device salt (deleting it) none of the old assertions can ever be recreated again and the next time core detection runs it will produce a 0 score. The objective for any further integrity checks or self-protect should be to destory this salt. Doing so also protects user TrustFactor hashes from being brute forced offline.

