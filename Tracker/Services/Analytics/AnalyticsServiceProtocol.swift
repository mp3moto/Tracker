import Foundation

protocol AnalyticsServiceProtocol {
    var isActivated: Bool { get }
    func openScreen(screen: String)
    func closeScreen(screen: String)
    func tapOn(element: String)
}
