/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 */

#pragma once

#import <Foundation/Foundation.h>

/** NSOutputStream subclass for writing files in the secure store.
 * This class is a subclass of the Foundation <tt>NSOutputStream</tt> class
 * for use when writing files in the secure store (see  \reflink GDFileManager\endlink).
 * 
 * The class supports the <tt>write</tt> and <tt>hasSpaceAvailable</tt> member
 * functions of <tt>NSOutputStream</tt>. The subclass doesn't support
 * <tt>scheduleInRunLoop</tt> nor <tt>removeFromRunLoop</tt> which are not
 * required as the file data can be written immediately.
 *
 * This documentation includes only additional operations provided by
 * GDCWriteStream that are not part of <tt>NSOutputStream</tt>.
 *
 * The functions in this class utilize <tt>NSError</tt> in a conventional way. Function calls accept as a parameter the location of a pointer to <tt>NSError</tt>, i.e. a pointer to a pointer, with type <tt>NSError**</tt>. The location may be <tt>nil</tt>. If the location isn't <tt>nil</tt>, and an error occurs, the Good Dynamics Runtime overwrites the pointer at the specified location with the address of an object that describes the error that occurred.
 * 
 * @see <a
 *    HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSOutputStream_Class"
 *    target="_blank"
 * >NSOutputStream class reference in the iOS Developer Library on apple.com</a>
 * @see \ref GDCReadStream
 */
@interface GDCWriteStream : NSOutputStream <NSStreamDelegate> {
    @private
    void* m_internalWriter;
    int m_streamError;
    NSStreamStatus m_streamStatus;
    id <NSStreamDelegate> m_delegate;
}

/** Constructor that opens or creates a file in the secure store,
 *  for writing.
 * Call this constructor to create a new file in the secure store, or to open an
 * existing file for writing. Files in the secure store are encrypted on the
 * device; data written to the stream returned by this function will be
 * encrypted, transparently to the application.
 *
 * If a file already exists at the specified path, the file can either be
 * appended to, or overwritten.
 *
 * Note. This constructor is used by the
 * \reflink GDFileManager::getWriteStream:appendmode:error: getWriteStream:\endlink
 * function in the  \reflink GDFileManager\endlink class.
 *
 * @param filePath <tt>NSString</tt> containing the path, within the secure
 *                 store, of the file to be opened.
 *
 * @param shouldAppend Selects the action to take if a file already exists at
 *                     the path: <tt>YES</tt> to append to the file, or
 *                     <tt>NO</tt> to overwrite.
 *
 * @param error For returning an <tt>NSError</tt> object if an error occurs. If <tt>nil</tt>, no object will be returned.
 *
 * @return <tt>nil</tt> if the file could not be opened.
 */
- (id) initWithFile:(NSString*)filePath append:(BOOL) shouldAppend error:(NSError**)error;

/** Constructor that opens or creates a file in the secure store,
 *  for writing.
 * Calling this constructor is equivalent to calling the
 * \ref initWithFile:append:error: constructor, above, and specifying <tt>nil</tt> as the
 * <tt>error</tt> parameter.
 */
- (id) initWithFile:(NSString*)filePath append:(BOOL) shouldAppend;

/** Get the last error.
 * Call this function to get the last error associated with the open stream.
 *
 * @return Reference to an <tt>NSError</tt> object that describes the error.
 * @see \ref gdfilesystemerrordomain 
 */
- (NSError*) streamError;

@end
