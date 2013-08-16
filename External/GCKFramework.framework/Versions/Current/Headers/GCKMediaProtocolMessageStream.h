// Copyright 2013 Google Inc.

#import "GCKMessageStream.h"

@class GCKContentMetadata;
@class GCKMediaProtocolCommand;

/** Remote media player states. */
typedef NS_ENUM(NSInteger, GCKPlayerState) {
  kGCKPlayerStateUnknown = -1,
  kGCKPlayerStateIdle = 0,
  kGCKPlayerStateStopped = 1,
  kGCKPlayerStatePlaying = 2
};

/**
 * The minimum allowed value for audio volume.
 *
 * @memberof GCKMediaProtocolMessageStream
 */
extern const double kGCKMinVolume;

/**
 * The maximum allowed value for audio volume.
 *
 * @memberof GCKMediaProtocolMessageStream
 */
extern const double kGCKMaxVolume;

@protocol GCKMediaProtocolMessageStreamDelegate;

/**
 * A subclass of GCKMessageStream that implements RAMP (Remote Application Media Protocol). This
 * class provides methods for issuing the various RAMP requests to control playback and obtain
 * player status.
 * <p>
 * Some methods, such as {@link #stopStream}, do not provide any result notifications. Others,
 * such as {@link #loadMediaWithContentID:contentMetadata:},
 * return a {@link GCKMediaProtocolCommand} object which can be used to track the result of the
 * operation.
 * <p>
 * This class is not threadsafe.
 *
 * @ingroup Messages
 */
@interface GCKMediaProtocolMessageStream : GCKMessageStream

/** The delegate that will receive notifications for this stream. */
@property(nonatomic, assign) id<GCKMediaProtocolMessageStreamDelegate> delegate;

/** The current content ID, or <code>nil</code> if none is available. */
@property(nonatomic, copy, readonly) NSString *contentID;

/** The current content info, or <code>nil</code> if there is none. */
@property(nonatomic, copy, readonly) NSDictionary *contentInfo;

/** The current media player state. */
@property(nonatomic, readonly) GCKPlayerState playerState;

/**
 * The current stream position, in seconds. Extrapolates the current position from the latest
 * update based on elapsed wall-time since that update.
 */
@property(nonatomic, readonly) NSTimeInterval streamPosition;

/**
 * The current stream duration, in seconds, or <code>0.0</code> if the stream is a live stream or
 * the duration is otherwise unavailable.
 */
@property(nonatomic, readonly) NSTimeInterval streamDuration;

/** The title of the currently loaded media, if any. */
@property(nonatomic, copy, readonly) NSString *mediaTitle;

/** The image URL for the currently loaded media, if any. */
@property(nonatomic, copy, readonly) NSURL *mediaImageURL;

/** The current audio volume. */
@property(nonatomic, readonly) double volume;

/** The current mute state. */
@property(nonatomic, readonly) BOOL muted;

/** The list of available media tracks. */
@property(nonatomic, copy, readonly) NSMutableArray *mediaTracks;

/** Designated initializer. Constructs a new MediaProtocolMessageStream. */
- (id)init;

/**
 * Loads the specified media in the media player.
 *
 * @param contentID The unique identifier for the content.
 * @param metadata The metadata for the content; may be <code>nil</code>.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)loadMediaWithContentID:(NSString *)contentID
                                    contentMetadata:(GCKContentMetadata *)metadata;

/**
 * Loads the specified media in the media player and optionally starts playback immediately.
 *
 * @param contentID The unique identifier for the content.
 * @param metadata The metadata for the content; may be <code>nil</code>.
 * @param autoplay If <code>YES</code>, playback sould start automatically once the content is
 * loaded.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)loadMediaWithContentID:(NSString *)contentID
                                    contentMetadata:(GCKContentMetadata *)metadata
                                           autoplay:(BOOL)autoplay;

/**
 * Starts playback at the current stream position. Equivalent to calling
 * @link #playStreamFrom: @endlink with a position of <code>-1.0</code>.
 *
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)resumeStream;

/**
 * Starts playback at the beginning of the stream. Equivalent to calling
 * @link #playStreamFrom: @endlink with a position of <code>0.0</code>.
 *
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)playStream;

/**
 * Starts playback at the given stream position.
 *
 * @param position The stream position.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)playStreamFrom:(NSTimeInterval)position;

/**
 * Stops playback.
 *
 * @return <code>YES</code> if the request was sent successfully, <code>NO</code> otherwise.
 */
