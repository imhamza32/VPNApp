//
//  API Manager.swift
//  API Manager
//
//  Created by Munib Hamza on 23/05/2022.
//

import Foundation
import Alamofire
import UIKit

typealias RequestCompletion = (_ response: [String:Any]?, _ error: Error?) -> Void
//typealias RequestCompletionWithIndex = (_ response: Any?,_ index : IndexPath , _ error: Error?) -> Void


class APIRequestUtil {
    
    static let shared = APIRequestUtil()
    private init() {}
    
    func registerUser(parameters: Parameters, completion: @escaping RequestCompletion) {
        sendRequest(withToken : false, urlString: APIPaths.register_user, parameters: parameters, method: .post, completion: completion)
    }
    
    func getUserProfile(parameters: Parameters = [:], completion: @escaping RequestCompletion) {
        sendRequest(urlString: APIPaths.user_profile, parameters: parameters, method: .get, completion: completion)
    }
    
    func sendResetLink(parameters: Parameters, completion: @escaping RequestCompletion) {
        sendRequest(withToken: false, urlString: APIPaths.reset_password, parameters: parameters, method: .post, completion: completion)
    }
    
    
    
    
    func loginUser(parameters: Parameters, completion: @escaping RequestCompletion) {
        
        var params = ["grant_type": "password",
                      "client_id": "django_client_id",
                      "client_secret": "client_secret",
                      "backend": "django-user"] as Parameters
        
        for (key,value) in parameters {
            params[key] = value
        }
        
        sendRequest(withToken : false, urlString: APIPaths.login_user, parameters: params, method: .post, completion: completion)
    }
    
    func fetchAllPumpkins(parameters: Parameters, completion: @escaping RequestCompletion) {
        sendRequest(urlString: APIPaths.pumkins, parameters: parameters, method: .get, completion: completion)
    }
    
    func addPumpkin(image : UIImage, imageName: String, parameters: Parameters, completion: @escaping RequestCompletion) {
        MultipartRequest(url: APIPaths.pumkins, parameters: parameters, image: image, withImgName: imageName, completion: completion)
    }
    
}

extension APIRequestUtil {
    
