// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

@protocol GCKApplicationChannelDelegate;
@class GCKError;
@class GCKMessageStream;

/**
 * A communications channel to a first-screen application. Messages are not sent and received using the
 * GCKApplicationChannel directly; instead, one or more GCKMessageStream%s are layered over
 * the channel.
 * <p>
 * GCKMessageStream attachment and detachment is threadsafe; connecting and disconnecting is
 * currently not threadsafe.
 *
 * @ingroup Sessions
 */
// TODO(mlindner): Make connect/disconnect threadsafe.
@interface GCKApplicationChannel : NSObject

/** @cond INTERNAL */

/** The delegate for receiving GCKApplicationChannel notifications. */
@property(nonatomic) id<GCKApplicationChannelDelegate> delegate;

/** @endcond */

/**
 * The number of bytes that can be written to the outgoing message buffer; will be <code>0</code>
 * if the buffer is full, or <code>-1</code> if the channel is not currently connected.
 */
@property(nonatomic, readonly) NSUInteger sendBufferAvailableBytes;

/**
 * The number of unsent bytes in the outgoing message buffer; will be <code>0</code> if the buffer
 * is empty (all data has been sent), or <code>-1</code> if the channel is not currently connected.
 */
@property(nonatomic, readonly) NSUInteger sendBufferPendingBytes;

/** @cond INTERNAL */

/**
 * Designated initializer. Constructs a new GCKApplicationChannel with the given I/O buffer size.
 * Application code should not constructGCKApplicationChannel%s directly; they are created by
 * the GCKApplicationSession.
 *
 * @param bufferSize The I/O buffer size for this channel.
 * @param pingInterval The ping interval.
 */
- (id)initWithBufferSize:(NSUInteger)bufferSize
            pingInterval:(NSTimeInterval)pingInterval;

/**
 * Begins connecting the channel to the specified URL. The delegate is notified when the connection
 * completes (or fails).
 *
 * @param url The URL to connect to.
 */
- (BOOL)connectTo:(NSURL *)url;

/**
 * Begins disconnecting the channel. The delegate is notified when the disconnect completes.
 */
- (void)disconnect;

/** @endcond */

/**
 * Attaches a GCKMessageStream to the channel.
 *
 * @param stream The stream to attach.
 * @return <code>YES</code> if the stream was successfully attached; <code>NO</code> if there is
 * already a stream attached with this stream's namespace.
 */
- (BOOL)attachMessageStream:(GCKMessageStream *)stream;

/**
 * Detaches a GCKMessageStream from to the channel.
 *
 * @param stream The strema to detach.
 * @return <code>YES</code> if the stream was successfully detached; <code>NO</code> if there is
 * no stream attached with this stream's namespace.
 */
- (BOOL)detachMessageStream:(GCKMessageStream *)stream;

/** Detaches all GCKMessageStream%s from the channel. */
- (void)detachAllMessageStreams;

@end

/** @cond INTERNAL */

/** Interface used only by unit tests. */
@interface GCKApplicationChannel (UnitTestSupport)

/**
 * Parses the given message into a namespace and a JSON object and dispatches it to the
 * appropriate GCKMessageStream.
 *
 * @param message The message to process.
 */
- (void)dispatchMessage:(NSString *)message;

/**
 * Sends a message down the channel.
 */
- (BOOL)sendMessageWithNamespace:(NSString *)namespace message:(id)message;

@end

/**
 * The delegate protocol for GCKApplicationChannel.
 */
@protocol GCKApplicationChannelDelegate<NSObject>

/**
 * Called when a channel has been successfully connected.
 *
 * @param channel The channel.
 */
- (void)applicationChannelDidConnect:(GCKApplicationChannel *)channel;

/**
 * Called when a channel failed to connect due to an error.
 *
 * @param channel The channel.
 * @param error The error.
 */
- (void)applicationChannel:(GCKApplicationChannel *)channel
    connectionDidFailWithError:(GCKError *)error;

/**
 * Called when the channel has been disconnected.
 *
 * @param channel The channel.
 * @param error The error, or <code>nil</code>if the disconnect was normal.
 */
- (void)applicationChannel:(GCKApplicationChannel *)channel
    didDisconnectWithError:(GCKError *)error;

@end

/** @endcond */
