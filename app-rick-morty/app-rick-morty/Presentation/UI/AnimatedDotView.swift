//
//  AnimatedDotView.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

import UIKit

class AnimatedDotView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    init(image: UIImage) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        let animatedImageView = UIImageView(image: image)
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        animatedImageView.contentMode = .scaleAspectFit
        addSubview(animatedImageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),

            animatedImageView.topAnchor.constraint(equalTo: topAnchor),
            animatedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animatedImageView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        animatedImageView.alpha = 0.5

        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       options: .repeat,
                       animations: {
            animatedImageView.alpha = 0.1
            animatedImageView.transform = CGAffineTransformMakeScale(2.0, 2.0)
        }, completion: { isFinished in
            if isFinished {
                animatedImageView.alpha = 0.5
                animatedImageView.transform = .identity
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
