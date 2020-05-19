public class Section {
    public var headerView: HeaderView?
    public var itemViews: [ItemViewConfigurator]

    public init(headerView: HeaderView? = nil,
                itemViews: [ItemViewConfigurator] = []) {
        self.headerView = headerView
        self.itemViews = itemViews
    }
}
