//
//  FormDateCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

public class FormDateCell: FormValueCell {

    /// MARK: Properties
    
    @objc private let datePicker = UIDatePicker()
    
    private let hiddenTextField = UITextField(frame: CGRectZero)
    private let defaultDateFormatter = NSDateFormatter()
    private let defaultCountdownFormatter: CountdownFormatterClosure = { countdown in
        let minutes = Int(countdown / 60)
        let hours = Int(countdown / 60 / 60)
        return "\(hours)h \(minutes - hours * 60)m"
    }
    
    /// MARK: FormBaseCell
    
    public override func configure() {
        super.configure()
        contentView.addSubview(hiddenTextField)
        hiddenTextField.inputView = datePicker
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged)
    }
    
    public override func update() {
        super.update()
        
        if let showsInputToolbar = rowDescriptor.configuration[FormRowDescriptor.Configuration.ShowsInputToolbar] as? Bool {
            if showsInputToolbar && hiddenTextField.inputAccessoryView == nil {
                hiddenTextField.inputAccessoryView = inputAccesoryView()
            }
        }
        
        titleLabel.text = rowDescriptor.title
        
        switch rowDescriptor.rowType {
        case .Date:
            datePicker.datePickerMode = .Date
            defaultDateFormatter.dateStyle = .LongStyle
            defaultDateFormatter.timeStyle = .NoStyle
        case .Time:
            datePicker.datePickerMode = .Time
            defaultDateFormatter.dateStyle = .NoStyle
            defaultDateFormatter.timeStyle = .ShortStyle
        case .Countdown:
            datePicker.datePickerMode = .CountDownTimer
            defaultDateFormatter.dateStyle = .NoStyle
            defaultDateFormatter.timeStyle = .NoStyle
        case .DateAndTime:
            datePicker.datePickerMode = .DateAndTime
            defaultDateFormatter.dateStyle = .LongStyle
            defaultDateFormatter.timeStyle = .ShortStyle
        default:
            break
        }
        
        func getTimeInterval<T: IntegerLiteralConvertible>(value: NSObject) -> T? {
            if let val = value as? T {
                return val
            }
            return nil
        }
        
        if let date = rowDescriptor.value as? NSDate {
            datePicker.date = date
            valueLabel.text = self.getDateFormatter().stringFromDate(date)
        } else if let duration = getTimeInterval(rowDescriptor.value) {
            datePicker.countDownDuration = NSTimeInterval(duration)
            valueLabel.text = getCountdownFormatter()(NSTimeInterval(duration))
        }
    }
    
    public override class func formViewController(formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        
        let row: FormDateCell! = selectedRow as? FormDateCell
        
        if row.rowDescriptor.value == nil {
            if [FormRowType.Date, FormRowType.Time, FormRowType.DateAndTime].contains(row.rowDescriptor.rowType) {
                let date = NSDate()
                row.rowDescriptor.value = date
                row.valueLabel.text = row.getDateFormatter().stringFromDate(date)
            } else if row.rowDescriptor.rowType == .Countdown {
                let countdown = NSTimeInterval(0)
                row.rowDescriptor.value = countdown
                row.valueLabel.text = row.getCountdownFormatter()(countdown)
            }
            row.update()
        }
        
        row.hiddenTextField.becomeFirstResponder()
    }
    
    public override func firstResponderElement() -> UIResponder? {
        return hiddenTextField
    }
    
    public override class func formRowCanBecomeFirstResponder() -> Bool {
        return true
    }
    
    /// MARK: Actions
    
    internal func valueChanged(sender: UIDatePicker) {
        if [FormRowType.Date, FormRowType.Time, FormRowType.DateAndTime].contains(rowDescriptor.rowType) {
            rowDescriptor.value = sender.date
            valueLabel.text = getDateFormatter().stringFromDate(sender.date)
        } else if rowDescriptor.rowType == .Countdown {
            rowDescriptor.value = sender.countDownDuration
            valueLabel.text = getCountdownFormatter()(sender.countDownDuration)
        }
        update()
    }
    
    /// MARK: Private interface
    
    private func getDateFormatter() -> NSDateFormatter {
        if let dateFormatter = rowDescriptor.configuration[FormRowDescriptor.Configuration.DateFormatter] as? NSDateFormatter {
            return dateFormatter
        }
        return defaultDateFormatter
    }
    
    private func getCountdownFormatter() -> CountdownFormatterClosure {
        if let formatter = rowDescriptor.configuration[FormRowDescriptor.Configuration.CountdownFormatterClosure] as? CountdownFormatterClosure {
            return formatter
        }
        return defaultCountdownFormatter
    }
}
