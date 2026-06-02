//
//  AnimatedViewController.swift
//  app-rick-morty
//
//  Created by Jose Servet Font on 2/6/26.
//

import UIKit

class AnimatedViewController: UIViewController {

    let viewModel: AnimatedViewModel

    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var slidingView: AnimatedSlidingView!
    private var gradientIndex = 0
    private let gradientLayer = CAGradientLayer()

    init(viewModel: AnimatedViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "AnimatedViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        continueButton.alpha = 0.0
        slidingView.onFinished = { [weak self] in
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                self?.continueButton.alpha = 1.0
                self?.gradientLayer.opacity = 1.0
                self?.view.bringSubviewToFront(self?.continueButton ?? UIView())
            }, completion: { [weak self] finished in
                if finished {
                    self?.setupAnimationCycle()
                }
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupGradientAnimation()
        gradientLayer.opacity = 0.0
    }

    @IBAction func continueButtonTapped(_ sender: Any) {
        viewModel.didPressNextScreenButton()
    }
}

private extension AnimatedViewController {
    var cgColors: [CGColor] {
        let colors: [UIColor] = [.systemRed, .systemPink,
                                 .systemPurple, .systemBlue,
                                 .systemCyan, .systemGreen,
                                 .systemYellow, .systemOrange]
        return colors.map { $0.cgColor }
    }

    func setupGradientAnimation() {
        gradientLayer.colors = [cgColors[gradientIndex], cgColors[gradientIndex + 1]]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = CGRect(origin: CGPoint.zero, size: view.bounds.size)
        view.layer.addSublayer(gradientLayer)
    }

    func setupAnimationCycle() {
        let colorsAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))

        let colorCount = cgColors.count
        let startIndex = gradientIndex % colorCount
        let endIndex = (gradientIndex + 1) % colorCount
        let newIndex = (gradientIndex + 2) % colorCount
        gradientIndex += 1

        colorsAnimation.fromValue = [cgColors[startIndex], cgColors[endIndex]]
        colorsAnimation.toValue = [cgColors[endIndex], cgColors[newIndex]]
        colorsAnimation.duration = 2.0
        colorsAnimation.delegate = self
        colorsAnimation.fillMode = .forwards
        colorsAnimation.isRemovedOnCompletion = true
        gradientLayer.add(colorsAnimation, forKey: "colors")
    }
}

extension AnimatedViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            setupAnimationCycle()
        }
    }
}
