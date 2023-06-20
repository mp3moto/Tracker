import Foundation
import YandexMobileMetrica

final class AppMetrica: AnalyticsServiceProtocol {
    var isActivated = false
    
    init(key: String) {
        if let configuration = YMMYandexMetricaConfiguration(apiKey: key) {
            YMMYandexMetrica.activate(with: configuration)
            isActivated = true
        }
    }
    
    func openScreen(screen: String) {
        YMMYandexMetrica.reportEvent("open", parameters: ["screen": screen])
    }
    
    func closeScreen(screen: String) {
        YMMYandexMetrica.reportEvent("close", parameters: ["screen": screen])
    }
    
    func tapOn(element: String) {
        YMMYandexMetrica.reportEvent(element + " click")
    }
}
