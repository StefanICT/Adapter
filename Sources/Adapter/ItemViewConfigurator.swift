import UIKit

public protocol ItemViewConfigurator {
    static var identifier: String { get }
    static var cellClass: AnyClass { get }

    var height: Height { get }

    func fill(_ cell: UIView, _ info: Info)
    func didSelect(_ cell: UIView, _ info: Info) -> Bool
    func didDeselect(_ cell: UIView, _ info: Info) -> Void
}
