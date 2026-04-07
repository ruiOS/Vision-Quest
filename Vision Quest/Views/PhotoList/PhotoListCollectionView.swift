//
//  PhotoListCollectionView.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 08/04/26.
//

import UIKit

final class PhotoListCollectionView: UIView {

    private let collectionView: UICollectionView
    
    var dataSource: UICollectionViewDataSource? {
        didSet { collectionView.dataSource = dataSource }
    }
    
    var delegate: UICollectionViewDelegate? {
        didSet { collectionView.delegate = delegate }
    }
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func reload() {
        collectionView.reloadData()
    }
    
    func insert(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    
    func setHidden(_ hidden: Bool) {
        collectionView.isHidden = hidden
    }
    
    func getCollectionView() -> UICollectionView {
        return collectionView
    }
}
