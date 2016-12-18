//
// \file DAFTestAdapter.h
//
// \brief Shim from C++ daf_testlib to Objective-C
//
// DAF self-tests are written in C++, and the caller
// of these needs to supply an implementation of
// (C++) class DATestInterface to run them. This code
// is a shim from C++ to an equivalent Obj-C class
// (DAFTestRunner) to allow easy integration of
// DAF self-tests into iOS applications.
//
//  Created by Ian Harvey on 29/01/2016.
//  Copyright © 2016 Blackberry Inc. All rights reserved.
//

#ifndef DAFTestRunner_h
#define DAFTestRunner_h

#include "daf_testlib.h"

/** \brief DAF self-test 'runner' class
  *
  * This is the Objective-C equivalent of C++ DATestInterface.
  * iOS app writers will, typically, subclass this and use the
  * callback methods to drive the UI.
  */
@interface DAFTestRunner : NSObject
- (void)cbStartTest:(NSInteger)testId withName:(const char *)testName;
///< Called at the start of each test.

- (void)cbComment:(const char *)text;
///< Reports a general progress message.

- (void)cbError:(const char *)text withDAError:(const char *)error;
///< Reports a failure during a test; there may be more than one of
///  these between cbStartTest and cbEndTest. If the failure was
///  an error from a DigitalAuthenticationFramework.h call, the
///  error parameter is set to the text value of this error.

- (void)cbEndTest;
///< Called at the end of each test.
@end

/** \brief Concrete class implementing DATestInterface
 *
 */

class DAFTestAdapter : public DATestInterface
{
public:
    DAFTestAdapter(DAFTestRunner *parent, DADevice *dev, DASession *sess);
    /**< \brief Constructor
     *
     * \param parent - Objective-C object which will receive callbacks during tests
     * \param dev - value to supply as return value from getDevice()
     * \param sess - value to supply as return value from getSession()
     *
     * Note that ownership of 'sess' is not passed to this object; this class
     * doesn't try to delete (or otherwise destroy) 'sess' in its destructor.
     */
    
    virtual DADevice *getDevice();
    virtual DASession *getSession();
    virtual void startTest( DATestId testId, const char *testName );
    virtual void comment( const char *text );
    virtual void error( const char *text, DAError *daError = NULL );
    virtual void endTest();
   
private:
    DAFTestRunner *m_parent;
    DADevice *m_device;
    DASession *m_session;
};

#endif /* DAFTestRunner_h */
