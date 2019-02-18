//
//  OneCourseViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 17/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit

class OneCourseViewController: UIViewController {
    
    var reslut: ExamResult?

    @IBOutlet weak var ID: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var grade: UILabel!
    @IBOutlet weak var ECTS: UILabel!
    
    @IBOutlet weak var period: UILabel!
    
    @IBOutlet weak var given: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ID.text = reslut?.CourseCode
        name.text = reslut?.Name
        grade.text = "\(reslut?.Grade ?? 00)"
        ECTS.text = "\(reslut?.EctsPoints ?? 00)"
        period.text = "\(reslut?.Year ?? "00") \(reslut?.Period ?? "00")"
        
        if let bool = reslut?.EctsGiven{
        if bool{
            given.image = #imageLiteral(resourceName: "con.png")
        }else{
            given.image = #imageLiteral(resourceName: "de.png")
        }
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
