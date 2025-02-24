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
    @IBOutlet var decimalSeparatorButton: UIButton!
    
    // MARK: Screen state
    private var calculator = Calculator()
    private var isUserTypingNumber: Bool = false
    private var formatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .current
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = Locale.getDecimalSeparator()
        return numberFormatter
    }
    
    private var displayFormatedValue: Double {
        set {
            displayLabel.text = formatter.string(from: NSNumber(value: newValue))
        }
        get {
            guard let displayText = displayLabel.text,
                  let formattedNumber = formatter.number(from: displayText) else {
                logger.error("Text format fails")
                return .zero
            }
            return Double(truncating: formattedNumber)
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButtons()
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
        
        guard let (currentDisplayText, nextValue) = shouldAddComma(buttonText) else {
            logger.error("Not double decimal separator allowed")
            return
        }
        
        if isUserTypingNumber {
            displayLabel.text = currentDisplayText + nextValue
        } else {
            displayLabel.text = nextValue
            isUserTypingNumber = true
        }
    }
    
    /// Predicate to add comma or zero with comma to the digits
    /// - Parameter buttonText: a text of type `(String)` that represent a digit or comma
    /// - Returns: a tuple of type `(String:String)` that represent the display text and the digit with or without comma
    private func shouldAddComma(_ buttonText: String) -> (String, String)? {
        let displayText = displayLabel.text ?? ""
        let isUserTypingComma = buttonText == Locale.getDecimalSeparator()
        
        // Validation to avoid add more than one comma in the first or second number
        guard isUserTypingComma && displayText.contains(Locale.getDecimalSeparator()) && isUserTypingNumber else {
            // Validation to add 0 after tap comma
            let nextValue = isUserTypingComma && !isUserTypingNumber ? "0\(Locale.getDecimalSeparator())" : buttonText
            return (displayText, nextValue)
        }
        
        return nil
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
        displayFormatedValue = .zero // Clear the display
        calculator = Calculator() // Reset complete state
        isUserTypingNumber = false // To not accum digits in the screen as 09
        logger.log("Display cleared")
    }
}

extension ViewController {
    
    /// UI Components customization
    private func customizeButtons() {
        var uiButtonConfiguration = UIButton.Configuration.filled()
        uiButtonConfiguration.baseBackgroundColor = UIColor.calculatorDark
        uiButtonConfiguration.cornerStyle = .capsule
        uiButtonConfiguration.attributedTitle = AttributedString(
            Locale.getDecimalSeparator(),
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 30, weight: .regular),
                .foregroundColor: UIColor.white
            ]))
        decimalSeparatorButton.configuration = uiButtonConfiguration
    }
}
