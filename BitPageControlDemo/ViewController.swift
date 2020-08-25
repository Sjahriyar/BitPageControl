//
//  ViewController.swift
//  BitPageControlDemo
//
//  Created by Wise Sapien on 24/08/2020.
//  Copyright © 2020 Shahriar. All rights reserved.
//

import UIKit
import BitPageControl

class ViewController: UIViewController
{

    @IBOutlet var pageControl: BitPageControlWithTiming!
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageControl.backgroundColor = .clear
        self.pageControl.numberOfPages = 5
        self.pageControl.spacing = 8
        self.pageControl.autoPlay = true
        self.pageControl.setFillingDurationForIndicators([0.5])
        self.pageControl.indicatorCollapseAnimationDuration = 1
        self.pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        self.pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        self.pageControl.delegate = self
        self.pageControl.addTarget(self, action: #selector(pageDidChange), for: .valueChanged)
        
        self.label.text = "Page: \(self.pageControl.currentPage + 1)"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pageControl.startFillAnimation()
    }
    
    @objc func pageDidChange() {
        self.label.text = "Page: \(self.pageControl.currentPage + 1)"
    }
}

extension ViewController: BitPageControlWithTimingDelegate
{
    func didSelectIndicatorAt(_ index: Int) {
        self.label.text = "Page: \(self.pageControl.currentPage + 1)"
    }
    
    func pageControlDidEnd() {
        view.backgroundColor = #colorLiteral(red: 0.2207899094, green: 0, blue: 0.4181671143, alpha: 1)
        
        self.label.textColor = .white
        self.label.text = "Completed"
    }
}
