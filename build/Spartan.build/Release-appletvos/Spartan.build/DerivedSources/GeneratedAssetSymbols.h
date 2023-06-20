#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.whitetailani.Spartan";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "App Icon/Front/Content" asset catalog image resource.
static NSString * const ACImageNameAppIconFrontContent AC_SWIFT_PRIVATE = @"App Icon/Front/Content";

/// The "App Icon/Back/Content" asset catalog image resource.
static NSString * const ACImageNameAppIconBackContent AC_SWIFT_PRIVATE = @"App Icon/Back/Content";

/// The "DefaultIcon" asset catalog image resource.
static NSString * const ACImageNameDefaultIcon AC_SWIFT_PRIVATE = @"DefaultIcon";

/// The "NotFound" asset catalog image resource.
static NSString * const ACImageNameNotFound AC_SWIFT_PRIVATE = @"NotFound";

/// The "Top Shelf Image" asset catalog image resource.
static NSString * const ACImageNameTopShelfImage AC_SWIFT_PRIVATE = @"Top Shelf Image";

/// The "repeat.slash" asset catalog image resource.
static NSString * const ACImageNameRepeatSlash AC_SWIFT_PRIVATE = @"repeat.slash";

/// The "repeat.slash.black" asset catalog image resource.
static NSString * const ACImageNameRepeatSlashBlack AC_SWIFT_PRIVATE = @"repeat.slash.black";

/// The "repeat.slash.white" asset catalog image resource.
static NSString * const ACImageNameRepeatSlashWhite AC_SWIFT_PRIVATE = @"repeat.slash.white";

#undef AC_SWIFT_PRIVATE