import Foundation
import UIKit

struct OnboardingSlideViewModel {
    let title: String
    let description: String
    let image: UIImage
    let isLastSlide: Bool
    let actionButtonTitle: String
    
    var closeAction: (() -> Void)?
    var actionButtonAction: (() -> Void)?
}

final class OnboardingViewModel {
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: String.localizable(.onboardingSlide1Title),
            description: String.localizable(.onboardingSlide1Description),
            image: UIImage(named: "Slide1")!
        ),
        OnboardingSlide(
            title: String.localizable(.onboardingSlide2Title),
            description: String.localizable(.onboardingSlide2Description),
            image: UIImage(named: "Slide2")!
        ),
        OnboardingSlide(
            title: String.localizable(.onboardingSlide3Title),
            description: String.localizable(.onboardingSlide3Description),
            image: UIImage(named: "Slide3")!
        )
    ]
    
    func getSlideViewModel(for index: Int) -> OnboardingSlideViewModel? {
        guard index >= 0 && index < slides.count else { return nil }
        let slide = slides[index]
        return OnboardingSlideViewModel(
            title: slide.title,
            description: slide.description,
            image: slide.image,
            isLastSlide: index == slides.count - 1,
            actionButtonTitle: index == slides.count - 1
            ? String.localizable(.onboardingSlide3Button) // "Завершить"
            : String.localizable(.onboardingSlide1Title)
        )
    }
    
    func numberOfSlides() -> Int {
        return slides.count
    }
    
    func canGoToNextSlide(from index: Int) -> Bool {
        return index < slides.count - 1
    }
    
    func isFirstSlide(index: Int) -> Bool {
        return index == 0
    }
    
    func isLastSlide(index: Int) -> Bool {
        return index == slides.count - 1
    }
    
    func indexOfSlide(withTitle title: String?) -> Int? {
        return slides.firstIndex { $0.title == title }
    }
}
