import UIKit

extension UIColor {
    // Helper method for color retrieval
    private static func color(named name: String, fallback: UIColor = .black) -> UIColor {
        return UIColor(named: name) ?? fallback
    }
    
    // Base Colors
    static let yBackgroundUniversal = color(named: "yBackgroundUniversal")
    static let yBlack = color(named: "yBlack")
    static let yBlackUniversal = color(named: "yBlackUniversal")
    static let yBlueUniversal = color(named: "yBlueUniversal")
    static let yGreyUniversal = color(named: "yGreyUniversal")
    static let yGreenUniversal = color(named: "yGreenUniversal")
    static let yLightGrey = color(named: "yLightGrey")
    static let yRedUniversal = color(named: "yRedUniversal")
    static let yWhite = color(named: "yWhite")
    static let yWhiteUniversal = color(named: "yWhiteUniversal")
    static let yYellowUniversal = color(named: "yYellowUniversal")
    
    // Semantic Colors
    static let primary = yBlueUniversal
    static let secondary = yYellowUniversal
    static let background = yWhiteUniversal
    
    // Text Colors
    static let textPrimary = yBlack
    static let textSecondary = yGreyUniversal
    static let textOnPrimary = yWhite
    static let textOnSecondary = yBlack
    
    // UI Element Colors
    static let segmentActive = yBlack
    static let segmentInactive = yLightGrey
    static let closeButton = yBlack
}
