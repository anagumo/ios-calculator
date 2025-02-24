//
//  Calculator.swift
//  Calculator
//
//  Created by Ariana Rodríguez on 23/02/25.
//

import Foundation

/// Define the calculator operations
/// First has a binary operation for sum, subtract, division and multiplication
/// Second has the equal, it is going to print the result
enum Operation {
    case binaryOperation((Double, Double) -> (Double))
    case equal
}

struct Calculator {
    /// Saves the first operand, the second one and the result
    var accumulator: Double?
    /// This dic maps the operator button text into an operation `(Operation)`
    let operations: [String: Operation] = [
        "+" : Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "x": Operation.binaryOperation(*),
        "/": Operation.binaryOperation(/),
        "=": Operation.equal
    ]
    
    var pendingBinaryOperation: PendingBinaryOperation?
    var resultIsPending: Bool {
        pendingBinaryOperation != nil
    }
    
    /// Sets the second number in the accumulator
    mutating func setOperand(_ number: Double) {
        accumulator = number
    }
    
    /// Performs an operation
    /// - Parameter symbol: a text of type `(String)` that represent an operation to perform
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol] else {
            return
        }
        
        switch operation {
        case let .binaryOperation(function):
            if resultIsPending {
                performOperation("=")
            }
            
            guard let accumulator else {
                return
            }
            
            pendingBinaryOperation = PendingBinaryOperation(number: accumulator, function: function)
        case .equal:
            guard let pendingBinaryOperation,
                  let secondNumber = accumulator else {
                return
            }
            
            accumulator = pendingBinaryOperation.performOperation(secondNumber)
            self.pendingBinaryOperation = nil
        }
    }
    
    /// Saves the result after perform an operation
    var result: Double? {
        get { accumulator }
    }
}

/// Represent a pending operation after perfoms equal
/// Given the first number and an operation I set the second number and performs that operation
struct PendingBinaryOperation {
    let number: Double
    let function: (Double, Double) -> Double
    
    func performOperation(_ secondNumber: Double) -> Double {
        function(number, secondNumber)
    }
}
