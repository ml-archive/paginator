import NIO

public struct Transformer<Input, Output> {
    let transform: (EventLoopFuture<[Input]>) -> EventLoopFuture<[Output]>

    init(_ transform: @escaping (EventLoopFuture<[Input]>) -> EventLoopFuture<[Output]>) {
        self.transform = transform
    }

    public init(_ transform: @escaping ([Input]) throws -> [Output]) {
        self.transform = { input in
            input.map(transform)
        }
    }

    public init(_ transform: @escaping ([Input]) -> EventLoopFuture<[Output]>) {
        self.transform = { input in
            input.flatMap(transform)
        }
    }

    public init(_ transform: @escaping (Input) throws -> Output) {
        self.transform = { input in
            input.map { try $0.map(transform) }
        }
    }

    public init(_ transform: @escaping (Input) -> EventLoopFuture<Output>) {
        self.transform = { input in
            input.flatMap { EventLoopFuture.whenAll($0.map(transform), eventLoop: input.eventLoop) }
        }
    }
}

extension Transformer where Input == Output {
    public init() {
        self.transform = { $0 }
    }
}
