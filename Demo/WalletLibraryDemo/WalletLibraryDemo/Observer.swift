//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

import Foundation

/// Generic observer
public class Observer<Type>
{
    var listener: ((Type)->Void)?

    /// The current value
    public var value: Type {
        didSet {
            listener?(value)
        }
    }

    init(_ value: Type)
    {
        self.value = value
    }

    /// Callback invoked on value change.
    func bind(listener: @escaping (Type)->Void)
    {
        self.listener = listener
        listener(value)
    }
}
