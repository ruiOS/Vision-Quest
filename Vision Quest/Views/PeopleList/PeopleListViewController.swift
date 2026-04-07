//
//  PeopleListViewController.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

protocol PeopleListViewable: AnyObject {
    func refreshData()
}

final class PeopleListViewController: UIViewController {
    
    private let viewModel: PeopleListViewModelable
    
    private let cellPadding: CGFloat = 16

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = cellPadding
        layout.minimumLineSpacing = cellPadding
        layout.sectionInset = UIEdgeInsets(top: cellPadding, left: cellPadding, bottom: cellPadding, right: cellPadding)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.register(PersonCell.self, forCellWithReuseIdentifier: PersonCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppStrings.peopleListEmptyState
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    init(viewModel: PeopleListViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = AppStrings.peopleListTitle
        view.backgroundColor = .systemBackground
        setupUI()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = (view.bounds.width - (cellPadding * 4)) / 3
        flowLayout.itemSize = CGSize(width: width, height: width + 30) // extra space for name
    }
}

extension PeopleListViewController: PeopleListViewable {
    func refreshData() {
        collectionView.reloadData()
        emptyStateLabel.isHidden = !viewModel.persons.isEmpty
    }
}

extension PeopleListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.persons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PersonCell.identifier, for: indexPath) as! PersonCell
        let person = viewModel.persons[indexPath.item]
        let face = viewModel.getDefaultFace(for: person)
        cell.configure(with: person, defaultFace: face)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = viewModel.persons[indexPath.item]
        viewModel.routeToPersonDetail(person: person)
    }
}
