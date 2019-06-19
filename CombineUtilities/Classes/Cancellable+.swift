//
//  Cancellable+.swift
//  CombineUtilities
//
//  Created by Gabriele Trabucco on 18/06/2019.
//  Copyright © 2019 Gabriele Trabucco. All rights reserved.
//

import Combine

public class CancellableBag: Cancellable {

    private var lock = os_unfair_lock()
    private var cancellables: [Cancellable] = []

    deinit {
        cancel()
    }

    public func append(_ cancellable: Cancellable) {

        synchronized(&lock) {
            cancellables.append(cancellable)
        }
    }

    public func cancel() {
        synchronized(&lock) {
            cancellables.forEach { $0.cancel() }
            cancellables = []
        }
    }
}

public extension Cancellable {

    func cancelled(by bag: CancellableBag) {
        bag.append(self)
    }
}

private func synchronized(_ lock: os_unfair_lock_t, block: () -> Void) {
    os_unfair_lock_lock(lock)
    defer { os_unfair_lock_unlock(lock) }

    block()
}
