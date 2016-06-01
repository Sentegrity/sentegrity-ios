
### Sentegrity For Good - Production User Interface

- [ ] iPad support


### Sentegrity For Good - Production Security Features
  
- [ ] Employ policies encrypted with device salt

The web service will use the device salt sent in the first upload attempt to encrypt future policy downloads. The app will then decrypt them using the store device salt.
  
- [ ] Employ encrypted memory for user password and transparent authentication keys

  https://github.com/project-imas/memory-security
  
- [ ] Use device salt to self destruct

During each startup of Core Detection a function call should then be made to a honeypot function isDeviceJailbroken(). This function should be set to perform a basic (fake but obvious) Jailbreak check, always return YES and return nil. If the function returns "NO" then we should replace the device salt in the startup file (and currently used one) with a newly generated one. This essentially operates as a mechanism to indirectly destory the entire assertion store without actually deleting the file itself. By changing the device salt (deleting it) none of the old assertions can ever be recreated again and the next time core detection runs it will produce a 0 score. The objective for any further integrity checks or self-protect should be to destory this salt. Doing so also protects user TrustFactor hashes from being brute forced offline.


