//
//  File.swift
//  
//
//  Created by Stefan van der Wolf on 08/04/2020.
//

import UIKit

public final class ItemView<Cell: UITableViewCell, Item>: ItemViewConfigurator {
    public static var identifier: String {
        return [
            String(describing: self),
            String(describing: Cell.self),
            String(describing: Item.self)
        ].joined(separator: "-")
    }

    public let item: Item
    public let height: Height

    public var fill: ((Cell, Item) -> Void)?
    public var select: ((Item, Cell) -> Bool)?
    public var deselect: ((Item, Cell) -> Void)?

    public init(item: Item,
                height: Height = .estimated(96),
                fill: ((Cell, Item) -> Void)? = nil) {
        self.item = item
        self.height = height
        self.fill = fill
    }

    public func register(in tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: Self.identifier)
    }

    public func fill(_ cell: UIView) {
        fill?((cell as! Cell), item)
    }

    public func didSelect(_ cell: UIView) -> Bool {
        select?(item, (cell as! Cell)) ?? false
    }

    public func didDeselect(_ cell: UIView) -> Void {
        deselect?(item, (cell as! Cell))
    }
}
