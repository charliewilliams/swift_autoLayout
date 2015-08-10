//
//  ViewController.swift
//  Auto Layout in Swift 2.0
//
//  Created by Charlie Williams on 22/01/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var buttons: [UIButton]! {
        return [button1, button2, button3, button4, button5];
    }
    
    var buttonConstraints: [NSLayoutConstraint]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateLayout()
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        sender.hidden = true
        updateLayout()
    }
    
    @IBAction func resetPressed(sender: UIButton?) {
        for b in buttons {
            b.hidden = false
        }
        
        updateLayout()
    }
    
    func visibleButtonsWithHeight() -> ([UIButton], CGFloat) {
        
        var visibleButtons: [UIButton] = []
        var totalButtonHeight: CGFloat = 0
        
        for b in buttons {
            
            if !b.hidden {
                visibleButtons.append(b)
                totalButtonHeight += b.bounds.size.height
            }
        }

        return (visibleButtons, totalButtonHeight)
    }

    func updateLayout() {
        
        let (visibleButtons, totalButtonHeight) = visibleButtonsWithHeight()
        
        // Don't allow hiding last button
        guard visibleButtons.count > 0 else {
            resetPressed(nil)
            return
        }
        
        // Calculate how much space each button gets
        let availableHeight = getAvailableHeight() - totalButtonHeight
        let interButtonSpacing = availableHeight / CGFloat(visibleButtons.count + 1)
        
        // Build the format string which is interpretated as constraints
        // 'V:' means we're describing vertical constraints here
        // '|' represents the superview
        // This first line says "from the superview down to the top of the next view, leave at least (interbuttonSpacing) worth of space".
        var formatString = "V:|-(>=\(interButtonSpacing))-"
        
        var views = [String:UIButton]()
        
        for (index, button) in visibleButtons.enumerate() {
            
            let buttonName = "button\(index)"
            var thisSpacing = interButtonSpacing
            
            if index == visibleButtons.count - 1 {
                thisSpacing = interButtonSpacing + toolBar.bounds.size.height
            }
            
            // For each button, we add its name to the format string, along with the spacing to the next button:
            formatString += "[\(buttonName)]-(\(thisSpacing))-"
            
            // And we build a dictionary linking each view to the (arbitrary) name we've given it for Auto Layout purposes
            views[buttonName] = button
        }
        
        // Finally, reference the bottom edge of the superview
        // Otherwise, all of these constraints are just floating in space.
        formatString += "|"
        
        // At this point, on a 4" phone, before hiding any buttons, the format string reads like so:
        // "V:|-(>=51.6667)-[button0]-(51.6667)-[button1]-(51.6667)-[button2]-(51.6667)-[button3]-(51.6667)-[button4]-(95.6667)-|"
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(formatString, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        // Remove the previous constraints to avoid conflict
        if let buttonConstraints = buttonConstraints {
            view.removeConstraints(buttonConstraints)
        }
        
        view.addConstraints(constraints)
        buttonConstraints = constraints
        
        UIView.animateWithDuration(0.6) {
            self.view.layoutIfNeeded()
        }
    }

    func getAvailableHeight() -> CGFloat {
        return view.bounds.size.height - toolBar.bounds.size.height
    }
}

