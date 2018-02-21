//
//  LoadingView.swift
//  LoadingView
//
//  Created by Jim Rhoades on 9/30/17.
//  Copyright © 2017 Jim Rhoades. All rights reserved.
//

import UIKit
/**
 A loading indicator view that shows three circles pulsing in and out.
 
 For convenience use either init(color:) which provides a standard size of 60.0 width and 12.0 height, or init() which provides the same standard size along with a default color.
 
 Otherwise, the size of the circles and the spacing between them will depend on frame size provided during init(frame:) or init(frame: color:).
 */
public class LoadingView: UIView {
    private var color: UIColor
    private var circle1: CircleView!
    private var circle2: CircleView!
    private var circle3: CircleView!
    private let defaultColor = UIColor(white: 0.5, alpha: 0.5)
    private let defaultFrame = CGRect(x: 0.0, y: 0.0, width: 60.0, height: 12.0)
    
    // default frame and color
    public init() {
        self.color = defaultColor
        super.init(frame: defaultFrame)
        setup()
    }
    
    // default frame, user provided color
    public init(color: UIColor) {
        self.color = color
        super.init(frame: defaultFrame)
        setup()
    }
    
    // user provided frame and color
    public init(frame: CGRect, color: UIColor) {
        self.color = color
        super.init(frame: frame)
        setup()
    }
    
    // user provided frame, default color
    public override init(frame: CGRect) {
        self.color = defaultColor
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.color = defaultColor
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        
        let diameter = bounds.height
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        circle1 = CircleView(frame: rect, color: color)
        circle2 = CircleView(frame: rect, color: color)
        circle3 = CircleView(frame: rect, color: color)
        circle1.frame.origin.x = 0
        circle2.frame.origin.x = bounds.width / 2.0 - circle2.frame.size.width / 2.0
        circle3.frame.origin.x = bounds.width - circle3.frame.size.width
        
        addSubview(circle1)
        addSubview(circle2)
        addSubview(circle3)
        
        // start animating the first circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            self.animateCircle(self.circle1)
        })
        
        // animate the second circle after 0.25 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.animateCircle(self.circle2)
        })
        
        // animate the third circle after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
            self.animateCircle(self.circle3)
        })
    }
    
    private func animateCircle(_ circle: CircleView) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseInOut, .beginFromCurrentState], animations: {
            circle.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            circle.alpha = 0.5;
        }, completion: nil)
    }
}

class CircleView: UIView {
    private var color = UIColor.lightGray
    
    init(frame: CGRect, color: UIColor){
        self.color = color
        super.init(frame: frame)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.addEllipse(in: rect)
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
