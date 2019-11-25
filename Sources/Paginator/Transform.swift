import Vapor

public struct TransformingQuery<Query, Result, TransformedResult: Codable> {
    public let source: Query
    public let transform: ([Result]) throws -> Future<[TransformedResult]>
}

public protocol Transformable {
    associatedtype TransformableQuery
    associatedtype TransformableQueryResult

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> T
    ) throws -> TransformingQuery<TransformableQuery, TransformableQueryResult, T>

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> Future<T>
    ) throws -> TransformingQuery<TransformableQuery, TransformableQueryResult, T>

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping ([TransformableQueryResult]) throws -> Future<[T]>
    ) throws -> TransformingQuery<TransformableQuery, TransformableQueryResult, T>
}

public extension Transformable {
    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> T
    ) throws -> TransformingQuery<TransformableQuery, TransformableQueryResult, T> {
        let newTransform: (TransformableQueryResult) throws -> Future<T> = { result in
            return try req.future(transform(result))
        }

        return try self.transform(on: req, newTransform)
    }

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping (TransformableQueryResult) throws -> Future<T>
    ) -> TransformingQuery<Self, Self.TransformableQueryResult, T> {
        let newTransform: ([TransformableQueryResult]) throws -> Future<[T]> = { result in
            try result.map { try transform($0) }.flatten(on: req)
        }

        return TransformingQuery(source: self, transform: newTransform)
    }

    func transform<T: Codable>(
        on req: Request,
        _ transform: @escaping ([TransformableQueryResult]) throws -> Future<[T]>
    ) -> TransformingQuery<Self, Self.TransformableQueryResult, T> {
        return TransformingQuery(source: self, transform: transform)
    }
}
