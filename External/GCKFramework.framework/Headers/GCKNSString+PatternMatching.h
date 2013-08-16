// Copyright 2013 Google Inc.

#import <Foundation/Foundation.h>

/**
 * A category on NSString that adds methods for regular expression pattern matching.
 *
 * @ingroup Utilities
 */
@interface NSString (GCKPatternMatching)

/**
 * Tests if the string exactly matches a given regular expression.
 *
 * @param regexPattern The pattern to compare to.
 * @return <code>YES</code> if the string matches the pattern, <code>NO</code> otherwise.
 */
- (BOOL)gck_matchesPattern:(NSString *)regexPattern;

@end
