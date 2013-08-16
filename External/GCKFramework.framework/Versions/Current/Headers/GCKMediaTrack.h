// Copyright 2013 Google Inc.

/**
 * Media track types.
 */
typedef NS_ENUM(NSInteger, GCKMediaTrackType) {
  /** Unknown track type. */
  kGCKMediaTrackTypeUnknown = 0,
  /** Subtitles. */
  kGCKMediaTrackTypeSubtitles = 1,
  /** Closed captions. */
  kGCKMediaTrackTypeCaptions = 2,
  /** Audio. */
  kGCKMediaTrackTypeAudio = 3,
  /** Video. */
  kGCKMediaTrackTypeVideo = 4
};

/**
 * A class representing a media track. Instances of this object are immutable.
 *
 * @ingroup Messages
 */
@interface GCKMediaTrack : NSObject<NSCopying>

/**
 * Designated initializer. Constructs a new GCKMediaTrack with the given property values.
 */
- (id)initWithIdentifier:(NSInteger)identifier
                    type:(GCKMediaTrackType)type
                    name:(NSString *)name
            languageCode:(NSString *)languageCode
                 enabled:(BOOL)enabled;

/** The track's unique numeric identifier. */
@property(nonatomic, readonly) NSInteger identifier;

/** The track's type. */
@property(nonatomic, readonly) GCKMediaTrackType type;

/** The track's name, which may be <code>nil</code>. */
@property(nonatomic, copy, readonly) NSString *name;

/** The track's language code, which may be <code>nil</code>. */
@property(nonatomic, copy, readonly) NSString *languageCode;

/** Whether the track is enabled. */
@property(nonatomic, readwrite) BOOL enabled;

@end
