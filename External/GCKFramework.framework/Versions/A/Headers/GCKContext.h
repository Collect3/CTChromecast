// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

/**
 * @defgroup Initialization Initialization
 * @defgroup Discovery Device discovery
 * @defgroup Sessions Application session management
 * @defgroup Messages Application message streams
 * @defgroup Utilities General-purpose utilities
 */

/**
 * The version number of this SDK.
 *
 * @memberof GCKContext
 */
extern NSString * const kGCKVersion;

/**
 * An object for maintaining global framework state.
 *
 * @ingroup Initialization
 */
@interface GCKContext : NSObject

/**
 * The user agent string that is used when making HTTP requests.
 */
@property(nonatomic, copy, readonly) NSString *userAgent;

/** Designated initializer. Constructs a new GCKContext with the given HTTP user agent string.
 *
 * @param userAgent The user agent string to use when making HTTP requests
 * This should consist of an application name, optionally followed by a slash
 * and an application version, e.g., "MyApp/1.0". Both the
 * name and version strings must contain only alphanumeric characters,
 * periods, dashes, and underscores.
 * The system details from the default user agent string will be appended
 * to this identifier automatically to form a complete user agent string.
 * If the string is invalid, an assertion will be raised.
 */
- (id)initWithUserAgent:(NSString *)userAgent;

@end
