import Foundation

final class AnalyticsServices: AnalyticsServicesProtocol {
    private let services: [AnalyticsServiceProtocol]
    var isActivated: [Bool] = []
    
    init(services: [AnalyticsServiceProtocol]) {
        self.services = services
        services.enumerated().forEach { [weak self] index, item in
            self?.isActivated.append(item.isActivated)
        }
    }
    
    func openScreen(screen: String) {
        services.enumerated().forEach { [weak self] index, item in
            guard let self = self else { return }
            if self.isActivated[index] {
                item.openScreen(screen: screen)
            }
        }
    }
    
    func closeScreen(screen: String) {
        services.enumerated().forEach { [weak self] index, item in
            guard let self = self else { return }
            if self.isActivated[index] {
                item.closeScreen(screen: screen)
            }
        }
    }
    
    func tapOn(element: String) {
        services.enumerated().forEach { [weak self] index, item in
            guard let self = self else { return }
            if self.isActivated[index] {
                item.tapOn(element: element)
            }
        }
    }
}
