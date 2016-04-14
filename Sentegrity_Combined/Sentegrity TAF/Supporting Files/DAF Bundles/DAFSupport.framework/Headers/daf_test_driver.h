/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_TEST_DRIVER_H
#define DAF_TEST_DRIVER_H

/* Example (software) implementations of different classes of device
 * for testing purposes. 
 */
#include "DigitalAuthenticationFramework.h"

class DATestDriver
{
public:
    
    enum ImplementationType
    {
        Unset = 0,
        Class0,
        Class1Public,
        Class1Secure,
        Class1SecureKeyGen,
        Class2PublicEncrypt,
        Class2PublicOneWay,
        Class2SecureEncrypt,
        Class2SecureOneWay,
        Pkcs11Class2,
        Pkcs11Class3,
        Pkcs11Class4
    };
    
    // Call this function before initialize() to select implementation
    static void setImplementationType(ImplementationType type);
    
    // In a real implementation, this may call up some UI
    static void getAuthToken(DAData &tkn);
    
    // These are equivalent to the regular DADriver calls
    static void initialize();
    
    static DADevice *getDevice();
    
    static DAError &getLastError();
};

#endif
