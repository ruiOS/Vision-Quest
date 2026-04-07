//
//  FaceBoxView.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit

/// A view that draws a coloured border around a detected face.
/// If the face has an assigned name, a label floats above the box.
final class FaceBoxView: UIView {

    // MARK: - Subviews

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4
        return label
    }()

    // MARK: - Init

    /// - Parameters:
    ///   - frame: The bounding-box rect in the parent coordinate space.
    ///   - face: The detected face whose metadata drives the visual styling.
    init(frame: CGRect, face: DetectedFace) {
        super.init(frame: frame)
        configure(with: face)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Private

    private func configure(with face: DetectedFace) {
        layer.borderWidth = 2
        layer.cornerRadius = 4
        tag = face.id.hashValue

        if let name = face.personName, !name.isEmpty {
            applyNamedStyle(name: name)
        } else {
            layer.borderColor = UIColor.green.cgColor
        }
    }

    private func applyNamedStyle(name: String) {
        layer.borderColor = UIColor.systemBlue.cgColor

        nameLabel.text = name
        nameLabel.sizeToFit()

        let labelWidth = max(nameLabel.frame.width + 8, bounds.width)
        let labelHeight = nameLabel.frame.height + 4
        nameLabel.frame = CGRect(
            x: 0,
            y: -labelHeight - 4,
            width: labelWidth,
            height: labelHeight
        )
        addSubview(nameLabel)
    }
}
