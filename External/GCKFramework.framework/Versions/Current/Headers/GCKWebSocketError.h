// Copyright 2013 Google Inc.

#import "GCKError.h"

/**
 * The error domain for GCKWebSocket errors.
 *
 * @ingroup Sessions
 */
extern NSString * const kGCKWebSocketErrorDomain;

/**
 * An error code indicating a protocol error.
 *
 * @memberof GCKWebSocketError
 */
extern const int kGCKWebSocketErrorCodeProtocol;

/**
 * An error code indicating an I/O timeout.
 *
 * @memberof WebSocketError
 */
extern const int kGCKWebSocketErrorCodeTimeout;

/**
 * A subclass of GCKError for GCKWebSocket errors.
 */
@interface GCKWebSocketError : GCKError

/** @cond INTERNAL */

- (id)initWithCode:(NSInteger)code;

+ (NSString *)localizedDescriptionForCode:(NSInteger)code;

/** @endcond */

@end
