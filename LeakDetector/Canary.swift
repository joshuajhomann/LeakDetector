//
//  Canary.swift
//  LeakDetector
//
//  Created by Joshua Homann on 6/4/23.
//

import Foundation

final class Canary {
    private let name: String
    init<T>(for type: T.Type) {
        name = String(describing: type)
        Task.detached { [name] in
            await TattleTale.shared.register(name)
        }
    }

    deinit {
        Task.detached { [name] in
            await TattleTale.shared.unregister(name)
        }
    }
}
