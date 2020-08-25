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
    func didSelectIndicatorAt(_ index: Int)
}

public final class BitPageControlWithTiming: UIControl
{
    
    //MARK: Public
    
    /// Conform to this protocol to get notified whenever the pageControl animation is compeleted.
    public var delegate: BitPageControlWithTimingDelegate?
    /// Indicates if an indicator is currently animating.
    public var isAnimating: Bool = false
    /// Spacing between indicators. default 4
    public var spacing: CGFloat = 4 { didSet { self.stackView.spacing = spacing } }
    /// Current indicator, changing this value will automatically animate the current indicator. - zero base.
    @objc public dynamic var currentPage: Int = 0 {
        didSet {
            guard (currentPage >= 0 && currentPage <= self.numberOfPages - 1) else {
                currentPage = oldValue
                print("⚠️ The numberOfPages has not been set correctly.")
                return
            }
            self.resetAnchor(self.widthAnchors[oldValue]) { (_) in
                self.startFillAnimation()
            }
        }
    }
    
    private(set) var indicators = [UIView]()
    /// Duration it takes to fill indicators. you can add multiple values, or single value. use setFillingDurationForIndicators method to set the value.
    private(set) var fillAnimationDuration: [CFTimeInterval] = [2.5]
    /// Duration it takes to reset current indicator to inactive size. default 0.25
    public var indicatorCollapseAnimationDuration: TimeInterval = 0.25
    /// The tint color to be used for the page indicator
    @IBInspectable public var pageIndicatorTintColor: UIColor = .lightGray {
        didSet { self.setupIndicators() }
    }
    /// The tint color to be used for the current page indicator
    @IBInspectable public var currentPageIndicatorTintColor: UIColor = .green
    /// If set to true, the dots starts filling one after each other till the end. default is false.
    @IBInspectable public var autoPlay = false
    
    @IBInspectable public var numberOfPages: Int = 0 { didSet { self.setupIndicators() }}
    
    
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
    
    // MARK: - Private methods
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(self.stackView)
        
        addConstraints([
            self.stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            self.stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    private func setupIndicators() {
        
        guard self.numberOfPages > 0 else {
            print("🔴 numberOfPages should be greater than 0")
            return
        }
        
        if !self.indicators.isEmpty {
            self.indicators.removeAll()
            self.widthAnchors.removeAll()
            self.stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        }
        
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
    // reset the active indicator width to default size.
    fileprivate func resetAnchor(_ anchor: NSLayoutConstraint, completion: ((Bool) -> Void)?) {
        anchor.constant = 0
        
        UIView.animate(withDuration: self.indicatorCollapseAnimationDuration, animations: {
            self.layoutSubviews()
        }, completion: completion)
    }
    
    @objc private func indicatorTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        
        self.delegate?.didSelectIndicatorAt(index)
        
        guard index != self.currentPage else { return }
        
        self.animationLayer.removeFromSuperlayer()
        
        self.currentPage = index
        self.sendActions(for: .valueChanged)
    }
    
    // MARK: - Public methods
    
    /// Call this method to start the animation.
    /// You should call this mehod when the view presented.
    public func startFillAnimation() {
        guard self.numberOfPages > 0 else { return }
        
        let anchor = self.widthAnchors[self.currentPage]
        
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
            
            let duration = self.fillAnimationDuration.indices.contains(self.currentPage) == true ? self.fillAnimationDuration[self.currentPage] : self.fillAnimationDuration.last!
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue   = 1
            animation.duration  = duration
            animation.fillMode  = .forwards
            animation.delegate  = self
            animation.isRemovedOnCompletion = !(self.currentPage == self.numberOfPages - 1)
            
            dot.layer.addSublayer(self.animationLayer)
            
            self.animationLayer.add(animation, forKey: "stroke")
        })
    }
    /**
     Set indicators fill animation durations, each indicator may have different animation duration.
     
     The number of elements you add in the parameter doesn't have to match the `numberOfPages`.
     
     i.e: if the `numberOfPages` is 5 and timing parameter is set to [1.2, 3.2] the first indicator animation duration will be 1.2 second
     and the rest of the indicators will have 3.2 seconds animation duration.
     - Parameter durations: array  CFTimeInterval, a single value will take effect for all the indicators.
     */
    public func setFillingDurationForIndicators(_ durations: [CFTimeInterval]) {
        guard durations.count > 0 else {
            print("⚠️ durations parameter should not be empty.")
            return
        }
        
        self.fillAnimationDuration = durations
    }
}

extension BitPageControlWithTiming: CAAnimationDelegate
{
    public func animationDidStart(_ anim: CAAnimation) {
        self.isAnimating = true
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isAnimating = !flag
        
        self.resetAnchor(self.widthAnchors[self.currentPage]) { (_) in
            if self.currentPage == self.numberOfPages - 1 {
                self.delegate?.pageControlDidEnd()
            }
            
            guard flag, self.autoPlay else { return }
            
            if self.currentPage < self.numberOfPages - 1 {
                self.currentPage += 1
                self.sendActions(for: .valueChanged)
            }
        }
    }
}
