// Copyright 2013 Google Inc.

/**
 * The error domain for GCKApplicationSession errors.
 */
extern NSString * const kGCKApplicationSessionErrorDomain;

#import "GCKError.h"

/**
 * Error code indicating that an application could not be started.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeFailedToStartApplication;

/**
 * Error code indicating that an application's information could not be queried.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeFailedToQueryApplication;

/**
 * Error code indicating that an application unexpectedly stopped.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeApplicationStopped;

/**
 * Error code indicating that an application channel could not be created.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeFailedToCreateChannel;

/**
 * Error code indicating that an application channel could not be connected.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeFailedToConnectChannel;

/**
 * Error code indicating that an application channel was unexpectedly disconnected.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeChannelDisconnected;

/**
 * Error code indicating that an application could not be stopped.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeFailedToStopApplication;

/**
 * Error code indicating an unknown error condition.
 *
 * @memberof GCKApplicationSessionError
 */
extern const int kGCKApplicationSessionErrorCodeUnknownError;

/**
 * A subclass of GCKError for GCKApplicationSession errors.
 *
 * @ingroup Sessions
 */
@interface GCKApplicationSessionError : GCKError

/** @cond INTERNAL */

- (id)initWithCode:(NSInteger)code causedByError:(NSError *)error;

+ (NSString *)localizedDescriptionForCode:(NSInteger)code;

/** @endcond */

@end
