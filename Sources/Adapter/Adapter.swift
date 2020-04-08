import Foundation
import UIKit

public class Adapter: NSObject {
    private let tableView: UITableView

    public var headerView: UIView?

    public var sections: [Section] {
        didSet {
            registerCells()
            notifySectionsChanged()
        }
    }

    private var registeredCells: Set<String>

    private var width: CGFloat

    public init(tableView: UITableView) {
        self.tableView = tableView

        sections = []

        registeredCells = []

        width = 0

        super.init()

        self.tableView.setNeedsLayout()

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

    public func notifySectionsChanged() {
        updateHeaderView(force: true)
        updateHeaderView()
        tableView.reloadData()
    }

    /// Update the header view and the layout.
    ///
    /// This method must be called in the UIViewController the assure correct
    /// layout in different sizes. Example:
    ///
    /// ```
    /// override func viewDidLayoutSubviews() {
    ///     super.viewDidLayoutSubviews()
    ///
    ///     adapter.updateHeaderView()
    /// }
    ///
    /// override func viewWillTransition(to size: CGSize,
    ///                                  with coordinator: UIViewControllerTransitionCoordinator) {
    ///     super.viewWillTransition(to: size, with: coordinator)
    ///
    ///     coordinator.animate(alongsideTransition: { _ in
    ///         self.adapter.updateHeaderView()
    ///     })
    /// }
    /// ```
    ///
    /// - Parameter force: Force an update of the view. This can be needed if
    ///   the size of the view has changed. For example an label has new text.
    public func updateHeaderView(force: Bool = false) {
        guard let headerView = headerView else {
            tableView.tableHeaderView = nil
            return
        }

        // Make sure we have a size otherwise we cannot layout. Sometimes we get
        // a valid width but an invalid height. To avoid calculating layout we
        // wait on some height as well.
        guard tableView.frame.size.width > 0 && tableView.frame.size.height > 0 else {
            return
        }

        // Short circuit work here
        guard tableView.frame.size.width != width || force else {
            return
        }

        headerView.frame = headerFooterSystemLayoutSizeFitting(headerView)

        tableView.tableHeaderView = headerView

        // Save width for next cycle.
        width = tableView.frame.size.width
    }

    private func headerFooterSystemLayoutSizeFitting(_ view: UIView,
                                                     width: CGFloat) -> CGSize {
        let targetSize = CGSize(width: width,
                                height: UIView.layoutFittingCompressedSize.height)
        return view.systemLayoutSizeFitting(targetSize,
                                            withHorizontalFittingPriority: .required,
                                            verticalFittingPriority: .defaultLow)
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
