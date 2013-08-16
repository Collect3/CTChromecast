// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

/**
 * Metadata about a first-screen application.
 *
 * @ingroup Sessions
 */
@interface GCKApplicationMetadata : NSObject<NSCopying>

/** The application's name. */
@property(nonatomic, copy, readonly) NSString *name;

/** The application's human-readable title. */
@property(nonatomic, copy, readonly) NSString *title;

/** The application's publisher. */
@property(nonatomic, copy, readonly) NSString *publisher;

/** The application's version. */
@property(nonatomic, copy, readonly) NSString *version;

/** The launch information for the corresponding second-screen application. */
@property(nonatomic, copy, readonly) NSString *secondScreenLaunchInfo;

/** The URL of the application's icon. */
@property(nonatomic, copy, readonly) NSURL *iconURL;

/**
 * Designated initializer. Constructs a new ApplicationMetadata object with the supplied property
 * values.
 */
- (id)initWithName:(NSString *)name
                     title:(NSString *)title
                 publisher:(NSString *)publisher
                   version:(NSString *)version
    secondScreenLaunchInfo:(NSString *)launchInfo
                   iconURL:(NSURL *)iconURL
        supportedProtocols:(NSArray *)supportedProtocols;

/**
 * Tests if this application supports the protocol with the given namespace.
 *
 * @param protocol The protocol namespace.
 */
- (BOOL)doesSupportProtocol:(NSString *)protocol;

@end
