//
//  Date+Ext.swift
//  SeptaWidgetTest
//
//  Created by Cory Popp on 1/27/23.
//

import Foundation

extension Date {

var zeroSeconds: Date? {
    let calendar = Calendar.current
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    return calendar.date(from: dateComponents)
}}
