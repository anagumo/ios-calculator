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
            let formattedText = formatter.string(from: NSNumber(value: newValue))
            // Replace comma with point to not affect the number displayed
            displayLabel.text = formattedText?.replacingOccurrences(of: ".", with: ",")
        }
        get {
            // Replace comma with point to be able to perform a correct math operation
            guard let displayText = displayLabel.text?.replacingOccurrences(of: ",", with: "."),
                  let formattedNumber = formatter.number(from: displayText) else {
                logger.error("Text format fails")
                return .zero
            }
            return Double(truncating: formattedNumber)
        }
    }
    
    // MARK: Actions
    /// This IBAction receives the "Touch Up Inside" event when user taps in the 0...9 digits
    /// - Parameter sender: a view of type `(UIbutton)` that represent a digit
    @IBAction func didTapDigitOrComma(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {
            logger.error("The button has not text")
            return
        }
        logger.log("Digit tapped: \(buttonText)")
        
        guard let (displayText, digitOrComma) = shouldAddComma(buttonText) else {
            return
        }
        
        if isUserTypingNumber {
            displayLabel.text = displayText + digitOrComma
        } else {
            displayLabel.text = digitOrComma
            isUserTypingNumber = true
        }
    }
    
    /// Predicate to add comma or zero with comma to the digits
    /// - Parameter buttonText: a text of type `(String)` that represent a digit or comma
    /// - Returns: a tuple of type `(String:String)` that represent the display text and the digit with or without comma
    private func shouldAddComma(_ buttonText: String) -> (String, String)? {
        let displayText = displayLabel.text ?? ""
        let didTapComma = buttonText == ","
        
        // Validation to avoid add more than one comma in the first or second number
        if didTapComma && displayText.contains(",") && isUserTypingNumber {
            return nil
        }
        
        // Validation to add 0 after tap comma
        let digitOrComma = didTapComma && !isUserTypingNumber ? "0," : buttonText
        return (displayText, digitOrComma)
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
