//
// TriGuide 2025
//

import Foundation
import TriGuideDomain

// MARK: - CalculateFuelingResultUseCase

public protocol CalculateFuelingResultUseCase: UseCase, Sendable {
    func execute(fuelingInput: FuelingInput) -> FuelingResult
}

// MARK: - CalculateFuelingResultUseCaseDefault

public struct CalculateFuelingResultUseCaseDefault {
    // MARK: - Dependencies

    let dataSource: FuelingCalculatorDataSource
}

// MARK: - CalculateFuelingResultUseCase

extension CalculateFuelingResultUseCaseDefault: CalculateFuelingResultUseCase {
    public func execute(fuelingInput: FuelingInput) -> FuelingResult {
        dataSource.calculateFueling(from: fuelingInput)
    }
}
