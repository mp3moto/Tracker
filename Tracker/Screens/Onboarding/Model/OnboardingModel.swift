import Foundation

final class OnboardingModel {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case firstLaunch
    }
    
    func buttonTapped() -> Bool {
        userDefaults.set(true, forKey: Keys.firstLaunch.rawValue)
        return true
    }
}
