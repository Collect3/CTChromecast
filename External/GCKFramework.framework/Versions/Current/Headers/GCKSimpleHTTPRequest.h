// Copyright 2012 Google Inc.

#import <Foundation/Foundation.h>

@class GCKMimeData;

/**
 * HTTP "OK" status (200).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusOK;

/**
 * HTTP "Created" status (201).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusCreated;

/**
 * HTTP "No Content" status (204).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusNoContent;

/**
 * HTTP "Forbidden" status (403).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusForbidden;

/**
 * HTTP "Not found" status (404).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusNotFound;

/**
 * HTTP "Not implemented" status (501).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusNotImplemented;

/**
 * HTTP "Service unavailable" status (503).
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern const int kGCKHTTPStatusServiceUnavailable;

/**
 * HTTP "Location" header name.
 *
 * @memberof GCKSimpleHTTPRequest
 */
extern NSString * const kGCKHTTPHeaderLocation;

@protocol GCKSimpleHTTPRequestDelegate;

/**
 * An object for performing simple HTTP requests asynchronously.
 *
 * @ingroup Utilities
 */
@interface GCKSimpleHTTPRequest : NSObject

/** The delegate for receiving notifications. */
@property(nonatomic, assign) id<GCKSimpleHTTPRequestDelegate> delegate;

/** The request timeout. */
@property(nonatomic, assign) NSTimeInterval timeout;

/** The original URL of the latest request. */
@property(nonatomic, copy, readonly) NSURL *url;

/**
 * The final URL of the latest request, which will differ from the original URL if any HTTP
 * redirects took place.
 */
@property(nonatomic, copy, readonly) NSURL *finalUrl;

/** The HTTP response headers. */
@property(nonatomic, strong, readonly) NSDictionary *responseHeaders;

/** Designated initializer. Constructs a new HTTP request. */
- (id)init;

/**
 * Starts a GET request.
 *
 * @param url The URL for the request.
 */
- (void)startGetRequest:(NSURL *)url;

/**
 * Starts a POST request.
 *
 * @param url The URL for the request.
 * @param data The data to post; may be <code>nil</code>.
 */
- (void)startPostRequest:(NSURL *)url
                    data:(GCKMimeData *)data;

/**
 * Sets a header value for the request. Must not be called once the request has been started.
 *
 * @param value The value to set for the header.
 * @param field The header field for which to set the value.
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 * Starts a DELETE request.
 *
 * @param url The URL for the request.
 */
- (void)startDeleteRequest:(NSURL *)url;

/**
 * Cancels the request, if it's in-progress.
 */
- (void)cancel;

@end


/**
 * The delegate protocol for GCKSimpleHTTPRequest.
 *
 * @ingroup Utilities
 */
@protocol GCKSimpleHTTPRequestDelegate <NSObject>

@optional

/**
 * Called for all URL requests after they are configured, before starting the request.
 * Use this method for any custom configuration of the NSMutableURLRequest.
 *
 * @param request The request to be started.
 * @param simpleRequest The GCKSimpleHTTPRequest.
 */
- (void)configureURLRequest:(NSMutableURLRequest *)request
       forSimpleHTTPRequest:(GCKSimpleHTTPRequest *)simpleRequest;

@required

/**
 * Messaged when a request completes successfully.
 *
 * @param request The request that completed.
 * @param status The HTTP response status.
 * @param finalURL The final URL, taking into account any HTTP redirects that took place.
 * @param headers The HTTP response headers.
 * @param data The HTTP response data, if any, otherwise <code>nil</code>.
 */
- (void)httpRequest:(GCKSimpleHTTPRequest *)request
    didCompleteWithStatusCode:(NSInteger)status
                     finalURL:(NSURL *)finalURL
                      headers:(NSDictionary *)headers
                         data:(GCKMimeData *)data;

/**
 * Messaged when a request fails with an error.
 *
 * @param request The request that failed.
 * @param error The error.
 */
- (void)httpRequest:(GCKSimpleHTTPRequest *)request
    didFailWithError:(NSError *)error;

@end
