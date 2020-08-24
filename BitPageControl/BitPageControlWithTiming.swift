//
//  BitPageControlWithTiming.swift
//  BitPageControl
//
//  Created by Shahriyar Soheytizadeh on 24/08/2020.
//  Copyright © 2020 Shahriar. All rights reserved.
//

import UIKit

public protocol BitPageControlWithTimingDelegate: class
{
    func pageControlDidEnd()
}

public final class BitPageControlWithTiming: UIControl
{
    
    //MARK: Public
    
    /// Conform to this protocol to get notified whenever the pageControl animation is compeleted.
    public var delegate: BitPageControlWithTimingDelegate?
    /// Indicates if an indicator is animating.
    public var isAnimation: Bool = false
    
    /// Spacing between indicators. default 4
    public var spacing: CGFloat = 4 { didSet { self.stackView.spacing = spacing } }
    /// Current indicator, changing this value will automatically animate the current indicator.
    public var currentPage: Int = 0 {
        didSet {
            guard currentPage <= self.numberOfPages - 1 else {
                print("🔴 The current number has not been set correctly.")
                return
            }
            self.resetAnchor(self.widthAnchors[oldValue]) { (_) in
                self.startFillAnimation()
            }
        }
    }
    /// Duration it takes to fill indicators. you can add multiple values, or single value.
    public var fillAnimationDuration: [CFTimeInterval] = [3] {
        didSet {
            guard fillAnimationDuration.count <= numberOfPages else {
                print("🔴 fillAnimationDuration count should match numberOfPages")
                return
            }
        }
    }
    /// The tint color to be used for the page indicator
    @IBInspectable public var pageIndicatorTintColor: UIColor = .lightGray
    /// The tint color to be used for the current page indicator
    @IBInspectable public var currentPageIndicatorTintColor: UIColor = .green
    /// If set to true, the dots starts filling one after each other till the end. default is false.
    @IBInspectable public var autoPlay = false
    
    @IBInspectable public var numberOfPages: Int = 4 {
        didSet { self.setupIndicators() }
    }
    
    private(set) var indicators = [UIView]()
    
    // MARK: Privates
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = self.spacing
        sv.distribution = .fill
        sv.alignment = .center
        
        return sv
    }()
    
    private var widthAnchors = [NSLayoutConstraint]()
    private var lastExpandedAnchor: NSLayoutConstraint?
    private var animationLayer = CAShapeLayer()
    
    required init() {
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupView()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupCornerRadiuses()
    }
    
    private func setupView() {
        addSubview(self.stackView)
        
        addConstraints([
            self.stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            self.stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        
        self.setupIndicators()
    }
    
    private func setupIndicators() {
        self.indicators.removeAll()
        
        for number in 0 ..< self.numberOfPages {
            let dot = UIView()
            dot.tag = number
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.backgroundColor = self.pageIndicatorTintColor.cgColor
            dot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.indicatorTapped(_:))))
            dot.layer.masksToBounds = true
            
            self.indicators.append(dot)
            self.stackView.addArrangedSubview(dot)
            
            dot.heightAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.45, constant: 0).isActive = true
            let width = dot.widthAnchor.constraint(equalTo: self.stackView.heightAnchor, multiplier: 0.45, constant: 0)
            width.isActive = true
            
            self.widthAnchors.append(width)
        }
        
        self.stackView.layoutIfNeeded()
    }
    
    private func setupCornerRadiuses() {
        self.stackView.layoutIfNeeded()
        
        self.indicators.forEach({ $0.layer.cornerRadius = $0.frame.height / 2 })
    }
    
    fileprivate func resetAnchor(_ anchor: NSLayoutConstraint, completion: ((Bool) -> Void)?) {
        anchor.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutSubviews()
        }, completion: completion)
    }
    
    @objc private func indicatorTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag, index != self.currentPage else { return }
        
        self.animationLayer.removeFromSuperlayer()
        
        let anchor = self.widthAnchors[self.currentPage]
        
        self.resetAnchor(anchor) { (_) in
            self.currentPage = index
        }
        
        sendActions(for: .valueChanged)
    }
    /// Whenever you need to play the animation, call this method, alternately set the currentPage value to 0 or other pages to start the animation.
    public func startFillAnimation() {
        let anchor = self.widthAnchors[self.currentPage]
        
        self.animationLayer.removeFromSuperlayer()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            
        }) { (_) in
            
            let dot = self.indicators[self.currentPage]
            anchor.constant += dot.frame.width * 2
            
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
                
            }, completion: { (_) in
                
                let barPath = UIBezierPath()
                barPath.move(to: .zero)
                barPath.addLine(to: CGPoint(x: dot.bounds.maxX, y: 0))
                
                self.animationLayer.position = CGPoint(x: 0, y: dot.bounds.midY - barPath.bounds.height / 2)
                self.animationLayer.path = barPath.cgPath
                self.animationLayer.lineCap = .round
                self.animationLayer.strokeColor = self.currentPageIndicatorTintColor.cgColor
                self.animationLayer.fillColor = nil
                self.animationLayer.lineWidth = dot.frame.height
                
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue   = 1
                animation.duration  = self.fillAnimationDuration[self.currentPage]
                animation.fillMode  = .forwards
                animation.delegate  = self
                animation.isRemovedOnCompletion = true
                
                dot.layer.addSublayer(self.animationLayer)
                
                self.animationLayer.add(animation, forKey: nil)
            })
        }
    }
}

extension BitPageControlWithTiming: CAAnimationDelegate
{
    public func animationDidStart(_ anim: CAAnimation) {
        self.isAnimation = true
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isAnimation = false
        
        if self.currentPage == self.numberOfPages - 1 {
            self.delegate?.pageControlDidEnd()
        }
        guard flag, self.autoPlay else { return }
        
        sendActions(for: .valueChanged)
        self.animationLayer.removeFromSuperlayer()
        
        let anchor = self.widthAnchors[self.currentPage]
        anchor.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
            
        }) { (_) in
            if self.currentPage < self.indicators.endIndex - 1 {
                self.currentPage += 1
            }
        }
    }
}
