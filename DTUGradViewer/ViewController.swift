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

//var userobj: User = User()

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBAction func btn(_ sender: UIButton) {
        guard let usernameText = self.username.text else {
            print("ooops wrong username")
            return
        }
        
        guard let passeordText = self.password.text else {
            print("ooops wrong password")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.dowork(id: usernameText, pass: passeordText)
        }
        
    }
    
    func dowork(id: String, pass: String){
        getAuthKey(id: id, password: pass) { (key, error) in
            if let stringkey = key{
                print("got key")
                userGlobal.accessKey = stringkey
                userGlobal.studyId = id
                
                self.getUser(accssesKey: stringkey, studyId: id, CompletionHandler: { (user, error) in
                
                    print("id: \(user?.studyId) , pass: \(user?.password)")
                    print("Skift!")
                    
                    DispatchQueue.main.async {
                    let vc: MainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mainview") as! MainViewController
                    
                    print("user: \(user?.GivenName) logedin")
                     /*   userGlobal.Closed = (user?.Closed)!
                        userGlobal.Email = (user?.Email)!
                        userGlobal.FamilyName = (user?.FamilyName)!
                        userGlobal.GivenName = (user?.GivenName)!
                        userGlobal.password = (user?.password)!
                        userGlobal.PreferredLanguage = user?.PreferredLanguage ?? "dk"
                        userGlobal.PrimaryPhone = (user?.PrimaryPhone)!
                        userGlobal.UserId = (user?.studyId)!
                        userGlobal.UserName = (user?.UserName)!
                    */
                    self.present(vc, animated: true, completion: nil)
                    }
                    
                })
                
                
            }else{
                print("error")
                self.dowork(id: id, pass: pass)
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
                           userGlobal.GivenName = firstname
                        }
                        if let FamilyName = xml["User", 0].attributes["FamilyName"] {
                            userGlobal.FamilyName = FamilyName
                        }
                        if let UserId = xml["User", 0].attributes["UserId"] {
                            userGlobal.UserId = UserId
                        }
                        if let Closed = xml["User", 0].attributes["Closed"] {
                            userGlobal.Closed = Closed
                        }
                        if let Email = xml["User", 0].attributes["Email"] {
                            userGlobal.Email = Email
                        }
                        if let PrimaryPhone = xml["User", 0].attributes["PrimaryPhone"] {
                            userGlobal.PrimaryPhone = PrimaryPhone
                        }
                        if let UserName = xml["User", 0].attributes["UserName"] {
                            userGlobal.UserName = UserName
                        }
                        
                        CompletionHandler(userGlobal , nil)
               
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
                            userGlobal.accessKey = String(mySubstring)
                            CompletionHandler(userGlobal.accessKey, nil)
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

