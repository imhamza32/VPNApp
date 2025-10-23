//
//  SpeedTest.swift
//  VPNApp
//
//  Created by Munib Hamza on 04/08/2023.
//

import Foundation
import Network
import UIKit

class InternetSpeedChecker {
    
    func testInternetSpeed(completion: @escaping (String?) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetSpeedMonitor")
        
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Network is reachable, perform speed test
                let start = CFAbsoluteTimeGetCurrent()
                
                let url = URL(string: "https://via.placeholder.com/300/09f/fff.png")!
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)
                
                let task = session.downloadTask(with: url) { (url, response, error) in
                    let elapsed = CFAbsoluteTimeGetCurrent() - start
                    
                    if let error = error {
                        print("Download failed with error: \(error)")
                        completion(nil)
                    } else if let url = url {
                        do {
                            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as! Int64
                            let speedInKbps = Double(fileSize) / 1024.0 / elapsed
                            print("Download speed: \(speedInKbps) KBps")
                            let speedString = String(format: "%.2f KBps", speedInKbps)

                            completion(speedString)

                        } catch {
                            completion(nil)
                            print("Failed to get file size.")
                        }
                    }
                }
                
                task.resume()
            } else {
                completion(nil)
                print("Network is not reachable.")
            }
        }
    }

}