- (BOOL)stopStream;

/**
 * Sets the audio volume.
 *
 * @param volume The volume.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)setStreamVolume:(double)volume;

/**
 * Mutes or unmutes the audio.
 *
 * @param muted Whether the audio should be muted.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)setStreamMuted:(BOOL)muted;

/**
 * Enables and disables media tracks. When the request completes successfully,
 * updated stream status information will be received and
 * @link GCKMediaProtocolMessageStreamDelegate#mediaProtocolMessageStreamDidReceiveStatusUpdate:
 * @endlink will be called. To get the updated status of the media tracks, read the
 * @link #mediaTracks @endlink property.
 *
 * @param tracksToEnable An array of identifiers of the media tracks to enable. May be
 * <code>nil</code>.
 * @param tracksToDisable An array of identifiers of the media tracks to disable. May be
 * <code>nil</code>.
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)selectTracksToEnable:(NSArray *)tracksToEnable
                                       andDisable:(NSArray *)tracksToDisable;

/**
 * Requests the media player's current status.  Note that completion of this command will result
 * in calls to both the @link
 * GCKMediaProtocolMessageStreamDelegate#mediaProtocolMessageStreamDidReceiveStatusUpdate:
 * @endlink method and the
 * @link GCKMediaProtocolCommandDelegate#mediaProtocolCommandDidComplete: @endlink method, in that
 * order.
 *
 * @return The GCKMediaProtocolCommand object representing this request.
 */
- (GCKMediaProtocolCommand *)requestStatus;

/**
 * Sends the authorization tokens to the receiver, in response to a key request received via
 * {@link #keyRequestWasReceivedWithRequestID:method:requests:}.
 *
 * @param requestID The unique ID of the corresponding key request.
 * @param tokens An array of authorization token strings.
 * @return <code>YES</code> if the request was sent successfully, <code>NO</code> otherwise.
 */
- (BOOL)sendKeyResponseForRequestID:(NSUInteger)requestID
                         withTokens:(NSArray *)tokens;

/**
 * Cancels an in-progress GCKMediaProtocolCommand.
 *
 * @param command The command to cancel.
 * @return <code>YES</code> if the command was cancelled, <code>NO</code> if this command isn't
 * currently running.
 */
- (BOOL)cancelCommand:(GCKMediaProtocolCommand *)command;

/**
 * Called when a key request event has arrived from the receiver. Should be subclassed to prepare
 * an appropriate response, which can be sent to the receiver by calling
 * {@link sendKeyResponseForRequestID:withTokens:}. The default implementation is a no-op.
 *
 * @param requestID The unique ID for this request.
 * @param method A description of how to interpret the contents of the requests array.
 * @param requests An array of one or more key request strings.
 */
- (void)keyRequestWasReceivedWithRequestID:(NSInteger)requestID
                                    method:(NSString *)method
                                  requests:(NSArray *)requests;

- (void)didReceiveMessage:(id)message;

- (void)didDetach;

@end

/**
 * A delegate for receiving notifcations from a GCKMediaProtocolMessageStream.
 *
 * @ingroup Messages
 */
@protocol GCKMediaProtocolMessageStreamDelegate <NSObject>

@optional

/**
 * Called when a GCKMediaProtocolMessageStream has received updated state information.
 *
 * @param stream The stream.
 */
- (void)mediaProtocolMessageStreamDidReceiveStatusUpdate:(GCKMediaProtocolMessageStream *)stream;

/**
 * Called when a GCKMediaProtocolMessageStream has updated its media track list.
 *
 * @param stream The stream.
 */
- (void)mediaProtocolMessageStreamDidUpdateTrackList:(GCKMediaProtocolMessageStream *)stream;

/**
 * Called when a GCKMediaProtocolMessageStream has received an error.
 *
 * @param stream The stream.
 * @param domain The error domain.
 * @param code The error code.
 * @param errorInfo Extra, application-specific error information, if any, otherwise
 * <code>nil</code>.
 */
- (void)mediaProtocolMessageStream:(GCKMediaProtocolMessageStream *)stream
         didReceiveErrorWithDomain:(NSString *)domain
                              code:(NSInteger)code
                         errorInfo:(NSDictionary *)errorInfo;

@end

