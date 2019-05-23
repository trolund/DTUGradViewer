//
//  MainViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 13/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ArrayProgram.count
    }
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let text = ArrayProgram[row]
       // print(pickerVal)
        return text
    }
     */
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: ArrayProgram[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_: UIPickerView, didSelectRow: Int, inComponent: Int){
        self.pickerVal = didSelectRow
    }
    
    var ExsamResults : Array<ExamResult> = []
    var ArrayProgram : Array<String> = []
  //  var userobj: User? = nil
    var pickerVal: Int = 0{
        didSet{
            self.tabelView.reloadData()
            self.avgGradeLabel.text = String(format: "%.2f", self.makeAvgGrade(program: self.pickerVal))
            self.minGradeLabel.text = String(self.getMinGrade(program: self.pickerVal))
            self.maxGradeLabel.text = String(self.getMaxGrade(program: self.pickerVal))
            print(pickerVal)
        }
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
        ArrayProgram.append("All")
        
        self.programPicker.dataSource = self
        self.programPicker.delegate = self
        self.programPicker.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        //self.tabelView.register(UITableViewCell.self, forCellReuseIdentifier: "hej")
        self.tabelView.dataSource = self
        self.tabelView.delegate = self
         //self.tabelView.dataSource = self as UITableViewDataSource
        // Do any additional setup after loading the view.
        EmalLabel.text = userGlobal.studyId

            nameLabel.text = "\(userGlobal.GivenName) \(String(userGlobal.FamilyName))"
        
        self.getGrades(studyId: (userGlobal.studyId), accessKey: (userGlobal.accessKey), CompletionHandler: { (error) in
                if error == nil{
                    print("alt gik godt")
                    DispatchQueue.main.async {
                        self.avgGradeLabel.text = String(format: "%.2f", self.makeAvgGrade(program: self.pickerVal))
                        self.minGradeLabel.text = String(self.getMinGrade(program: self.pickerVal))
                        self.maxGradeLabel.text = String(self.getMaxGrade(program: self.pickerVal))
                        self.tabelView.reloadData()
                        self.programPicker.reloadAllComponents()
                        print(String(self.ArrayProgram[0]))
                         }
                    
                }
                else{
                    print("fejl")
                }
            })
        
    }
    
    func getMinGrade(program :Int) -> Int {
        var min = 12
        for grade in ExsamResults {
            if grade.Program == ArrayProgram[program] || program == 0{
                if let gradeNum: Int = Int(grade.Grade) {
                    if gradeNum < min{
                        min = gradeNum
                    }
                }
            }
        }
        
        return min
    }
    
    func getMaxGrade(program :Int) -> Int {
        var max = 0
        for grade in ExsamResults {
            if grade.Program == ArrayProgram[program] || program == 0{
            if grade.Grade > max{
                max = grade.Grade
            }
            }
        }
        return max
    }
    
    func makeAvgGrade(program :Int) -> Double{
        var count = 0.0
        var sum = 0.0
        
        for grade in ExsamResults {
            if grade.Program == ArrayProgram[program] || program == 0{
            sum = sum + Double(grade.Grade) * Double(grade.EctsPoints)
            count += Double(grade.EctsPoints)
            }
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
                print(error as Any)
                CompletionHandler(error)
            } else {
                //let httpResponse = response as? HTTPURLResponse
                //print(httpResponse)
                //print(data)
                //print("XML_____________________")
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
            //print(element.attributes["DisplayName"])
            ArrayProgram.append(element.attributes["DisplayName"]!)
            let program = element
            for el in program.ExamResults.ExamResult {
                let resultat = ExamResult()
                
                if let CourseCodedata = el.attributes["CourseCode"] {
                    resultat.CourseCode = String(CourseCodedata)
                }
                if let EctsGivendata = el.attributes["EctsGiven"] {
                    resultat.EctsGiven = Bool(EctsGivendata)!
                }
                if let EctsPointsdata = el.attributes["EctsPoints"] {
                    resultat.EctsPoints = Double(EctsPointsdata)!
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
    
    // tabel view:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(pickerVal != 0){
        var count = 0
        for element in ExsamResults {
            if(ArrayProgram[pickerVal] == element.Program){
                count += 1
            }
        }
            return count
        }else{
            return ExsamResults.count
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) //1.
        
        let element = ExsamResults[indexPath.row]
        
        let text =  "\(element.Grade) \t \(element.Name)"
        
        cell.textLabel?.text = text //3.
        
        if(ArrayProgram[pickerVal] ==  ExsamResults[indexPath.row].Program || pickerVal == 0){
            cell.isHidden = false
        }else{
            cell.isHidden = true
        }
        //print(cell.textLabel?.text)
        return cell //4.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight:CGFloat = 0.0
        
        if(ArrayProgram[pickerVal] ==  ExsamResults[indexPath.row].Program || pickerVal == 0){
            rowHeight = 55.0
        }else{
            rowHeight = 0.0
        }
        return rowHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
            let vc: OneCourseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OneCourseView") as! OneCourseViewController
        
        vc.reslut = ExsamResults[Int(indexPath[1])]
            
            self.present(vc, animated: true, completion: nil)
    }
    
    // tabelview end

}
