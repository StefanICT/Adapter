import UIKit

public class TableViewAdapter: NSObject {
    public let tableView: UITableView

    public var sections: [Section] {
        didSet {
            notifySectionsChanged()
        }
    }

    public var registeredCells: Set<String>

    public var isScrolling: Bool {
        return tableView.isDecelerating || tableView.isDragging
    }

    public init(_ tableView: UITableView) {
        self.tableView = tableView

        sections = []

        registeredCells = []

        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    private func notifySectionsChanged() {
        tableView.reloadData()
    }
}

extension TableViewAdapter: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
        guard !sections.isEmpty else {
            return 0
        }

        return sections[section].itemViews.count
    }

    public func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemView = sections[indexPath.section].itemViews[indexPath.row]
        let identifier = type(of: itemView).identifier

        if !registeredCells.contains(identifier) {
            tableView.register(type(of: itemView).cellClass,
                               forCellReuseIdentifier: identifier)
            registeredCells.insert(identifier)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        let info = Info(indexPath: indexPath,
                        isScrolling: isScrolling)
        itemView.fill(cell, info)

        return cell
    }
}

extension TableViewAdapter: UITableViewDelegate {
    public func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].itemViews[indexPath.row].height {
        case .constant(let height):
            return height
        case .estimated:
            return UITableView.automaticDimension
        }
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section].itemViews[indexPath.row].height {
        case .constant(let height):
            return height
        case .estimated(let height):
            return height
        }
    }

    public func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].headerView
    }

    public func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].headerView?.height {
        case .constant(let height):
            return height
        case .estimated:
            return UITableView.automaticDimension
        case .none:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView,
                          estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section].headerView?.height {
        case .constant(let height):
            return height
        case .estimated(let height):
            return height
        case .none:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView,
                          didSelectRowAt indexPath: IndexPath) {
        let itemView = sections[indexPath.section].itemViews[indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let info = Info(indexPath: indexPath,
                        isScrolling: isScrolling)
        if !itemView.didSelect(cell, info) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView,
                          didDeselectRowAt indexPath: IndexPath) {
        let itemView = sections[indexPath.section].itemViews[indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        let info = Info(indexPath: indexPath,
                        isScrolling: isScrolling)
        itemView.didDeselect(cell, info)
    }
}

extension TableViewAdapter: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fillVisibleCells()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                         willDecelerate decelerate: Bool) {
        if !decelerate {
            fillVisibleCells()
        }
    }

    public func fillVisibleCells() {
        for indexPath in (tableView.indexPathsForVisibleRows ?? [IndexPath]()) {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                continue
            }

            let info = Info(indexPath: indexPath,
                            isScrolling: isScrolling)
            sections[indexPath.section].itemViews[indexPath.row].fill(cell, info)
        }
    }
}
