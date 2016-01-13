### Sentegrity Application TODO List

- [x] Permissions check fixes

Check permissions for location/motion until the user actually elects, right now if you close the app during first run and never make an election it never asks again. Make sure we have the ability to prompt on-demand for future updates where, for example, we suggest the user allow location or motion if a score is low.

### Core Detection TODO List

- [ ] Create “startup” file to store temporary info

This should be a JSON file like the policy/store, we can just use one “startup” class and hang the attributes off it that are parsed from the file. Lets have the file mapped into an object just like the policy with the ability to “set” it as well. This is where we will store things such as “lastOSVersion”, crypto salts, and a few other persistent storage attributes we need.

- [ ] OS Updated Check

Add new TF attribute “wipeOnUpdate” to each TF in the policy and all supporting TF object maps. During baseline analysis If the iOS version is determined to have been new/upgraded (check it once at start? and compare based on startup file “lastOSVersion”) then check every TF for this attribute. If the attribute is True then we delete the stored assertion object for this TF and create a new/blank one (this happens automatically if it can’t find a matching store TF object). This can likely occur within baseline analysis where, as it is already, if it does not find a matching TF object in the store it will create it. 


- [x] TF Updated Check

If During baseline analysis the revision number from the TF’s policy does not match the revision number in the stored TF object we need to blow the stored TF object away. This means the policy was updated the TF changed there we don’t want to use any old data. By blowing way the TF the new TF will re-learn etc.

- [ ] Add Core Detection timeout to policy

Currently this is hardcoded into the app. We should populate this value from the policy. We can add an attribute to the policy as a single key/value near the top where other values are such as UserThreshold, DeviceThreshold, etc..


- [ ] Identify why TFs hang when celluar or WiFi connection is lost or very low

We discussed addressing this once the app is integrated into Good by killing the thread that Core Detection runs on if it hangs. Obviously, it would be nice to figure out the root cause. I have a feeling it has something to do w/ one of the APIs and TrustFactor dataset class. This issue is not addressed by the Core Detection timeout as that timeout is internal to Core Detection to identify hardware (resource) constraints that are causing delays, not hangs. 

- [ ] Bluetooth classic does not work

I don't know when exactly this stopped working completely, perhaps when we stopped attaching the framework correctly and hid it from apple? But it never works for me now, seems not be able to find any devices that are paired. The dataset is always empty it seems. Can we also make it such that we can find paired devices using the refresh button as well? In the past we've always had to restart the whole app to get any data.

### Protect Mode TODO List

- [x] Modify whitelisting and popup box text in response  to a user vs. device threshold violation.

Current state:
Device threshold is always checked first:
+ If device threshold violated, ask for admin pin, we whitelist device assertions if correct (deviceTrustFactorsToWhitelist)
+ If user threshold is violated, ask for user pin, whitelist user assertions if correct (userTrustFactorsToWhitelist)

We want to change to:
+ If device threshold is violated, ask for user pin and warn “high risk device - data breach may occur, this attempt has been recorded”, whitelist user and device assertions (deviceTrustFactorsToWhitelist + userTrustFactorsToWhitelist) (*user trustfactors are whitelisted regardless of whether a user threshold was violated because it’s an opportunity to learn from the user authenticating)
+ If user thresholds violated, ask for user pin and state “Password Required”, whitelist only user assertions (userTrustFactorsToWhitelist)
