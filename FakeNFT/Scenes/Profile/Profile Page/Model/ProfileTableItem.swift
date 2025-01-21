import UIKit

struct ProfileTableItem {
    let title: String
    let count: Int?
    let destinationProvider: () -> UIViewController
}
