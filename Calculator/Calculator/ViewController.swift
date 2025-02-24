//
//  ViewController.swift
//  Calculator
//
//  Created by Ariana Rodríguez on 23/02/25.
//

import UIKit
import OSLog

class ViewController: UIViewController {
    private let logger = Logger(subsystem: "Calculator", category: "Developer")
    
    // MARK: UI Components
    @IBOutlet var displayLabel: UILabel!
    
    // MARK: Screen state
    private var calculator = Calculator()
    private var isUserTypingNumber: Bool = false
    private var formatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }
    
    private var displayFormatedValue: Double {
        set {
            displayLabel.text = formatter.string(from: NSNumber(value: newValue))
        }
        get {
            guard let displayText = displayLabel.text,
                  let formattedNumber = formatter.number(from: displayText) else {
                return .zero
            }
            return Double(truncating: formattedNumber)
        }
    }
    
    // MARK: Actions
    /// This IBAction receives the "Touch Up Inside" event when user taps in the 0...9 digits
    /// - Parameter sender: a view of type `(UIbutton)` that represent a digit
    @IBAction func didTapDigit(_ sender: UIButton) {
        guard let digitText = sender.titleLabel?.text else {
            logger.error("The button has not text")
            return
        }
        logger.log("Digit tapped: \(digitText)")
        
        let currentDisplayText = displayLabel.text ?? ""
        if isUserTypingNumber {
            displayLabel.text = currentDisplayText + digitText
        } else {
            displayLabel.text = digitText
            isUserTypingNumber = true
        }
    }
    
    /// This IBAction receives the "Touch Up Inside" event when user taps in the operators
    /// - Parameter sender: a view of type `(UIbutton)` that represent an operator
    @IBAction func didTapOperator(_ sender: UIButton) {
        guard let operatorText = sender.titleLabel?.text else {
            logger.error("The button has not text")
            return
        }
        logger.log("Operator tapped: \(operatorText)")
        
        if isUserTypingNumber {
            calculator.setOperand(displayFormatedValue)
            isUserTypingNumber = false
        }
        
        calculator.performOperation(operatorText)
        displayFormatedValue = calculator.result ?? .zero
    }
    
    /// This IBAction receives the "Touch Up Inside" event when user taps in the clear button
    /// - Parameter sender: a view of type `(UIbutton)` that represent a clear action
    @IBAction func didTapClearDisplay(_ sender: UIButton) {
        logger.log("Clear button tapped")
        displayFormatedValue = .zero // Clears the display
        calculator.accumulator = 0 // Resets calculator data
        calculator.pendingBinaryOperation = nil // Resets calculator pending operation
        isUserTypingNumber = false // To not accum digits in the screen as 09
    }
}
