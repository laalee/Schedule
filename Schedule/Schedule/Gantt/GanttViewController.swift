//
//  GanttViewController.swift
//  Schedule
//
//  Created by HsinYuLi on 2018/9/20.
//  Copyright © 2018年 laalee. All rights reserved.
//

import UIKit

class GanttViewController: UIViewController {

    @IBOutlet weak var ganttTableView: UITableView!

    var firstFlag: Bool = true

    var header: HeaderTableViewCell?

    var emptyRows: Int = 0

    var categorys: [CategoryMO] = []

    fileprivate var sourceIndexPath: IndexPath?

    fileprivate var snapshot: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        getCategorys()

        updateDatas()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.layoutIfNeeded()

        if firstFlag {

            scrollToToday(animated)

            firstFlag = false
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateEmptyCells()
    }

    private func setupTableView() {

        ganttTableView.dataSource = self

        ganttTableView.delegate = self

        let identifier = String(describing: GanttTableViewCell.self)

        let uiNib = UINib(nibName: identifier, bundle: nil)

        ganttTableView.register(uiNib, forCellReuseIdentifier: identifier)

        let headerIdentifier = String(describing: HeaderTableViewCell.self)

        let headerNib = UINib(nibName: headerIdentifier, bundle: nil)

        ganttTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerIdentifier)
    }

    @IBAction func scrollToToday(_ sender: Any) {

        NotificationCenter.default.post(name: .scrollToToday, object: nil)
    }

    func getCategorys() {

        guard let categorys = CategoryManager.share.getAllCategory() else { return }

        self.categorys = categorys
    }

    func updateEmptyCells() {

        let tableViewHeight = Int(ganttTableView.frame.size.height)

        self.emptyRows = (tableViewHeight / 50) - categorys.count

        if emptyRows <= 0 {

            emptyRows = 1
        }

        ganttTableView.reloadData()
    }

    private func updateDatas() {

        _ = NotificationCenter.default.addObserver(
        forName: .updateCategorys, object: nil, queue: nil) { (_) in

            self.getCategorys()

            self.updateEmptyCells()
        }
    }

}

extension GanttViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categorys.count + emptyRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: GanttTableViewCell.self), for: indexPath)

        tableView.index

        guard let ganttCell = cell as? GanttTableViewCell else {
            return cell
        }

        ganttCell.scrollDelegate = self

        if indexPath.row < categorys.count {

            ganttCell.setCategoryTitle(category: categorys[indexPath.row])
            ganttCell.addButton.isHidden = true
            ganttCell.tableViewTitleLabel.isHidden = false

        } else {

            ganttCell.setCategoryTitle(category: nil)
            ganttCell.addButton.isHidden = indexPath.row != categorys.count
            ganttCell.tableViewTitleLabel.isHidden = indexPath.row != categorys.count
        }

        ganttCell.tableViewTitleLabel.isUserInteractionEnabled = true

        ganttCell.reloadItemCollectionView()

        return ganttCell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: String(describing: HeaderTableViewCell.self))

        guard let headerView = view as? HeaderTableViewCell else {
            return view
        }

        headerView.scrollDelegate = self

        self.header = headerView

        return headerView
    }

}

extension GanttViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 51
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 51
    }

}

extension GanttViewController: GanttScrollDelegate {

    func didScroll(to position: CGPoint) {

        guard let header = ganttTableView.headerView(forSection: 0) as? HeaderTableViewCell else {

            return
        }

        let scrollView = header.dateCollectionView as UIScrollView

        scrollView.bounds.origin = position

        let addBottomCell = scrollView.contentOffset.x > (scrollView.contentSize.width - UIScreen.main.bounds.size.width - 100)

        let addTopCell = scrollView.contentOffset.x < 100

        if addBottomCell {

            header.addBottomCells()
        }

        if addTopCell {

            header.addTopCells()

        }

        for cell in ganttTableView.visibleCells {

            guard let ganttCell = cell as? GanttTableViewCell else { return }

            let scrollView = ganttCell.itemCollectionView as UIScrollView

            scrollView.bounds.origin = position

            if addBottomCell {

                ganttCell.addBottomCells()
            }

            if addTopCell {

                ganttCell.addTopCells()

            }
        }
    }

}
