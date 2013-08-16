// Copyright 2013 Google Inc.

#import "GCKNetworkRequest.h"

#include "TargetConditionals.h"

#if TARGET_OS_IPHONE
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

@class GCKContext;

/**
 * A request to fetch an image at a URL and optionally scale it to a given size.
 *
 * @ingroup Utilities
 */
@interface GCKFetchImageRequest : GCKNetworkRequest

/**
 * The image that was retrieved, otherwise {@code nil}.
 */
#if TARGET_OS_IPHONE
@property(nonatomic, strong, readonly) UIImage *image;
#else
@property(nonatomic, strong, readonly) NSImage *image;
#endif

/**
 * Designated initializer. Constructs a request that will fetch the image at the given URL and
 * scale it to the requested size while maintaining the original image's aspect ratio.
 * If the requested size is invalid (both width and height less than zero), the image will not be
 * scaled.
 *
 * @param context The context.
 * @param url The URL.
 * @param width The preferred width, in pixels.
 * @param height The preferred height, in pixels.
 */
- (id)initWithContext:(GCKContext *)context
                  url:(NSURL *)url
       preferredWidth:(NSUInteger)width
      preferredHeight:(NSUInteger)height;

/**
 * Constructs a request that will fetch the image at the given URL.
 *
 * @param context The context.
 * @param url The URL.
 */
- (id)initWithContext:(GCKContext *)context
                  url:(NSURL *)url;

@end
