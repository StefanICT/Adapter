//
//  File.swift
//  
//
//  Created by Stefan van der Wolf on 08/04/2020.
//

public class Section {
    public var headerView: HeaderView?
    public var itemViews: [ItemViewConfigurator]

    public init(headerView: HeaderView? = nil,
                itemViews: [ItemViewConfigurator] = []) {
        self.headerView = headerView
        self.itemViews = itemViews
    }
}