    fileprivate func sendRequest(withToken : Bool = true, urlString: String, parameters: Parameters, method : HTTPMethod, completion: @escaping RequestCompletion) {
        
        guard let url = URL(string: urlString) else {
            print("URL invalid")
            completion(nil, CustomError.invalidURL)
            return
        }
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 50
        
        var request = URLRequest(url: url)
        
        if withToken {
            guard let accessToken = DataManager.shared.getAccessToken() else {
                completion(nil, CustomError.tokenExpired)
                return
            }
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if parameters.count > 0 {
            request.httpBody = toJSonString(data: parameters).data(using: .utf8)
        }
        request.httpMethod = method.rawValue
        
        print("************** \(method.rawValue) Request with url \(url)")
        
        print("************** \(method.rawValue) Request with Params \(parameters)")
        
        manager.request(request).responseJSON { response in
            print("************* Response ****************")
            print(response)
            switch response.result {
            case .success(let value):
                completion(value as? [String : Any], nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    fileprivate func MultipartRequest(withToken : Bool = true, url: String, parameters: Parameters, image: UIImage, withImgName: String, completion: @escaping RequestCompletion) {
        
        var headers = ["Accept": "application/json"]
        
        if withToken {
            guard let accessToken = DataManager.shared.getAccessToken() else {
                completion(nil, CustomError.tokenExpired)
                return
            }
            
            headers = ["Authorization": "Bearer " + accessToken,
                        "Accept": "application/json"]
            
        }
        print("********** Multipart Request with url \( url)")
        print("********** Multipart Request with Params \(parameters)")
        
        let URL = URL(string: url)
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            let imageData = image.compressedData()!
            
            multipartFormData.append(imageData, withName: withImgName, fileName: String(Date().timeIntervalSince1970) + ".png", mimeType: "image/png")
            
            for (key, value) in parameters {
                let stringValue = "\(value)"
                multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init(), to: URL!, method: .post, headers: headers)
        { (result) in
            switch result{
            case .success(let upload, _,_ ):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadProgress"), object: nil, userInfo: ["progress": Progress.fractionCompleted])
                    
                })
                
                upload.responseJSON { (response) in
                    print("************* Response ****************")
                    print(response)
                    if response.result.isSuccess {
                        if let response = response.result.value as? [String : Any] {
                            completion(response,nil)
                        } else {
                            completion(nil, response.result.error)
                        }
                    } else {
                        completion(nil, response.result.error)
                    }
                }
                
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                completion(nil, error)
                
            }
        }
    }

    //    static func downloadFile(with url: URL, completion:@escaping ( _ path:URL,  _ error:NSError?)-> Void) {
    //        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
    //        let sessionConfig = URLSessionConfiguration.default
    //        sessionConfig.timeoutIntervalForRequest = 20.0
    //        sessionConfig.timeoutIntervalForResource = 60.0
    //        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "GET"
    //        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
    //            if (error == nil) {
    //                if let response = response as? HTTPURLResponse {
    //                    if response.statusCode == 200 {
    //                        if (try? data!.write(to: destinationUrl, options: [.atomic])) != nil {
    //                            completion(destinationUrl, nil)
    //                        } else {
    //                            let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
    //                            completion(destinationUrl, error)
    //                        }
    //                    }
    //                }
    //            }
    //            else {
    //                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
    //                completion(destinationUrl, error)
    //            }
    //        })
    //        task.resume()
    //    }
    //

    fileprivate func toJSonString(data : Any) -> String {
        
        var jsonString = "";
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .init(rawValue: 0))
            jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
            jsonString = jsonString.replacingOccurrences(of: "\n", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString)
        return jsonString;
    }
    
    
    
}

extension URL {
    
    @discardableResult
    func append(_ queryItem: String, value: String?) -> URL {
        
        guard var urlComponents = URLComponents(string:  absoluteString) else { return absoluteURL }
        
        // create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        
        // create query item if value is not nil
        guard let value = value else { return absoluteURL }
        let queryItem = URLQueryItem(name: queryItem, value: value)
        
        // append the new query item in the existing query items array
        queryItems.append(queryItem)
        
        // append updated query items array in the url component object
        urlComponents.queryItems = queryItems// queryItems?.append(item)
        
        // returns the url from new url components
        return urlComponents.url!
    }
}

class APIResponseUtil {
    
    public static func isValidResponse(viewController: UIViewController, response: [String:Any]?, error: Error?, renderError: Bool = true) -> Bool {
        
        var isValidResponse = false
        var message = ""
        
//        if dismissLoading {
////            DispatchQueue.main.async {
//                BaseClass.stopLoading()
////            }
//        }
////
        if response != nil {
            if let errorArray = response?["errors"] as? [AnyObject] {
                if let first = errorArray.first, let msg = first["detail"] as? String {
                    message = msg
                } else {
                    message = "\(errorArray)"
                }

            } else if let error = response?["error"] as? String {
                if let msg = response?["error_description"] as? String {
                    message = msg
                } else{
                    message = error
                }

            } else {
                isValidResponse = true
                if let msg = response?["message"] as? String {
                    message = msg
                }
            }
        } else {
            isValidResponse = false
            message = error?.localizedDescription ?? AC.SomeThingWrong
        }
        if !isValidResponse && message.count > 0 && renderError {
            viewController.showAlert(title: AC.Error, message: message)
        }
        return isValidResponse
    }
    
    
//    public static func isValidResponse(cell: UITableViewCell,
//                                       response: Any?, error: Error?, renderError: Bool = false,
//                                       dismissLoading: Bool = true) -> Bool {
//        return  APIResponseUtil.check(response: response, error: error, renderError: renderError, dismissLoading: dismissLoading)
//    }
//
//
//    static func check (response: Any?, error: Error?, renderError: Bool = true,
//                       dismissLoading: Bool = true) -> Bool{
//        var isValidResponse = false
//        var message = ""
//
//        print(response as Any)
//
//        if error != nil {
//            if dismissLoading {
//                BaseClass().hideLoading()
//            }
//            message = AC.SomeThingWrong
//
//        } else {
//            if dismissLoading {
//                BaseClass().hideLoading()
//            }
//            if response != nil {
//                isValidResponse = true
//                if let code = response["Code"] as? Int, code == 1 {
//                    isValidResponse = true
//                }
//                else {
//                    message = response["message"] as? String ?? AC.SomeThingWrong
//                    //                    message = (message.count == 0 ? json["error_message"].stringValue : message)
//                }
//            } else {
//                isValidResponse = false
//            }
//        }
//        if !isValidResponse && message.count > 0 && renderError {
//            //            showErrorAlert(message: message, AlertTitle: AC.Error)
//        }
//        return isValidResponse
//    }
}

func decodeJson<T: Decodable>(_ dataJS: Any) -> T?{
    
    if let data = try? JSONSerialization.data(withJSONObject: dataJS) {
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error as Any)
            return nil
        }
    } else {
        return nil
    }
}
