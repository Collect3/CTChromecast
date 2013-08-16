// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

/**
 * The MIME-type for binary data ("application/octet-stream").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeBinary;

/**
 * The MIME-type for HTML form data ("application/x-www-form-urlencoded").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeForm;

/**
 * The MIME-type for HTML text ("text/html").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeHTML;

/**
 * The MIME-type for JSON data ("application/json").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeJSON;

/**
 * The MIME-type for plain text ("text/plain").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeText;

/**
 * The MIME-type for a URL ("text/url").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeURL;

/**
 * The MIME-type for XML data ("application/xml").
 *
 * @memberof GCKMimeData
 */
extern NSString * const kGCKMimeXML;

/**
 * A class for encapsulating a chunk of MIME data.
 *
 * @ingroup Utilities
 */
@interface GCKMimeData : NSObject

/** The MIME-type. */
@property(nonatomic, copy, readonly) NSString *type;
/** The MIME data. */
@property(nonatomic, copy, readonly) NSData *data;
/** The MIME data, interpreted as UTF-8 encoded text. */
@property(nonatomic, copy, readonly) NSString *textData;

/**
 * Designated initializer. Constructs a GCKMimeData with the given binary data and mime type.
 *
 * @param data The MIME data.
 * @param type The MIME type. Cannot be <code>nil</code>.
 */
- (id)initWithData:(NSData *)data type:(NSString *)type;

/**
 * Constructs a GCKMimeData with the given text data and mime type.
 *
 * @param data The MIME text data. The data will be encoded to UTF-8.
 * @param type The MIME type. Cannot be <code>nil</code>.
 */
- (id)initWithTextData:(NSString *)data type:(NSString *)type;

/**
 * Constructs a GCKMimeData object to encapsulate the string representation of a JSON object.
 *
 * @param json The JSON object.
 * @return The GCKMimeData.
 */
+ (GCKMimeData *)mimeDataWithJsonObject:(id)json;

/**
 * Constructs a GCKMimeData object to encapsulate a URL.
 *
 * @param url The URL.
 * @return The GCKMimeData.
 */
+ (GCKMimeData *)mimeDataWithURL:(NSURL *)url;

@end
