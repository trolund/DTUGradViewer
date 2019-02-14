//
//  MainViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 13/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class MainViewController: UIViewController {
    
    var userobj: User? = nil
    var ArrayProgram : Array<String> = []
    var Array : Array<ExamResult> = []

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var avgLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.text = userobj?.Email
        DispatchQueue.global(qos: .userInitiated).async {
            self.getGrades(studyId: (self.userobj?.studyId)!, accessKey: (self.userobj?.accessKey)!, CompletionHandler: { (error) in
                if error == nil{
                    print("alt gik godt")
                    self.avgLabel.text = "\(self.makeAvgGrade())"
                }else{
                    print("fejl")
                }
            })
            
      
        }
        
    }
    
    func makeAvgGrade() -> Double{
        var count = 0.0
        var sum = 0.0
        
        for grade in Array {
            sum = sum + Double(grade.Grade)
            count += 1
        }
        
        return sum/count 
    }
    
    func getGrades(studyId: String, accessKey: String, CompletionHandler: @escaping (Error?) -> Void){
        
        let headers = [
            "Accept": "text/html, */*, */*",
            "X-appname": "DTUGrades",
            "X-token": "61f1ed85-6e6e-4d9f-9bf5-3073efcb9578",
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type": "text/plain; charset=utf-8"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://\(studyId):\(accessKey)@cn.inside.dtu.dk/data/CurrentUser/Grades?_=1550091960082")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                CompletionHandler(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //print(httpResponse)
                //print(data)
                print("XML_____________________")
                if let xmldata = String(data: data!, encoding: .utf8){
                    self.parseResualtXML(xmlString: String(xmldata))
                    CompletionHandler(nil)
                }else{
                    CompletionHandler(error)
                }
                
            }
        })
        
        dataTask.resume()
 
    }
    
    private func parseResualtXML(xmlString: String){
    
        let xml = try! XML.parse(xmlString)
        
        for element in xml.EducationProgrammes.EducationProgramme{
            print(element.attributes["DisplayName"])
            ArrayProgram.append(element.attributes["DisplayName"]!)
            var program = element
            for el in program.ExamResults.ExamResult {
                var resultat = ExamResult()
                
                if let CourseCodedata = el.attributes["CourseCode"] {
                    resultat.CourseCode = String(CourseCodedata)
                }
                if let EctsGivendata = el.attributes["EctsGiven"] {
                    resultat.EctsGiven = Bool(EctsGivendata)!
                }
                if let EctsPointsdata = el.attributes["EctsPoints"] {
                    resultat.EctsPoints = Int(EctsPointsdata)!
                }
                if let Gardedata = el.attributes["Grade"] {
                    resultat.Grade = Int(Gardedata)!
                }
                if let Namedata = el.attributes["Name"] {
                    resultat.Name = Namedata
                }
                if let Perioddata = el.attributes["Period"] {
                    resultat.Period = Perioddata
                }
                if let Programdata = program.attributes["DisplayName"] {
                    resultat.Program = Programdata
                }
                if let Yeardata = program.attributes["Year"] {
                    resultat.Year = Yeardata
                }
                print(resultat.dis())
                Array.append(resultat)
                
            }
        }
        
    }

    /*
     
     <EducationProgrammes>
     <EducationProgramme DisplayName="Adgangskursus" Active="false">
     <PassedEctsSum Exams="9" Credits="0" Total="9" />
     <ExamResults>
     <ExamResult CourseCode="ADGFYSB06" EctsGiven="true" EctsPoints="9" Grade="12" Period="Summer" Year="2016" Name="-" />
     </ExamResults>
     <CreditResults />
     </EducationProgramme>
 
 
 
 */
    
}
