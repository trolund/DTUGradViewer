//
//  MainViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 13/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit
import SwiftyXMLParser



class MainViewController: UIViewController, UITableViewDataSource {
    
    var ExsamResults : Array<ExamResult> = []
    var ArrayProgram : Array<String> = []
    var userobj: User? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExsamResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) //1.
        
        let element = ExsamResults[indexPath.row]
        
        let text =  "\(element.Grade) : \(element.Name)"
        
        cell.textLabel?.text = text //3.
        
        print(cell.textLabel?.text)
        
        return cell //4.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBOutlet weak var maxGradeLabel: UILabel!
    @IBOutlet weak var minGradeLabel: UILabel!
    @IBOutlet weak var programPicker: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var EmalLabel: UILabel!
    
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var avgGradeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabelView.register(UITableViewCell.self, forCellReuseIdentifier: "hej")
        self.tabelView.dataSource = self
         //self.tabelView.dataSource = self as UITableViewDataSource
        // Do any additional setup after loading the view.
        EmalLabel.text = userobj?.studyId
        if let name = userobj?.GivenName, let famName = userobj?.FamilyName{
            nameLabel.text = "\(name) \(String(famName))"
        }
        self.getGrades(studyId: (self.userobj!.studyId), accessKey: (self.userobj!.accessKey), CompletionHandler: { (error) in
                if error == nil{
                    print("alt gik godt")
                    DispatchQueue.main.async {
                        self.avgGradeLabel.text = String(format: "%.2f", self.makeAvgGrade())
                        self.minGradeLabel.text = String(self.getMinGrade())
                        self.maxGradeLabel.text = String(self.getMaxGrade())
                        self.tabelView.reloadData()
                         }
                }
                else{
                    print("fejl")
                }
            })
        
    }
    
    func getMinGrade() -> Int {
        var min = 12
        for grade in ExsamResults {
            if grade.Grade < min{
                min = grade.Grade
            }
        }

       return min
    }
    
    func getMaxGrade() -> Int {
        var max = 0
        for grade in ExsamResults {
            if grade.Grade > max{
                max = grade.Grade
            }
        }
        return max
    }
    
    func makeAvgGrade() -> Double{
        var count = 0.0
        var sum = 0.0
        
        for grade in ExsamResults {
            sum = sum + Double(grade.Grade) * Double(grade.EctsPoints)
            count += Double(grade.EctsPoints)
        }
        return sum/count  
    }
    
    func getGrades(studyId: String, accessKey: String, CompletionHandler: @escaping (Error?) -> Void){
        
        DispatchQueue.global(qos: .userInitiated).async {
        
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
                ExsamResults.append(resultat)
                
            }
        }
    }

}
