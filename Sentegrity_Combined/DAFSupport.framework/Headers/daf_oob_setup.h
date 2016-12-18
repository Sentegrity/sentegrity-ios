/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

#ifndef DAF_OOB_SETUP_H
#define DAF_OOB_SETUP_H

/**
 * Some devices need specific setup steps before the test suite
 * can reasonably test them.  Such devices should provide a
 * definition of this function which performs device-specific
 * initialisation.  This call will be made by the test suite after
 * DADriver::initialize and DADriver::getDevice, but before
 * other uses of the device.
 *
 * On entry, \p dev is the device to set up, \p auth_data is
 * the contents of the DAF_AUTHDATA environment variable,
 * or empty if this is unset.
 *
 * On successful exit, \p auth_data will be the actual
 * auth data to be provided to \ref DADevice::createSession().
 *
 * Report errors to stderr, then return false.
 */
bool daf_oob_setup(DADevice *dev,
                   DAData &auth_data);

#endif
