//
//  PersonDetailViewController.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

final class PersonDetailViewController: UIViewController {
    
    private let viewModel: PersonDetailViewModelable
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.register(FaceCell.self, forCellWithReuseIdentifier: FaceCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    init(viewModel: PersonDetailViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.personName
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension PersonDetailViewController: PersonDetailViewable {
    func refreshData() {
        collectionView.reloadData()
    }
}

// MARK: - PhotoDetailToPersonDelegate
extension PersonDetailViewController: PhotoDetailToPersonDelegate {
    func personDidChange(newPersonId: UUID, newPersonName: String) {
        viewModel.updatePersonId(newPersonId, name: newPersonName)
        title = newPersonName
    }
}

extension PersonDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.faces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FaceCell.identifier, for: indexPath) as! FaceCell
        let item = viewModel.faces[indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 4) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFace = viewModel.faces[indexPath.item]
        guard let payload = viewModel.getRoutingPayload(for: selectedFace) else { return }
        let detailVC = PhotoDetailBuilder.build(with: payload.0, faces: payload.1)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let face = viewModel.faces[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let makeDefaultAction = UIAction(
                title: AppStrings.makeDefaultProfile,
                image: UIImage(systemName: "person.crop.circle.badge.checkmark")
            ) { _ in
                self?.viewModel.setAsDefaultFace(for: face)
            }
            return UIMenu(title: "", children: [makeDefaultAction])
        }
    }
}
