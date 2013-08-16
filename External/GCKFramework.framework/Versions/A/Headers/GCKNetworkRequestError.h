// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

#import "GCKError.h"

/**
 * The error domain for GCKNetworkRequest errors.
 */
extern NSString * const kGCKNetworkRequestErrorDomain;

/**
 * Error code indicating that the request completed successfully.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeOK;

/**
 * Error code indicating that the request failed with an I/O or network error.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeIOError;

/**
 * Error code indicating that the request timed out.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeTimeout;

/**
 * Error code indicating that the request returned an invalid response.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeInvalidResponse;

/**
 * Error code indicating that the requested object was not found.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeNotFound;

/**
 * Error code indicating that access was denied to the requested object.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeAccessDenied;

/**
 * Error code indicating that a service is busy; try again later.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeBusy;

/**
 * Error code indicating that the operation is not supported for the requested object.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeNotSupported;

/**
 * Error code indicating that the request was cancelled.
 *
 * @memberof GCKNetworkRequestError
 */
extern const int kGCKNetworkRequestErrorCodeCancelled;

/**
 * A subclass of NSError for GCKNetworkRequest errors.
 *
 * @ingroup Utilities
 */
@interface GCKNetworkRequestError : GCKError

/** @cond INTERNAL */

- (id)initWithCode:(NSInteger)code causedByError:(NSError *)error;

+ (NSString *)localizedDescriptionForCode:(NSInteger)code;

/** @endcond */

@end
