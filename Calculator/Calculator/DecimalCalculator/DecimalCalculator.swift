//
//  DecimalCalculator.swift
//  Calculator
//
//  Created by Yeon on 2020/12/07.
//

import Foundation

class DecimalCalculator {
    var postfixStack: Stack = Stack<String>()
    var calculateStack: Stack = Stack<String>()
    init() {}

}

extension DecimalCalculator: BasicCalculable {
    func add(first: String, second: String) throws -> String {
        var result: Double
        let firstNumber: Double = (first as NSString).doubleValue
        let secondNumber: Double = (second as NSString).doubleValue
        result = firstNumber + secondNumber
        return String(describing: result)
    }
    
    func subtract(first: String, second: String) throws -> String {
        var result: Double
        let firstNumber: Double = (first as NSString).doubleValue
        let secondNumber: Double = (second as NSString).doubleValue
        result = firstNumber - secondNumber
        return String(describing: result)
    }
    
    func clear() {
        postfixStack.removeAll()
        calculateStack.removeAll()
    }
}

extension DecimalCalculator: DecimalCalculable {
    func multiply(first: String, second: String) throws -> String {
        var result: Double
        let firstNumber: Double = (first as NSString).doubleValue
        let secondNumber: Double = (second as NSString).doubleValue
        result = firstNumber * secondNumber
        return String(describing: result)
    }
    
    func divide(first: String, second: String) throws -> String {
        var result: Double
        let firstNumber: Double = (first as NSString).doubleValue
        let secondNumber: Double = (second as NSString).doubleValue
        
        if secondNumber == 0 {
            throw CalculatorError.divideByZero
        } else {
            result = firstNumber / secondNumber
        }
        return String(describing: result)
    }
}
