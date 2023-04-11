import Foundation

typealias Binding<T> = (T) -> Void

final class OnboardingViewModel {
    var onButtonTap: Binding<Bool>?
    
    private let model: OnboardingModel
    
    init(for model: OnboardingModel) {
        self.model = model
    }
    
    func buttonTapped() {
        onButtonTap?(model.buttonTapped())
    }
}
