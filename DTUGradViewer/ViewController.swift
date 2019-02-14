//
//  ViewController.swift
//  DTUGradViewer
//
//  Created by Troels on 13/02/2019.
//  Copyright © 2019 Troels. All rights reserved.
//

import UIKit

import SwiftyXMLParser
import Alamofire

var userobj: User = User()

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func btn(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.dowork()
        }
    }
    
    func dowork(){
        getAuthKey(id: "s161791", password: "VXH77kdp") { (key, error) in
            if let stringkey = key{
                print("got key")
                userobj.accessKey = stringkey
                userobj.studyId = "s161791"
                
                self.getUser(accssesKey: stringkey, studyId: "s161791", CompletionHandler: { (user, error) in
                
                    print("id: \(userobj.studyId) , pass: \(userobj.password)")
                    print("Skift!")
                    
                    DispatchQueue.main.async {
                    let vc: MainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mainview") as! MainViewController
                    
                    print("user: \(user?.GivenName) logedin")
                    vc.userobj = userobj
                    
                    self.present(vc, animated: true, completion: nil)
                    }
                    
                })
                
                
            }else{
                print("error")
                self.dowork()
            }
            }
        }
    
    
    func getUser(accssesKey: String, studyId: String, CompletionHandler: @escaping (User?, Error?) -> Void){
        
        let headers = [
            "accept": "text/html, */*, */*",
            "x-appname": "DTUGrades",
            "x-token": "61f1ed85-6e6e-4d9f-9bf5-3073efcb9578",
            "x-requested-with": "XMLHttpRequest",
            "content-type": "text/plain; charset=utf-8",
            "cache-control": "no-cache",
            ]
        
        print(studyId)
        print("Key: \(accssesKey)")
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://\(studyId):\(accssesKey)@cn.inside.dtu.dk/data/CurrentUser/UserInfo?_=1549915803628")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                // print(error)
                CompletionHandler(nil , error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //print(httpResponse)
                if let httpBody = data {
                    if let dataString = String(data: httpBody, encoding: .utf8){
                        print("data: \(dataString)")
                        
                        let xml = try! XML.parse(dataString)
                        
                        if let firstname = xml["User", 0].attributes["GivenName"] {
                            userobj.GivenName = firstname
                        }
                        if let FamilyName = xml["User", 0].attributes["FamilyName"] {
                            userobj.FamilyName = FamilyName
                        }
                        if let UserId = xml["User", 0].attributes["UserId"] {
                            userobj.UserId = UserId
                        }
                        if let Closed = xml["User", 0].attributes["Closed"] {
                            userobj.Closed = Closed
                        }
                        if let Email = xml["User", 0].attributes["Email"] {
                            userobj.Email = Email
                        }
                        if let PrimaryPhone = xml["User", 0].attributes["PrimaryPhone"] {
                            userobj.PrimaryPhone = PrimaryPhone
                        }
                        if let UserName = xml["User", 0].attributes["UserName"] {
                            userobj.UserName = UserName
                        }
                        
                        CompletionHandler(userobj , nil)
               
                    }
                }
                else{
                    CompletionHandler(nil, error)
                }
                
            }
        })
        dataTask.resume()
    }
    
    func getAuthKey(id: String, password: String, CompletionHandler: @escaping (String?, Error?) -> Void){
        let headers = [
            "cache-control": "no-cache"
        ]
        
        let postData = NSMutableData(data: "username=\(id)".data(using: String.Encoding.utf8)!)
        postData.append("&password=\(password)".data(using: String.Encoding.utf8)!)
        //postData.append("&undefined=undefined".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://auth.dtu.dk/dtu/mobilapp.jsp")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                // print(error)
                CompletionHandler(nil, error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //print(httpResponse)
                if let httpBody = data {
                    let dataString = String(data: httpBody, encoding: .utf8)
                    //print(dataString)
                    if let newstr = dataString {
                        let lowerBound = String.Index(encodedOffset: 30)
                        let upperBound = String.Index(encodedOffset: 66)
                        let mySubstring = newstr[lowerBound..<upperBound]
                        //print(mySubstring)
                        
                        if !String(mySubstring).contains("Wrong"){
                            userobj.accessKey = String(mySubstring)
                            CompletionHandler(userobj.accessKey, nil)
                        }
                        else{
                            CompletionHandler(nil, error)
                        }
                    }
                }
                
            }
        })
        
        dataTask.resume()
        
    }
}

