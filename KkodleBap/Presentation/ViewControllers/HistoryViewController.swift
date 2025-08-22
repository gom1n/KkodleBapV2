//
//  HistoryViewController.swift
//  KkodleBap
//
//  Created by gomin on 8/23/25.
//

import UIKit
import SnapKit
import Then
import Foundation

struct HistorySection {
    let date: Date          // 자정기준(yyyy-MM-dd)
    var items: [HistoryEntry]
}

final class HistoryGrouper {
    private let cal = Calendar(identifier: .gregorian)

    func buildSections(from entries: [HistoryEntry]) -> [HistorySection] {
        // 최신순으로 정렬
        let sorted = entries.sorted(by: { $0.timestamp > $1.timestamp })

        // 날짜(자정) 단위로 그룹
        var dict: [Date: [HistoryEntry]] = [:]
        for e in sorted {
            let day = cal.startOfDay(for: e.timestamp)
            dict[day, default: []].append(e)
        }

        // 최신 날짜 섹션이 위로
        return dict.keys.sorted(by: >).map { day in
            HistorySection(date: day, items: dict[day] ?? [])
        }
    }
}

struct HistoryEntry: Codable, Equatable, Identifiable {
    let id: UUID
    let timestamp: Date
    let answer: String
    let didWin: Bool
    let imagePath: String?

    init(id: UUID = UUID(), timestamp: Date = Date(), answer: String, didWin: Bool, imagePath: String?) {
        self.id = id
        self.timestamp = timestamp
        self.answer = answer
        self.didWin = didWin
        self.imagePath = imagePath
    }
}

enum HistoryStore {
    private static let key = "kkodle.history.entries"
    private static let defaults = UserDefaults.standard

    static func load() -> [HistoryEntry] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([HistoryEntry].self, from: data)) ?? []
    }

    static func save(_ entries: [HistoryEntry]) {
        let data = try? JSONEncoder().encode(entries)
        defaults.set(data, forKey: key)
    }

    static func add(_ entry: HistoryEntry) {
        var list = load()
        list.append(entry)
        save(list)
    }

    static func delete(id: UUID) {
        var list = load()
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list.remove(at: idx)
            save(list)
        }
    }

    static func clear() {
        defaults.removeObject(forKey: key)
    }
}

final class HistoryViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [HistorySection] = []
    private let grouper = HistoryGrouper()

    private lazy var timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "a h:mm" // 예: 오후 3:21
        return f
    }()

    private lazy var dateHeaderFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        f.dateFormat = "yyyy년 M월 d일 (E)"
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray_0
        self.navigationController?.isNavigationBarHidden = false
        
        configureNavigationBar()
        configureTableView()
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 다른 화면(게임)에서 기록 추가 후 돌아오면 최신 반영
        reloadData()
    }

    // MARK: - UI

    private func configureNavigationBar() {
        navigationItem.title = "과거 내역"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapBack)
        )
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 64
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseID)
    }

    private func reloadData() {
        let all = HistoryStore.load()
        sections = grouper.buildSections(from: all)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateHeaderFormatter.string(from: sections[section].date)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HistoryCell.reuseID, for: indexPath
        ) as! HistoryCell

        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(
            timeText: timeFormatter.string(from: item.timestamp),
            answer: item.answer,
            didWin: item.didWin
        )
        return cell
    }
    
    // 탭 액션
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = sections[indexPath.section].items[indexPath.row]

        if let path = record.imagePath,
           let image = UIImage(contentsOfFile: path) {
            let detailVC = HistoryDetailViewController(image: image)
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // 스와이프 삭제
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, done in
            guard let self else { return }
            let entry = self.sections[indexPath.section].items[indexPath.row]
            HistoryStore.delete(id: entry.id)
            // 로컬 섹션에서도 제거 후 테이블 업데이트
            self.sections[indexPath.section].items.remove(at: indexPath.row)
            if self.sections[indexPath.section].items.isEmpty {
                self.sections.remove(at: indexPath.section)
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
