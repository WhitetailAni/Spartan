import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

private class ResourceBundleClass {}
private let resourceBundle = Bundle(for: ResourceBundleClass.self)

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = ColorResource(name: "AccentColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "App Icon" asset catalog resource namespace.
    enum AppIcon {

        /// The "App Icon/Front" asset catalog resource namespace.
        enum Front {

            /// The "App Icon/Front/Content" asset catalog image resource.
            static let content = ImageResource(name: "App Icon/Front/Content", bundle: resourceBundle)

        }

        /// The "App Icon/Back" asset catalog resource namespace.
        enum Back {

            /// The "App Icon/Back/Content" asset catalog image resource.
            static let content = ImageResource(name: "App Icon/Back/Content", bundle: resourceBundle)

        }

    }

    /// The "DefaultIcon" asset catalog image resource.
    static let defaultIcon = ImageResource(name: "DefaultIcon", bundle: resourceBundle)

    /// The "NotFound" asset catalog image resource.
    static let notFound = ImageResource(name: "NotFound", bundle: resourceBundle)

    /// The "Top Shelf Image" asset catalog image resource.
    static let topShelf = ImageResource(name: "Top Shelf Image", bundle: resourceBundle)

    /// The "repeat.slash" asset catalog image resource.
    static let repeatSlash = ImageResource(name: "repeat.slash", bundle: resourceBundle)

    /// The "repeat.slash.black" asset catalog image resource.
    static let repeatSlashBlack = ImageResource(name: "repeat.slash.black", bundle: resourceBundle)

    /// The "repeat.slash.white" asset catalog image resource.
    static let repeatSlashWhite = ImageResource(name: "repeat.slash.white", bundle: resourceBundle)

}

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Hashable {

    /// An asset catalog color resource name.
    fileprivate let name: String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Hashable {

    /// An asset catalog image resource name.
    fileprivate let name: String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: String, bundle: Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// Initialize a `NSImage` with an image resource.
    convenience init(resource: ImageResource) {
        self.init()
        let image = resource.bundle.image(forResource: NSImage.Name(resource.name))!
        self.addRepresentations(image.representations)
        self.isTemplate = image.isTemplate
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif