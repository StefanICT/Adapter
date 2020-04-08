//
//  File.swift
//  
//
//  Created by Stefan van der Wolf on 08/04/2020.
//

import UIKit

public class HeaderView {
    public let view: UIView
    public let height: Height

    public init(view: UIView,
                height: Height = .estimated(48)) {
        self.view = view
        self.height = height
    }
}
