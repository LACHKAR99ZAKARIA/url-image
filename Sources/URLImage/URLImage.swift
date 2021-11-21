//
//  URLImage.swift
//  
//
//  Created by Dmytro Anokhin on 16/08/2020.
//

import SwiftUI
import DownloadManager
import Model


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
private final class URLImageModel: ObservableObject {

    unowned var service: URLImageService!

    var url: URL?

    /// Unique identifier used to identify an image in cache.
    ///
    /// By default an image is identified by its URL. This is useful for static resources that have persistent URLs.
    /// For images that don't have a persistent URL create an identifier and store it with your model.
    ///
    /// Note: do not use sensitive information as identifier, the cache is stored in a non-encrypted database on disk.
    var identifier: String?

    init() {
    }

    @Published var phase: URLImagePhase = .empty

    func load() {

    }
}


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
public struct URLImage<Content> : View where Content : View {

    @Environment(\.urlImageService) var service: URLImageService

    /// Options passed in the environment.
    @Environment(\.urlImageOptions) var urlImageOptions: URLImageOptions

    public init(url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (URLImagePhase) -> Content) {
        self.url = url
        self.identifier = nil
        self.transaction = transaction
        self.content = content
    }

    public var body: some View {
        if model.service !== service {
            model.service = service
        }

        return content(model.phase)
    }

    private let url: URL?

    /// Unique identifier used to identify an image in cache.
    ///
    /// By default an image is identified by its URL. This is useful for static resources that have persistent URLs.
    /// For images that don't have a persistent URL create an identifier and store it with your model.
    ///
    /// Note: do not use sensitive information as identifier, the cache is stored in a non-encrypted database on disk.
    private let identifier: String?

    private let transaction: Transaction

    @ViewBuilder
    private let content: (URLImagePhase) -> Content

    @StateObject private var model = URLImageModel()
}


@available(macOS 10.15, iOS 14.0, tvOS 13.0, watchOS 6.0, *)
public enum URLImagePhase {

    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(Error)

    /// The loaded image, if any.
    ///
    /// If this value isn't `nil`, the image load operation has finished,
    /// and you can use the image to update the view. You can use the image
    /// directly, or you can modify it in some way. For example, you can add
    /// a ``Image/resizable(capInsets:resizingMode:)`` modifier to make the
    /// image resizable.
    public var image: Image? {
        switch self {
            case .success(let image):
                return image
            default:
                return nil
        }
    }

    /// The error that occurred when attempting to load an image, if any.
    public var error: Error? {
        switch self {
            case .failure(let error):
                return error
            default:
                return nil
        }
    }
}
