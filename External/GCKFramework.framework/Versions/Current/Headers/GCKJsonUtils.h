// Copyright 2012 Google Inc.

#import <Foundation/Foundation.h>

/**
 * Utility methods for working with JSON data.
 *
 * @ingroup Utilities
 */
@interface GCKJsonUtils : NSObject

/**
 * Parses a JSON string into an object.
 *
 * @param json The JSON string to parse.
 * @return The root object of the object hierarchy that represents the data (either an NSArray or
 * an NSDictionary), or <code>nil</code> if the parsing failed.
 */
+ (id)parseJson:(NSString *)json;

/**
 * Writes an object hierarchy of data to a JSON string.
 *
 * @param object The root object of the object hierarchy to encode. This must be either an NSArray
 * or an NSDictionary.
 * @return An NSString containing the JSON encoding, or <code>nil</code> if the data could not be
 * encoded.
 */
+ (NSString *)writeJson:(id)object;

/**
 * Tests if two JSON strings are equivalent. This does a deep comparison of the JSON data in the
 * two strings, but ignores any differences in the ordering of keys within a JSON object. For
 * example, <code>{ "width":64, "height":32 }</code> is considered to be equivalent to
 * <code>{ "height":32, "width":64 }</code>.
 */
+ (BOOL)isJsonString:(NSString *)actual
        equivalentTo:(NSString *)expected;

@end
