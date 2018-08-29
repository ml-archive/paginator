import Vapor

public struct TransformingQuery<Query, Result, TransformedResult: Codable> {
    let query: Query
    let transform: (Result) throws -> Future<TransformedResult>
}

protocol Transformable {
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
}
