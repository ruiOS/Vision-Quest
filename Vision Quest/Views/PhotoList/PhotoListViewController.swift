//
//  PhotoListViewController.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

protocol PhotoListViewable: AnyObject {
    func set(state: PhotoListViewState<[PhotoWithFaces]>)
    func appendNewPhoto(_ photo: PhotoWithFaces, at index: Int)
}

final class PhotoListViewController: UIViewController {

    private let viewModel: PhotoListViewModelable
    private let collectionContainer = PhotoListCollectionView()
    private let errorView = EmptyStateView(type: .settings)
    private let emptyView = EmptyStateView(type: .noPhotos)

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: PhotoListViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = AppStrings.photoListTitle
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupConstraints()
        setupCollectionBindings()
        
        viewModel.viewDidLoad()
    }

    private func setupUI() {
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionContainer)
        view.addSubview(errorView)
        view.addSubview(emptyView)
        view.addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupCollectionBindings() {
        collectionContainer.dataSource = self
        collectionContainer.delegate = self
    }
}

extension PhotoListViewController: PhotoListViewable {

    func set(state: PhotoListViewState<[PhotoWithFaces]>) {
        switch state {
        case .loading:
            showLoadingState()
        case .success(let photos):
            showContent(hasData: !photos.isEmpty)
        case .error:
            showError()
        }
    }
    
    private func showLoadingState() {
        loadingIndicator.startAnimating()
        errorView.isHidden = true
        emptyView.isHidden = true
        collectionContainer.setHidden(true)
    }

    private func showContent(hasData: Bool) {
        loadingIndicator.stopAnimating()
        errorView.isHidden = true
        emptyView.isHidden = hasData
        collectionContainer.setHidden(!hasData)
        if hasData {
            collectionContainer.reload()
        }
    }
    
    private func showError() {
        loadingIndicator.stopAnimating()
        collectionContainer.setHidden(true)
        emptyView.isHidden = true
        errorView.isHidden = false
    }

    func appendNewPhoto(_ photo: PhotoWithFaces, at index: Int) {
        loadingIndicator.stopAnimating()
        if collectionContainer.getCollectionView().isHidden {
            collectionContainer.setHidden(false)
            errorView.isHidden = true
            emptyView.isHidden = true
        }
        collectionContainer.insert(at: index)
    }
}

extension PhotoListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        let item = viewModel.photos[indexPath.item]
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectPhoto(at: indexPath.item)
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Safe, constraint-driven dynamic sizing
        let width = (collectionView.bounds.width - 4) / 3
        return CGSize(width: width, height: width)
    }
}

