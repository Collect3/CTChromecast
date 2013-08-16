//
//  Base64.h
//
//  Version 1.1
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/Base64
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import <Foundation/Foundation.h>
/**
 * A category on NSData that adds methods for Base-64 encoding and decoding.
 *
 * @ingroup Utilities
 */
@interface NSData (GCKBase64)

/**
 * Constructs an NSData from a Base-64 encoded string.
 *
 * @param string The string to decode.
 * @return An NSData containing the decoded data.
 */
+ (NSData *)gck_dataWithBase64EncodedString:(NSString *)string;

/**
 * Base-64 encodes the NSData with no line-wrapping.
 *
 * @return An NSString containing the encoded data.
 */
- (NSString *)gck_base64EncodedString;

/**
 * Base-64 encodes the NSData with line-wrapping.
 *
 * @param width The maximum width of a line, in characters.
 * @return An NString containing the encoded data.
 */
- (NSString *)gck_base64EncodedStringWithWrapWidth:(NSUInteger)width;

@end

/**
 * A category on NSString that adds methods for Base-64 encoding and decoding.
 *
 * @ingroup Utilities
 */
@interface NSString (GCKBase64)

/**
 * Constructs an NSString containing the Base-64 encoding of another string.
 *
 * @param string The string to Base-64 encode.
 * @return An NSString containing the encoded data.
 */
+ (NSString *)gck_stringWithBase64EncodedString:(NSString *)string;

/**
 * Base-64 encodes the string with no line-wrapping.
 *
 * @return An NSString containing the encoded data.
 */
- (NSString *)gck_base64EncodedString;

/**
 * Base-64 encodes the NSString with line-wrapping.
 *
 * @param wrapWidth The maximum width of a line, in characters.
 * @return An NSString containing the encoded data.
 */
- (NSString *)gck_base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;

/**
 * Base 64-decodes the NSString to an NSString.
 *
 * @return An NSString containing the decoded data.
 */
- (NSString *)gck_base64DecodedString;

/**
 * Base-64 decodes the NSString to an NSData.
 *
 * @return An NSData containing the decoded data.
 */
- (NSData *)gck_base64DecodedData;

@end
