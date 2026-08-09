//
//  WorkspaceImageStore.swift
//  Kuma
//
//  Hardware Image Downsampling & NSCache Manager.
//  Prevents memory leaks and spikes by downsampling images via ImageIO.
//

import AppKit
import Foundation
import ImageIO
import os

public final class WorkspaceImageStore: @unchecked Sendable {
    public static let shared = WorkspaceImageStore()
    
    private let cache = NSCache<NSString, NSImage>()
    
    private init() {
        cache.countLimit = 100
    }
    
    /// Loads and downsamples an image from URL to target max dimension using ImageIO.
    public func thumbnail(for url: URL, maxDimension: CGFloat = 256) -> NSImage? {
        let key = url.path as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            KumaLogger.ui.error("Failed to create image source for URL: \(url.path)")
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]
        
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            KumaLogger.ui.error("Failed to generate thumbnail for URL: \(url.path)")
            return nil
        }
        
        let thumbnail = NSImage(cgImage: thumbnailRef, size: NSSize(width: maxDimension, height: maxDimension))
        cache.setObject(thumbnail, forKey: key)
        return thumbnail
    }
    
    /// Clears the in-memory image cache.
    public func clearCache() {
        cache.removeAllObjects()
    }
}
