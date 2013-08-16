// Copyright 2012 Google Inc.

#import <Foundation/Foundation.h>

/**
 * An object representing a first-screen device.
 *
 * @ingroup Discovery
 */
@interface GCKDevice : NSObject <NSCopying, NSCoding>

/** The device's IPv4 address, in dot-notation. Used when making network requests. */
@property(nonatomic, copy, readonly) NSString *ipAddress;

/**
 * The device's unique ID. This is the USN (Unique Service Name) as reported by the SSDP protocol.
 */
@property(nonatomic, copy) NSString *deviceID;

/** The device's friendly name. This is a user-assignable name such as "Living Room". */
@property(nonatomic, copy) NSString *friendlyName;

/** The device's manufacturer name. */
@property(nonatomic, copy) NSString *manufacturer;

/** The device's model name. */
@property(nonatomic, copy) NSString *modelName;

/** @cond INTERNAL */

/** The application URL for this device. */
@property(nonatomic, copy) NSURL *applicationURL;

/** @endcond */

/** An array of GCKDeviceIcon objects containing icons for the device. */
@property(nonatomic, copy) NSArray *icons;

/** Designated initializer. Constructs a new GCKDevice with the given IP address.
 *
 * @param ipAddress The device's IPv4 address, in dot-notation.
 */
- (id)initWithIPAddress:(NSString *)ipAddress;

@end
