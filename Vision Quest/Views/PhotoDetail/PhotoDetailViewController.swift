//
//  PhotoDetailViewController.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import Photos

protocol PhotoDetailViewable: AnyObject {
    func refreshFaces()
}

final class PhotoDetailViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let viewModel: PhotoDetailViewModelable
    // MARK: - Root view
    private var detailView: PhotoDetailView { view as! PhotoDetailView }
    
    // MARK: - Init
    
    init(viewModel: PhotoDetailViewModelable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        let detailView = PhotoDetailView()
        detailView.delegate = self
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
        viewModel.viewDidLoad()
    }
}

// MARK: - Private
private extension PhotoDetailViewController {
    func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat

        manager.requestImage(
            for: viewModel.asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { [weak self] image, _ in
            guard let self, let image else { return }
            DispatchQueue.main.async {
                self.detailView.image = image
                self.detailView.renderFaces(self.viewModel.faces)
            }
        }
    }
}

// MARK: - PhotoDetailViewDelegate

extension PhotoDetailViewController: PhotoDetailViewDelegate {
    func photoDetailView(_ view: PhotoDetailView, didTapFace face: DetectedFace) {
        viewModel.didTapFace(face)
    }
}

// MARK: - PhotoDetailViewable

extension PhotoDetailViewController: PhotoDetailViewable {
    func refreshFaces() {
        detailView.renderFaces(viewModel.faces)
    }
}
