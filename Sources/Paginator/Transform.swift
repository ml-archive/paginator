import Vapor

// MARK: Convenience for transformation

public extension Future where T: Paginator {
    public func transform<C: Paginator>(
        transform: @escaping ([T.Object]) -> [C.Object]
    ) -> Future<C> where T.PaginatorMetaData == C.PaginatorMetaData {
        return self.map { paginator in
            let transformed = paginator.data.map { transform($0) }
            return try C.init(data: transformed ?? [], meta: paginator.metaData())
        }
    }

    public func transform<C: Paginator>(
        transform: @escaping ([T.Object]) throws -> Future<[C.Object]>
    ) -> Future<C> where T.PaginatorMetaData == C.PaginatorMetaData {
        return self
            .flatMap { paginator in
                try transform(paginator.data ?? [])
                    .map { try C.init(data: $0, meta: paginator.metaData()) }
            }
    }

    public func transform<C: Paginator>(
        transform: @escaping (T.Object) -> C.Object
    ) -> Future<C> where T.PaginatorMetaData == C.PaginatorMetaData {
        return self.map { paginator in
            let transformed = paginator.data?.map { transform($0) }
            return try C.init(data: transformed ?? [], meta: paginator.metaData())
        }
    }

    public func transform<C: Paginator>(
        transform: @escaping (T.Object) throws -> Future<C.Object>, on req: Request
    ) -> Future<C> where T.PaginatorMetaData == C.PaginatorMetaData {
        return self.flatMap { paginator in
            let transformed = try paginator.data?
                .map { try transform($0) }
                .flatten(on: req)
                ?? Future.transform(to: [], on: req)

            return transformed.map {
                try C.init(data: $0, meta: paginator.metaData())
            }
        }
    }
}
