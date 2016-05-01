/*
 * Good Dynamics Util to support interface to Native calls
 *
 */

var gooddynamics = {}

gooddynamics.callbacks = {};
gooddynamics.callbackId = Math.floor(Math.random() * 1234000000);
gooddynamics.callQueue = [];
gooddynamics.iFrame;
gooddynamics.inNativeCall = 0;

gooddynamics.createIframe = function() {
    console.log("Inside gooddynamics createIframe");
    
    var iframe = document.createElement("iframe");
    iframe.style.display = 'none';
    document.body.appendChild(iframe);
    return iframe;
};

gooddynamics.callGDStorage = function(method, args) {
 
    // Generate a callback ID
    var objectID = "GDStorage";
    var callID = objectID + this.callbackId++;
 
    console.log("CommandQueue: " + callID);

    var command = [callID, objectID, method, args];
    this.callQueue.push(JSON.stringify(command));
    console.log("CommandQueue: " + JSON.stringify(command));

    this.callbacks[callID] = {};

    // Check if native is accessing the queue
    if (!this.inNativeCall && this.callQueue.length == 1) {
        this.iFrame = this.iFrame || this.createIframe();
        this.iFrame.src = "good-dynamics://gdstorage";
    }
};

gooddynamics.toSDK = function() {
    
    if (!this.callQueue.length)
        return '';
    
    this.inNativeCall++
    try {
        var json = '[' + this.callQueue.join(',') + ']';
        this.callQueue.length = 0;
        return json;
    } finally {
        this.inNativeCall--;
    }
};

gooddynamics.fromSDK = function(callId, message) {
    
    var call = this.callbacks[callId];
    if (call) {
        console.log("Call message: " + message);
        delete this.callbacks[callId];
    }
};

if (typeof window.goodDynamics === "undefined") {
    window.goodDynamics = gooddynamics;
};


/*
 * GDLocalStorage to support storing key/value in secure store
 */

var gdLocalStorage = [];
gdLocalStorage.getItem = function(key) {
    console.log("Array getItem called " + key);
    
    for (var i = 0; i < this.length; i++) {
        if (this[i].Key == key)
            return this[i].Value;
    }
};

gdLocalStorage.removeItem = function(key) {
    console.log("Array removeItem called " + key);

    var args = {Key:key};
    goodDynamics.callGDStorage("removeItem", args);
    

    for (var i = 0; i < this.length; i++) {
        if (this[i].Key == key) {
            this.splice(i,1);
        }
    }
};

gdLocalStorage.loadItem = function(key, value) {
    console.log("Array loadItem called " + key);
    
    var found = false;
    for (var i = 0; i < this.length; i++) {
        if (this[i].Key == key) {
            found = true;
            this[i].Value = value;
        }
    }
    
    if (!found) {
        this.push({Key:key, Value:value});
    }
};

gdLocalStorage.setItem = function(key, value) {
    console.log("Array setItem called " + key);
    
    this.loadItem(key, value);

    var args = {Key:key, Value:value};
    goodDynamics.callGDStorage("setItem", args);
};

gdLocalStorage.key = function(position) {
    return this[position].Key;
};

gdLocalStorage.clear = function() {
    console.log("Array clear called ");
    
    if (this.length == 0)
        return;

    goodDynamics.callGDStorage("clear", {});
    this.length = 0;
    //this.splice(0, this.length);
};

if (typeof window.gdLocalStorage === "undefined") {
    window.gdLocalStorage = gdLocalStorage;
};

