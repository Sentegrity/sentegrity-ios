/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

/** \file daf_testlib.h
 *
 *  \brief Library of tests for DAF implementation
 *
 * This library is supplied with the DAF SDK to assist developing an
 * implementation. The test library is supplied a DASession object (and
 * an associated DADevice), and will run tests on the keys made available
 * through that session. Test status is reported back to the caller as
 * tests proceed, via the DATestInterface interface.
 */

#ifndef DAF_TESTLIB_H
#define DAF_TESTLIB_H

#include "DigitalAuthenticationFramework.h"

/**
 *  \brief Test identification
 *
 *  All tests are given integer identification numbers.
 *  This allows all tests, or a restricted range of tests, to be 
 *  run (see DATestLib::runTests()).
 *
 */
typedef unsigned int DATestId;

const DATestId ALL_TESTS_FIRST = 1000; ///< Lowest test number for all tests

const DATestId GENERAL_TESTS_FIRST = 1000; ///< First general DAF implementation test
const DATestId GENERAL_TESTS_LAST  = 1999; ///< Last general test

const DATestId SMIME_TESTS_FIRST = 2000; ///< First test for SMIME-capable keys 
const DATestId SMIME_TESTS_LAST  = 2999; ///< Last SMIME key test

const DATestId TLS_TESTS_FIRST = 3000; ///< First tests for TLS client-auth key
const DATestId TLS_TESTS_LAST  = 3999; ///< Last TLS key test

const DATestId ALL_TESTS_LAST  = 9999; ///< Highest test number for all tests

/**
  * \brief Interface between test library and test environment.
  *
  * The caller of the test library implements this interface; the
  * test library will call its methods to get information, and to
  * report the results of each test as it runs.
  */
class DATestInterface
{
public:
  /**
    * \brief Called to get a device used for the tests.
    */
  virtual DADevice *getDevice() = 0;

  /**
    * \brief Called to get a session to use for the tests.
    *
    * Typically, the session will be created by the test harness
    * before the test run begins, and the same session will be used
    * for a number of tests.
    */
  virtual DASession *getSession() = 0;

  /**
    * \brief Called before a test begins. 
    *
    * \param testId   Numeric identifier of the test
    * \param testName Brief test name summary
    */
    
  virtual void startTest( DATestId testId, const char *testName ) = 0;

  /**
    * \brief Called to record a comment, for debugging.
    *
    * Implementation of this is recommended, but optional.
    *
    * \param text    One-line comment text
    */
  virtual void comment( const char *text ) { };
  
  /**
    * \brief Reports a test error.
    *
    * \param text    Text description of the error
    * \param daError If not NULL, points to error from DAF call.
    *
    * Note that daError is typically taken from the getLastError()
    * call on the current DASession. You should not rely on the 
    * pointer remaining valid after this call has returned, unless you
    * can be sure this is safe for all DAError objects returned by the
    * implementation under test.
    */
  virtual void error( const char *text, DAError *daError = NULL ) = 0;

  /**
    * \brief Called at the end of each test. 
    *
    * Marks the end of a test sequence started by startTest(). 
    * Typically can be used to record results, and tear down anything
    * set up by the startTest() method.
    */
    
  virtual void endTest() = 0;
};

/**
  * \brief Run a sequence of tests
  *
  */

class DATestLib
{
public:
    /**
      * \brief Run one or more tests
      *
      * \param wrapper Pointer to callbacks to use for test progress indication.
      * \param first   Indicates start of range of tests to run.
      * \param last    Indicates end of range of tests to run.
      *
      * Tests are run if their test identifier is in the range first .. last, inclusive.
      */
    static void runTests(DATestInterface &wrapper, DATestId first, DATestId last);

};

#endif // DAF_TESTLIB_H
