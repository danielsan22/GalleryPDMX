//
//  PublisherExtensions.swift
//  GalleryPDMX
//
//  Created by Daniel Sanchez on 04/07/23.
//

import Combine
import Foundation

extension Publisher {
    func asyncMap<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
