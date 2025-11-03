//
// TriGuide 2025
//

import Foundation

public struct FormSection {
    public let title: String?
    public let fields: [FieldDescriptor]

    public init(title: String? = nil, fields: [FieldDescriptor]) {
        self.title = title
        self.fields = fields
    }
}
