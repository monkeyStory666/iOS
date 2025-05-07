// Copyright © 2025 MEGA Limited. All rights reserved.

import Foundation
import MEGAInfrastructure
import MEGAPresentation

public final class DataUsageScreenViewModel: ViewModel<DataUsageScreenViewModel.Route> {
    public enum Route {
        case agreed
        case dismissed
    }

    public var title: String {
        localization?.title() ?? ""
    }

    public var subtitle: AttributedString {
        localization?.subtitle() ?? ""
    }

    public var buttonTitle: String {
        localization?.agreeButtonTitle() ?? ""
    }

    static let dataUsageCacheKey = "dataUsageDisplayed"

    private let localization: DataUsageScreenLocalization?
    private let permanentCacheService: any CacheServiceProtocol

    public init(
        localization: DataUsageScreenLocalization?,
        permanentCacheService: some CacheServiceProtocol
    ) {
        self.localization = localization
        self.permanentCacheService = permanentCacheService
    }

    public func didTapCloseButton() {
        routeTo(.dismissed)
    }

    public func didTapAgreeButton() {
        try? permanentCacheService.save(true, for: Self.dataUsageCacheKey)
        routeTo(.agreed)
    }
}
