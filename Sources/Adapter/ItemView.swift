import UIKit

public final class ItemView<Cell: AnyObject, Item>: ItemViewConfigurator {
    public static var identifier: String {
        return [
            String(describing: self),
            String(describing: Cell.self),
            String(describing: Item.self)
        ].joined(separator: "-")
    }

    public static var cellClass: AnyClass {
        return Cell.self
    }

    public let item: Item
    public let height: Height

    public var fill: ((Cell, Item, Info) -> Void)?
    public var select: ((Cell, Item, Info) -> Bool)?
    public var deselect: ((Cell, Item, Info) -> Void)?

    public init(_ item: Item,
                _ height: Height = .estimated(96),
                fill: ((Cell, Item, Info) -> Void)? = nil) {
        self.item = item
        self.height = height
        self.fill = fill
    }

    public func fill(_ cell: UIView, _ info: Info) {
        fill?((cell as! Cell), item, info)
    }

    public func didSelect(_ cell: UIView, _ info: Info) -> Bool {
        select?((cell as! Cell), item, info) ?? false
    }

    public func didDeselect(_ cell: UIView, _ info: Info) -> Void {
        deselect?((cell as! Cell), item, info)
    }
}
