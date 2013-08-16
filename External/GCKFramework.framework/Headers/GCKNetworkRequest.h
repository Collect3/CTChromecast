// Copyright 2012 Google Inc.

#import <Foundation/Foundation.h>

#include "GCKNetworkRequestError.h"

@class GCKMimeData;

/**
 * The default timeout interval for GCKNetworkRequest%s.
 *
 * @memberof NetworkRequest
 */
extern const NSTimeInterval kGCKNetworkRequestDefaultTimeout;

/**
 * The Origin header value to use for requests to the device.
 *
 * @memberof NetworkRequest.
 */
extern NSString * const kGCKNetworkRequestHTTPOriginValue;

@class GCKNetworkRequest;

/**
 * The delegate protocol for GCKNetworkRequest.
 *
 * @ingroup Utilities
 */
@protocol GCKNetworkRequestDelegate <NSObject>

/**
 * Messaged when a request has completed successfully.
 *
 * @param request The request.
 */
- (void)networkRequestDidComplete:(GCKNetworkRequest *)request;

/**
 * Messaged when a request has failed with an error.
 *
 * @param request The request.
 * @param error The error.
 */
- (void)networkRequest:(GCKNetworkRequest *)request
      didFailWithError:(GCKNetworkRequestError *)error;

@optional

/**
 * Messaged when a request has been cancelled. This delegate method is optional.
 *
 * @param request The request.
 */
- (void)networkRequestWasCancelled:(GCKNetworkRequest *)request;

@end

@class GCKContext;

/**
 * The base class for all network requests.
 *
 * @ingroup Utilities
 */
@interface GCKNetworkRequest : NSObject

/** The delegate for receiving notifications. */
@property(nonatomic, assign) id<GCKNetworkRequestDelegate> delegate;

/** The encoding used for the response data. By default this is NSUTF8StringEncoding. */
@property(nonatomic) NSStringEncoding responseEncoding;

/**
 * Designated initializer. Constructs a new GCKNetworkRequest with the given context.
 *
 * @param context The context.
 */
- (id)initWithContext:(GCKContext *)context;

/**
 * Begins executing the request.
 */
- (void)execute;

/**
 * Cancels an in-progress request.
 */
- (void)cancel;

/**
 * Performs an HTTP GET operation.
 *
 * @param url The URL for the operation.
 * @param timeout The timeout.
 */
- (void)performHTTPGet:(NSURL *)url
               timeout:(NSTimeInterval)timeout;

/**
 * Performs an HTTP POST operation.
 *
 * @param url The URL for the operation.
 * @param data The data to post, if any; otherwise <code>nil</code>.
 * @param timeout The timeout.
 */
- (void)performHTTPPost:(NSURL *)url
                   data:(GCKMimeData *)data
                timeout:(NSTimeInterval)timeout;

/**
 * Performs an HTTP DELETE operation.
 *
 * @param url The URL for the operation.
 * @param timeout The timeout.
 */
- (void)performHTTPDelete:(NSURL *)url
                  timeout:(NSTimeInterval)timeout;

/**
 * Called when the current HTTP request has completed. The default implementation is a no-op
 * that returns @link GCKNetworkRequestError#kGCKNetworkRequestErrorCodeOK @endlink.
 * Subclasses should override the method to process the results and return an appropriate error
 * code.
 *
 * @param status The HTTP status code from the response.
 * @param finalURL The final URL that was requested, taking into account any HTTP redirects.
 * @param headers The HTTP headers from the response.
 * @param data The data from the response, if any; otherwise <code>nil</code>.
 * @return An error code; one of the constants defined above.
 */
- (NSInteger)processResponseWithStatus:(NSInteger)status
                              finalURL:(NSURL *)finalURL
                               headers:(NSDictionary *)headers
                                  data:(GCKMimeData *)data;

/**
 * A convenience method for parsing JSON data. Delegates to @link GCKJsonUtils#parseJson: @endlink.
 */
- (id)parseJson:(NSString *)json;

/**
 * A convenience method for writing JSON data. Delegates to @link GCKJsonUtils#writeJson: @endlink.
 */
- (NSString *)writeJson:(id)object;

/**
 * Called if the request completes successfully. The default implementation does nothing, but
 * subclasses may override. This is called before the delegate is notified.
 */
- (void)didComplete;

/**
 * Called if the request fails. The default implementation does nothing, but subclasses may
 * override. This is called before the delegate is notified.
 */
- (void)didFailWithError:(GCKError *)error;

@end
