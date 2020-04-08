//
//  File.swift
//  
//
//  Created by Stefan van der Wolf on 08/04/2020.
//

import UIKit

public protocol ItemViewConfigurator {
    static var identifier: String { get }

    var height: Height { get }

    func register(in tableView: UITableView)
    func fill(_ cell: UIView)
    func didSelect(_ cell: UIView) -> Bool
    func didDeselect(_ cell: UIView) -> Void
}
