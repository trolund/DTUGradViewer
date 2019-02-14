//
//  MainViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 13/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var userobj: User? = nil
    var colourArray : Array<ExamResult>

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        label.text = userobj?.Email
        getGrades(studyId: String(userobj!.studyId), accessKey: String(userobj!.accessKey))
        
    }
    
    func getGrades(studyId: String, accessKey: String){
        
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
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                print(data)
                
                
                
                
            }
        })
        
        dataTask.resume()
 
    }

}
