// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

@protocol GCKMessageSink;

/**
 * A GCKMessageStream is layered over a GCKApplicationChannel and is used to send and receive
 * messages that are tagged with a specific namespace. In this way, multiple message streams may be
 * multiplexed over a single channel.
 * <p>
 * This is an abstract class. Subclasses will implement the
 * @link GCKMessageStream#didReceiveMessage: @endlink
 * method to process incoming messages, and will typically provide additional methods for sending
 * messages that are specific to a given namespace.
 *
 * @ingroup Messages
 */
@interface GCKMessageStream : NSObject

/** The stream's namespace. */
@property(nonatomic, copy, readonly) NSString *namespace;

/** @cond INTERNAL */

/**
 * The destination for outgoing messages. This property is set by the GCKApplicationSession and
 * should not be modified by the application.
 */
@property(nonatomic, strong) id<GCKMessageSink> messageSink;

/** @endcond */

/**
 * Designated initializer. Constructs a new GCKMessageStream with the given namespace.
 *
 * @param namespace The namespace.
 */
- (id)initWithNamespace:(NSString *)namespace;

/**
 * Called when the stream has been attached to a channel. The default implementation is a no-op.
 */
- (void)didAttach;

/**
 * Called when the stream has been detached from its channel. The default implementation is a
 * no-op.
 */
- (void)didDetach;

/**
 * Called when a JSON message has been received for this stream on its channel. The default
 * implementation is a no-op.
 *
 * param message The message, parsed into a JSON object.
 */
- (void)didReceiveMessage:(id)message;

/**
 * Sends a JSON message on the channel.
 *
 * @param message The message, as a JSON object.
 * @return <code>YES</code> on success or <code>NO</code> if the message could not be sent (because
 * there is no channel attached, or because the channel's send buffer is too full at the moment).
 */
- (BOOL)sendMessage:(id)message;

@end
