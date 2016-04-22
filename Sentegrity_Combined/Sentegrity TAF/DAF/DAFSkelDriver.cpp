//
//  DAFSkelDriver.cpp
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//  Copyright (c) 2014 Good Technology. All rights reserved.
//

#include "DAFSkelDriver.h"

#include "DAFSupport/basic_error.h"
#include "DAFSupport/basic_metadata.h"
#include "DAFSupport/basic_key.h"
#include "DAFSupport/daf_log.h"

// DASession concrete implementation ---------------------------------

class SkeletonSession : public DASession
{
public:
    
    // Constructor
    SkeletonSession( DADevice &device, DAData &authToken ):m_error(), m_metadata(m_error), m_device(device) {
        
        DAFLog(DAFLog_Debug, "DAF Skeleton: SkeletonSession() constructor");
        m_metadata.copyFrom(device.getInfo());
        
        // In real life we would connect to the device, perhaps
        // using 'authToken' passed in by the UI, and create keys
        // appropriately. In the skeleton version, we just create
        // an example key with constant value and serial number.
        static const uint8_t dummyKey[16] =
        { 0x53,0x6b,0x65,0x6c,0x44,0x75,0x6d,0x6d,0x79,0x4b,0x65,0x79,0x44,0x61,0x74,0x61 };
            
        DAData keyData = DAUtils::mkData(dummyKey, sizeof(dummyKey));
        m_theKey = new BasicReadonlyKey(m_error, keyData);
        m_theKey->setSerial("22222-33333-45678");
    }
    
    virtual ~SkeletonSession()
    {
        delete m_theKey;
        m_theKey = NULL;
    }
    
    DADevice & getDevice()
    {
        return m_device;
    }
    
    DAMetaData & getInfo()
    {
        return m_metadata;
    }
    
    DAError & getLastError()
    {
        return m_error;
    }
    
    bool isConnected()
    {
        // Placeholder: used to poll for hardware disconnection
        return true;
    }
    
    int getKeyCount()
    {
        DAFLog(DAFLog_Debug, "DAF Skeleton: SkeletonSession::getKeyCount()");
        return 1;
    }
    
    DAKey *getKey(int index)
    {
        DAFLog(DAFLog_Debug, "DAF Skeleton: SkeletonSession::getKey(%d)", index);
        if (index==0)
        {
            m_error.clear();
            return m_theKey;
        }

        m_error.setCode(DAError::KEY_NOT_FOUND);
        return NULL;
    }
    
    DAKey *getKey(const std::string &serial)
    {
        // Obvious implementation.
        // Should be replaced if getKey(int) is slow
        int i;
        for (i=0;  ;i++)
        {
            DAKey *key = getKey(i);
            if (!key)
                return NULL;
            
            std::string candidate;
            if (key->getInfo().getString(DA_SERIAL, candidate)
                && serial == candidate)
            {
                m_error.clear();
                return key;
            }
        }
    }
    
private:
    BasicError m_error;
    BasicMetaData m_metadata;
    DADevice &m_device;
    
    BasicReadonlyKey *m_theKey;
};

// DADevice concrete implementation ----------------------------------

class SkeletonDevice : public DADevice
{
public:
    SkeletonDevice():m_error(), m_metadata(m_error) {
        m_metadata.setString(DA_NAME, "DAFSkelDriver.cpp example device");
        m_metadata.setString(DA_SERIAL, "000000-11111-23456");
    }

    virtual ~SkeletonDevice()
    { }
    
    DAMetaData &getInfo()
    {
        return m_metadata;
    }
    
    DAError &getLastError()
    {
        return m_error;
    }
    
    DASession *createSession (DAData &authToken)
    {
        return new SkeletonSession(*this, authToken);
    }

private:
    BasicError m_error;
    BasicMetaData m_metadata;
};

// DADriver implementation -------------------------------------------

static BasicError s_driverError;
static SkeletonDevice *s_theDevice;

DAError& DADriver::getLastError()
{
    return s_driverError;
}

void DADriver::initialize()
{
    DAFLog(DAFLog_Debug, "DAF Skeleton: DADriver::initialize()");
    
    if (!s_theDevice)
    {
        s_theDevice = new SkeletonDevice();
        s_driverError.clear();
    }
}

DADevice *DADriver::getDevice()
{
    DAFLog(DAFLog_Debug, "DAF Skeleton: DADriver::getDevice()");
    s_driverError.setCode( s_theDevice!=NULL ? DAError::SUCCESS : DAError::NOT_PROVISIONED);
    return s_theDevice;
}

