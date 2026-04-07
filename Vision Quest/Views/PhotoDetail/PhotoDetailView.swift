//
//  PhotoDetailView.swift
//  Vision Quest
//
//  Created by Lurdhu Rupesh Kumar Pudota on 07/04/26.
//

import UIKit
import AVFoundation

// MARK: - Delegate

protocol PhotoDetailViewDelegate: AnyObject {
    func photoDetailView(_ view: PhotoDetailView, didTapFace face: DetectedFace)
}

// MARK: - PhotoDetailView

/// The root custom view for the photo detail screen.
/// Owns the `UIImageView`, all `FaceBoxView`s, and the face-drawing logic.
/// The view controller's only responsibilities are: supplying the image + faces,
/// and responding to the `didTapFace` delegate callback.
final class PhotoDetailView: UIView {

    // MARK: - Public interface

    weak var delegate: PhotoDetailViewDelegate?

    /// Set this to display an image and (re)draw face boxes.
    var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
            drawFaces()
        }
    }

    /// Replaces the current set of face overlays.
    func renderFaces(_ faces: [DetectedFace]) {
        self.faces = faces
        drawFaces()
    }

    // MARK: - Subviews

    private let imageView: FaceOverlayImageView = {
        let iv = FaceOverlayImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // MARK: - Private state

    private var faces: [DetectedFace] = []
    private var boxViews: [FaceBoxView] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        drawFaces()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .systemBackground
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Face drawing

    private func drawFaces() {
        guard let image = imageView.image, imageView.bounds.size != .zero else { return }

        clearBoxViews()

        let renderRect = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)

        for face in faces {
            let boxFrame = faceFrame(for: face, in: renderRect)
            let boxView = FaceBoxView(frame: boxFrame, face: face)

            let tap = UITapGestureRecognizer(target: self, action: #selector(faceTapped(_:)))
            boxView.addGestureRecognizer(tap)

            imageView.addSubview(boxView)
            boxViews.append(boxView)
        }
    }

    private func clearBoxViews() {
        boxViews.forEach { $0.removeFromSuperview() }
        boxViews.removeAll()
    }

    private func faceFrame(for face: DetectedFace, in renderRect: CGRect) -> CGRect {
        let x = renderRect.origin.x + CGFloat(face.boundingBoxX) * renderRect.size.width
        let y = renderRect.origin.y + (1 - CGFloat(face.boundingBoxY) - CGFloat(face.boundingBoxHeight)) * renderRect.size.height
        let width = CGFloat(face.boundingBoxWidth) * renderRect.size.width
        let height = CGFloat(face.boundingBoxHeight) * renderRect.size.height
        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - Actions

    @objc private func faceTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        guard let face = faces.first(where: { $0.id.hashValue == tappedView.tag }) else { return }
        delegate?.photoDetailView(self, didTapFace: face)
    }
}

// MARK: - FaceOverlayImageView

/// A `UIImageView` subclass that allows `FaceBoxView` labels that extend   
/// outside the image-view bounds (e.g. name tags sitting above a box) to   
/// remain visible and hittable. Clips-to-bounds is intentionally left off.
private final class FaceOverlayImageView: UIImageView {

    /// Expand the hit-test area so that labels positioned above box views
    /// (y < 0 in the box's local space) still receive touch events.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Walk subviews in reverse (top-most first)
        for subview in subviews.reversed() {
            let converted = subview.convert(point, from: self)
            if let hit = subview.hitTest(converted, with: event) {
                return hit
            }
        }
        return super.hitTest(point, with: event)
    }
}
