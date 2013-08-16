// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

#import "GCKApplicationChannel.h"

@class GCKApplicationMetadata;
@protocol GCKApplicationSessionDelegate;
@class GCKApplicationSessionError;
@class GCKContext;
@class GCKDevice;
@class GCKMimeData;

/**
 * The minimum I/O buffer size for a GCKApplicationSession.
 *
 * @memberof GCKApplicationSession
 */
extern const NSUInteger kGCKApplicationSessionMinBufferSize;

/**
 * The default I/O buffer size for a GCKApplicationSession.
 *
 * @memberof GCKApplicationSession
 */
extern const NSUInteger kGCKApplicationSessionDefaultBufferSize;

/**
 * A session with an application on a GCK device. A session is associated with an application;
 * when the session is started, the application is launched, and, if the application supports a
 * communications channel, that channel is established.
 * <p>
 * A typical session lifecycle consists of the following steps:
 * <ol>
 * <li>Construct a new GCKApplicationSession object for a GCKDevice.
 * <li>Assign a GCKApplicationSessionDelegate to the GCKApplicationSession.
 * <li>Start the session with @link #startSession @endlink.
 * <li>Wait for the @link GCKApplicationSessionDelegate#applicationSessionDidStart @endlink
 * method to be called.
 * <li> Get the session's GCKApplicationChannel by reading its @link #channel @endlink property.
 * <li>Construct one or more GCKMessageStream%s and attach them to the channel with
 * @link GCKApplicationChannel#attachMessageStream: @endlink.
 * <li>Send and receive messages using those GCKMessageStream%s.
 * <li>End the session with @link #endSession @endlink.
 * <li>Wait for the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidEndWithError: @endlink
 * method to be called.
 * </ol>
 *
 * <p>
 * This class is not threadsafe.
 *
 * @ingroup Sessions
 */
@interface GCKApplicationSession : NSObject <GCKApplicationChannelDelegate>

/** The delegate for receiving session notifications. */
@property(nonatomic) id<GCKApplicationSessionDelegate> delegate;

/** The application metadata for the current application. */
@property(nonatomic, strong, readonly) GCKApplicationMetadata *applicationInfo;

/** The channel to the application, if any. */
@property(nonatomic, strong, readonly) GCKApplicationChannel *channel;

/** Indicates whether the session has been successfully started. */
@property(nonatomic, readonly) BOOL hasStarted;

/** The session's I/O buffer size. */
@property(nonatomic, readonly) NSUInteger bufferSize;

/**
 * Flag indicating whether the application should be stopped when the session is ended. By
 * default this is set to <code>NO</code>. This property may not be set while the session is ending;
 * attempting to do so will result in an assertion failure.
 */
@property(nonatomic) BOOL stopApplicationWhenSessionEnds;

/**
 * Designated initializer. Constructs a new GCKApplicationSession with the given context, device
 * and I/O buffer size.
 *
 * @param context The context.
 * @param device The device.
 * @param bufferSize The I/O buffer size.
 */
- (id)initWithContext:(GCKContext *)context
               device:(GCKDevice *)device
           bufferSize:(NSUInteger)bufferSize;

/**
 * Constructs a new GCKApplicationSession with the given context, device and a default I/O buffer
 * size.
 *
 * @param context The context.
 * @param device The device.
 */
- (id)initWithContext:(GCKContext *)context
               device:(GCKDevice *)device;

/**
 * Starts a new session and connects to the currently running application, if any. This method
 * returns immediately, and the session setup continues in the background. When the session has
 * been started, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidStart @endlink
 * method is called. If the startup fails, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidFailToStartWithError: @endlink
 * method is called.
 *
 * @return <code>YES</code> on success, or <code>NO</code> if the session is not currently in a
 * "stopped" state, or if no application name was passed to the initializer and there is no
 * currently running application.
 */
- (BOOL)startSession;

/**
 * Starts a new session and connects to the named application. This method returns immediately, and
 * the session setup continues in the background. When the session has been started, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidStart @endlink
 * method is called. If the startup fails, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidFailToStartWithError: @endlink
 * method is called.
 *
 * @param applicationName The name of the application to start and connect to.
 * @return <code>YES</code> on success, or <code>NO</code> if the session is not currently in a
 * "stopped" state.
 */
- (BOOL)startSessionWithApplication:(NSString *)applicationName;

/**
 * Starts a new session and connects to the named application, passing it an optional argument,
 * which may be <code>nil</code>. This method returns immediately, and the session setup
 * continues in the background. When the session has been started, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidStart @endlink
 * method is called. If the startup fails, the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidFailToStartWithError: @endlink
 * method is called.
 *
 * @param applicationName The name of the application to start and connect to.
 * @param argument The optional application argument, or <code>nil</code> for none.
 * @return <code>YES</code> on success, or <code>NO</code> if the session is not currently in a
 * "stopped" state.
 */
- (BOOL)startSessionWithApplication:(NSString *)applicationName
                           argument:(GCKMimeData *)argument;

/**
 * Ends the session. Closes any channels that have been opened in this session. This method returns
 * immediately, and session teardown continues in the background. When the session has been ended,
 * the delegate's
 * @link GCKApplicationSessionDelegate#applicationSessionDidEndWithError: @endlink method
 * is called.
 *
 * @return <code>YES</code> on success or <code>NO</code> if the session is not currently in a
 * "started" state.
 */
- (BOOL)endSession;

/**
 * Resumes a previously ended session. Attempts to reconnect to the same application
 * instance that was running when the session was last ended. If that instance is no
 * longer running, session setup will fail. This method returns immediately, and the
 * session setup continues in the background. When the session has been resumed, the
 * @link GCKApplicationSessionDelegate#applicationSessionDidStart @endlink method is
 * called. If the setup fails, the
 * @link GCKApplicationSessionDelegate#applicationSessionDidFailToStartWithError: @endlink
 * method is called.
 *
 * @return <code>YES</code> on success or <code>NO</code> if the session is not currently in a
 * "stopped" state.
 */
- (BOOL)resumeSession;

@end

/**
 * The delegate protocol for GCKApplicationSession.
 *
 * @ingroup Sessions
 */
@protocol GCKApplicationSessionDelegate

/** Called when the session has been started successfully. */
- (void)applicationSessionDidStart;

/**
 * Called when the session could not be started.
 *
 * @param error The error indicating the reason for the failure.
 */
- (void)applicationSessionDidFailToStartWithError:(GCKApplicationSessionError *)error;

/**
 * Called when the session has ended, either normally or due to an error.
 *
 * @param error The error indicating the reason for the failure, or <code>nil</code> if the
 * session ended normally.
 */
- (void)applicationSessionDidEndWithError:(GCKApplicationSessionError *)error;

@end
