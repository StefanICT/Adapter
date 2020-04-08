import Foundation
import UIKit

public class Adapter: NSObject {
    private let tableView: UITableView

    public var headerView: UIView? {
        didSet {
            reloadHeaderView()
        }
    }

    public var sections: [Section] {
        didSet {
            registerCells()
            reloadData()
        }
    }

    private var observationHeaderViewIsHidden: NSKeyValueObservation?

    private var registeredCells: Set<String>

    private var width: CGFloat
    private var observationFrame: NSKeyValueObservation?

    public init(tableView: UITableView) {
        self.tableView = tableView

        sections = []

        registeredCells = []

        width = 0

        super.init()

        observationFrame = self.tableView.layer.observe(\.frame) { [weak self] _, _ in
            self?.updateHeaderView()
        }

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    private func registerCells() {
        for section in sections {
            for itemView in section.itemViews {
                let identifier = type(of: itemView).identifier
                if !registeredCells.contains(identifier) {
                    itemView.register(in: tableView)
                    registeredCells.insert(identifier)
                }
            }
        }
    }

    public func reloadData() {
        reloadHeaderView()
        tableView.reloadData()
    }

    public func reloadHeaderView() {
        width = 0
        updateHeaderView()
    }

    private func updateHeaderView() {
        guard let headerView = headerView else {
            observationHeaderViewIsHidden = nil
            tableView.tableHeaderView = nil
            return
        }

        observationHeaderViewIsHidden = headerView.layer.observe(\.isHidden) { [weak self] _, _ in
            self?.reloadHeaderView()
        }

        guard !headerView.isHidden else {
            tableView.tableHeaderView = nil
            return
        }

        guard tableView.frame.size.width != width else {
            return
        }

        headerView.frame = headerFooterSystemLayoutSizeFitting(headerView)

        tableView.tableHeaderView = headerView

        width = tableView.frame.size.width
    }

    private func headerFooterSystemLayoutSizeFitting(_ view: UIView) -> CGRect {
        let targetSize = CGSize(width: tableView.frame.size.width,
        height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize,
                                     withHorizontalFittingPriority: .required,
                                     verticalFittingPriority: .defaultLow)

        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

extension Adapter: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
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

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                 for: indexPath)
        itemView.fill(cell)

        return cell
    }
}

extension Adapter: UITableViewDelegate {
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
        return sections[section].headerView?.view
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

        if !itemView.didSelect(cell) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        let itemView = sections[indexPath.section].itemViews[indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        itemView.didDeselect(cell)
    }
}

extension Adapter: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        fillVisibleCells()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            fillVisibleCells()
        }
    }

    private func fillVisibleCells() {
        for indexPath in (tableView.indexPathsForVisibleRows ?? [IndexPath]()) {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                continue
            }

            sections[indexPath.section].itemViews[indexPath.row].fill(cell)
        }
    }
}

