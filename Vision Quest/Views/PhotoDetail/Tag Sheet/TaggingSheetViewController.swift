//
//  TaggingSheetViewController.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

// MARK: - TaggingSheetViewable
protocol TaggingSheetViewable: AnyObject {
    func reloadSuggestions()
    func setSaveEnabled(_ enabled: Bool)
    func dismissSheet()
}

// MARK: - TaggingSheetViewController
final class TaggingSheetViewController: UIViewController {

    // MARK: Dependencies

    private let viewModel: TaggingSheetViewModelable

    // MARK: UI

    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = AppStrings.taggingSheetTitle
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        return lbl
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.placeholder = AppStrings.taggingSheetSearchPlaceholder
        sb.searchBarStyle = .minimal
        sb.returnKeyType = .done
        return sb
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(PersonSuggestionCell.self, forCellReuseIdentifier: PersonSuggestionCell.identifier)
        tv.keyboardDismissMode = .onDrag
        return tv
    }()

    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = AppStrings.taggingSheetAddNewTag
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .systemBlue
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Init

    init(viewModel: TaggingSheetViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.viewDidLoad()
    }
}

// MARK: - Private setup

private extension TaggingSheetViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        searchBar.searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        view.addSubview(headerLabel)
        view.addSubview(searchBar)
        view.addSubview(saveButton)
        view.addSubview(tableView)

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func searchTextChanged() {
        viewModel.didChangeSearchText(searchBar.text ?? "")
    }

    @objc func saveButtonTapped() {
        viewModel.didConfirmNewTag(name: searchBar.text ?? "")
    }
}

// MARK: TaggingSheetViewable

extension TaggingSheetViewController: TaggingSheetViewable {
    func reloadSuggestions() {
        tableView.reloadData()
    }

    func setSaveEnabled(_ enabled: Bool) {
        saveButton.isEnabled = enabled
    }

    func dismissSheet() {
        dismiss(animated: true)
    }
}

// MARK: UITableViewDataSource & UITableViewDelegate

extension TaggingSheetViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.displayRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = viewModel.displayRows[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PersonSuggestionCell.identifier,
            for: indexPath
        ) as! PersonSuggestionCell
        cell.configure(with: row.person, defaultFace: row.defaultFace)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectPerson(viewModel.displayRows[indexPath.row].person)
    }
}

// MARK: UISearchBarDelegate

extension TaggingSheetViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
