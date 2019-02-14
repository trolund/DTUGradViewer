//
//  ExamResult.swift
//  DTUGradViewer
//
//  Created by Troels on 14/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

// <ExamResult CourseCode="02450" EctsGiven="true" EctsPoints="5" Grade="4" Period="Winter" Year="2018" Name="Introduction to Machine Learning and Data Mining" />

import Foundation

class ExamResult {
    
    var CourseCode: String = ""
    var EctsGiven: Bool = false
    var EctsPoints: Int = 0
    var Grade: Int = 0
    var Period: String = ""
    var Year: String = ""
    var Name: String = ""
    
    var Program: String = ""
    
    public func dis() -> String {
        return "\(CourseCode) \(EctsGiven) \(EctsPoints) \(Grade) \(Year) \(Period) \n \(Name) \n\n"
    }
    
}
