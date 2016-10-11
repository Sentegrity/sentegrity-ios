/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 */

#pragma once

#import <Foundation/Foundation.h>

/** NSInputStream subclass for reading files that are in the secure store.
 * This class is a subclass of the Foundation <tt>NSInputStream</tt> class
 * for use when reading files in the secure store (see  \reflink GDFileManager\endlink).
 * 
 * This class supports the <tt>read</tt> and <tt>hasBytesAvailable</tt>
 * member functions of <tt>NSInputStream</tt>. This class doesn't support
 * <tt>getBuffer</tt>, which will always return <tt>NO</tt>. This class also
 * doesn't support <tt>scheduleInRunLoop</tt> nor <tt>removeFromRunLoop</tt>
 * which are not required as the file data can be read immediately.
 *
 * This documentation includes only additional operations provided by
 * GDCReadStream that are not part of <tt>NSInputStream</tt>.
 *
 * \par Notes on use of the read function
 * The <tt>read</tt> function in this class will work best when the supplied
 * buffer is a multiple of 16 bytes in length. The <tt>maxLength</tt> parameter
 * should reflect the size of the buffer, and not the amount of data remaining
 * to be read from the file. To read a particular number of bytes, <em>B</em>,
 * supply a buffer whose size is <em>B </em>rounded up to the next multiple of
 * 16.\n
 * The return value of the <tt>read</tt> function must always be checked by the
 * application. It mustn't be assumed that a file has been completely read into
 * a buffer, even if the buffer is large enough to accomodate the whole file.
 *
 * The functions in this class utilize <tt>NSError</tt> in a conventional way. Function calls accept as a parameter the location of a pointer to <tt>NSError</tt>, i.e. a pointer to a pointer, with type <tt>NSError**</tt>. The location may be <tt>nil</tt>. If the location isn't <tt>nil</tt>, and an error occurs, the Good Dynamics Runtime overwrites the pointer at the specified location with the address of an object that describes the error that occurred.
 * 
 * @see <a
 *     HREF="https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSInputStream_Class"
 *     target="_blank"
 * >NSInputStream class reference in the iOS Developer Library on apple.com</a>
 * @see \ref GDCWriteStream
 */
@interface GDCReadStream : NSInputStream <NSStreamDelegate> {
    @private
    void* m_internalReader;
    int m_streamError;
    unsigned int m_offset;
    NSStreamStatus m_streamStatus;
    id <NSStreamDelegate> m_delegate;
}

/** Constructor that opens a file in the secure store, for reading.
 * Call this constructor to open a file in the secure store for reading. Files
 * in the secure store are encrypted on the device; this function provides
 * access to decrypted data.
 *
 * Note. This constructor is used by the
 * \reflink GDFileManager::getReadStream:error: getReadStream:\endlink
 * function in the  \reflink GDFileManager\endlink class.
 *
 * @param filePath <tt>NSString</tt> containing the path, within the secure
 *                 store, of the file to be opened.
 *
 * @param error For returning an <tt>NSError</tt> object if an error occurs. If <tt>nil</tt>, no object will be returned.
 *
 * @return <tt>nil</tt> if the file could not be opened.
 */
- (id) initWithFile:(NSString*)filePath error:(NSError**)error;

/** Constructor that opens a file in the secure store, for reading.
 * Calling this constructor is equivalent to calling the
 * \ref initWithFile:error: constructor, above, and specifying <tt>nil</tt> as the
 * <tt>error</tt> parameter.
 */
- (id) initWithFile:(NSString*)filePath;

/** Seek in an open file in the secure file system.
 * Call this function to move the file pointer to a specific offset
 * from the start of the stream.
 *
 * @param offset Required offset, expressed as a number of bytes
 * from the start of the file. Zero means the start of the file.
 *
 * @return <tt>YES</tt> if the file pointer was moved to the required
 * offset.
 * @return <tt>NO</tt> Otherwise.
 */
- (BOOL)seekToFileOffset:(unsigned long long)offset;


/** Get the last error.
 * Call this function to get the last error associated with the open stream.
 *
 * @return Reference to an <tt>NSError</tt> object that describes the error.
 * @see \ref gdfilesystemerrordomain 
 */
- (NSError*) streamError;

@end
