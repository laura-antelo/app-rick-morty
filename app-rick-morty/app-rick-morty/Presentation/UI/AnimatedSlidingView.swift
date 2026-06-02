//
//  AnimatedSlidingView.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

import UIKit

class AnimatedSlidingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private let imageCount = 8
    private var imageViews: [AnimatedDotView] = []
    private var slideState: SlideState?

    var onFinished: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeViews()
    }

}

private extension AnimatedSlidingView {
    enum State: String {
        case recognizing
        case failed
        case finished
        case alreadyFinished
    }

    class SlideState {
        private let imageCount: Int

        private var state: State
        private var currentImageIndex: Int?

        init(imageCount: Int) {
            self.imageCount = imageCount
            self.state = .recognizing
        }

        func isFinished() -> Bool {
            return [.finished, .alreadyFinished].contains(state)
        }

        func evaluateSlideInImageIndex(_ imageIndex: Int) -> State {
            switch state {
            case .failed:
                break
            case .finished:
                state = .alreadyFinished
            case .alreadyFinished:
                break
            case .recognizing:
                state = evaluateValidSlideInImageIndex(imageIndex)
            }

            return state
        }

        func evaluateValidSlideInImageIndex(_ imageIndex: Int) -> State {
            if let currentImageIndex {
                if [currentImageIndex, currentImageIndex + 1].contains(imageIndex) {
                    self.currentImageIndex = imageIndex
                    if imageIndex == imageCount - 1 {
                        return .finished
                    }
                    return .recognizing
                }

                self.currentImageIndex = nil
                return .failed
            } else {
                if imageIndex == 0 {
                    currentImageIndex = imageIndex
                    return .recognizing
                }

                self.currentImageIndex = -1
                return .failed
            }
        }
    }

    func initializeViews() {
        guard let image = UIImage(systemName: "arrowshape.right") else {
            return
        }

        let tintedImage = image.withTintColor(.systemRed, renderingMode: .alwaysOriginal)

        imageViews = (0..<imageCount).map { _ in
            AnimatedDotView(image: tintedImage)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / Double(imageCount))
        ])

        var previousImageView: AnimatedDotView?
        imageViews.enumerated().forEach { item in
            let imageView = item.element
            addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                imageView.heightAnchor.constraint(equalTo: heightAnchor),
                imageView.widthAnchor.constraint(equalTo: heightAnchor)
            ])
            if let previousImageView {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: previousImageView.trailingAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
                ])
            }

            previousImageView = imageView
        }
        if let previousImageView {
            NSLayoutConstraint.activate([
                previousImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognized(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc func gestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if let slideState, slideState.isFinished() {
                return
            }
            slideState = SlideState(imageCount: imageCount)
        case .cancelled, .failed:
            if let slideState, slideState.isFinished() {
                return
            }
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.imageViews.forEach() {
                    $0.alpha = 1.0
                    $0.transform = .identity
                }
            }
        default:
            let point = gestureRecognizer.location(in: self)
            let state: State
            var lastIndex: Int?
            if point.y < 0 || point.y > self.frame.height {
                state = .failed
            } else {
                let index = Int(point.x * Double(imageCount) / self.frame.width)
                state = slideState?.evaluateSlideInImageIndex(index) ?? .failed
                lastIndex = index
            }
            switch state {
            case .failed:
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.imageViews.forEach() {
                        $0.alpha = 1.0
                        $0.transform = .identity
                    }
                }
            case .finished:
                UIView.animate(withDuration: 0.5) { [weak self] in
                    self?.imageViews.forEach() {
                        $0.alpha = 0.0
                        $0.transform = CGAffineTransformMakeScale(0.0, 0.0)
                    }
                }
                removeGestureRecognizer(gestureRecognizer)
                onFinished?()
            case .alreadyFinished:
                break
            case .recognizing:
                if let lastIndex {
                    let view = imageViews[lastIndex]
                    UIView.animate(withDuration: 1.0) {
                        view.alpha = 0.0
                        view.transform = CGAffineTransformMakeScale(0.0, 0.0)
                    }
                }
            }
        }
    }
}
