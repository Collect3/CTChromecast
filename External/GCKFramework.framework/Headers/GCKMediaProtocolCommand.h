// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

/**
 * A type string that identifies a "info request" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypeInfo;

/**
 * A type string that identifies a "load media" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypeLoad;

/**
 * A type string that identifies a "play" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypePlay;

/**
 * A type string that identifies a "stop" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypeStop;

/**
 * A type string that identifies a "volume" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypeVolume;

/**
 * A type string that identifies a "select tracks" command.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolCommandTypeSelectTracks;

/**
 * The error domain for RAMP-specific errors.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern NSString * const kGCKMediaProtocolErrorDomain;

/** A RAMP error code indicating an invalid player state.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern const int kGCKMediaProtocolErrorInvalidPlayerState;

/** A RAMP error code indicating a failure to load media content.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern const int kGCKMediaProtocolErrorFailedToLoadMedia;

/** A RAMP error code indicating that loading of media content has been cancelled.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern const int kGCKMediaProtocolErrorMediaLoadCancelled;

/** A RAMP error code indicating that an invalid/malformed request was received.
 *
 * @memberof GCKMediaProtocolCommand
 */
extern const int kGCKMediaProtocolErrorInvalidRequest;

@protocol GCKMediaProtocolCommandDelegate;

/**
 * A class representing an in-progress command on a GCKMediaProtocolMessageStream. A delegate should
 * be assigned to the object to get notification of its completion and/or errors.
 *
 * @ingroup Messages
 */
@interface GCKMediaProtocolCommand : NSObject

/** The delegate for receiving notifications. */
@property(nonatomic) id<GCKMediaProtocolCommandDelegate> delegate;

/** The command's sequence number. */
@property(nonatomic, readonly) NSUInteger sequenceNumber;

/** The command type. */
@property(nonatomic, copy, readonly) NSString *type;

/** Whether the command was cancelled. */
@property(nonatomic, readonly) BOOL cancelled;

/** Whether the command has completed. */
@property(nonatomic, readonly) BOOL completed;

/** Whether the command returned an error. */
@property(nonatomic) BOOL hasError;

/** The error domain for the error. */
@property(nonatomic, copy) NSString *errorDomain;

/** The error code for the error. */
@property(nonatomic) NSInteger errorCode;

/** Extra, application-specific error information. */
@property(nonatomic, copy) NSDictionary *errorInfo;

/** @cond INTERNAL */

/**
 * Application code should not construct GCKMediaProtocolCommand%s directly; they are created by the
 * GCKMediaProtocolMessageStream.
 *
 * @param sequenceNumber The command's sequence number.
 * @param type The command type.
 */
- (id)initWithSequenceNumber:(NSUInteger)sequenceNumber
                        type:(NSString *)type;


/** Marks the command as having completed. */
- (void)complete;

/** @endcond */

/** Cancels the command. */
- (void)cancel;

@end

/**
 * The delegate protocol for GCKMediaProtocolCommand.
 *
 * @ingroup Messages
 */
@protocol GCKMediaProtocolCommandDelegate <NSObject>

/**
 * Called when a command has completed.
 *
 * @param command The command.
 */
- (void)mediaProtocolCommandDidComplete:(GCKMediaProtocolCommand *)command;

@optional

/**
 * Called when a command has been cancelled.
 *
 * @param command The command.
 */
- (void)mediaProtocolCommandWasCancelled:(GCKMediaProtocolCommand *)command;

@end
