//
//  AMapViewController.swift
//  EasyMapDemo
//
//  Created by ghysrc on 2017/1/10.
//  Copyright © 2017年 ghysrc. All rights reserved.
//

import UIKit

class AMapViewController: UIViewController {
    
    private var location:CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        AMapServices.shared().apiKey = "2f0e64657df91d70a5ae584cbfdc0829"
        // Do any additional setup after loading the view.
    }
    @IBAction func startLocating(_ sender: UIButton) {
        AMap.getLocation(onSuccess: { (location) in
            self.location = location
            sender.setTitle("\(location.coordinate.latitude), \(location.coordinate.longitude)", for: .normal)
        }) { (error) in
            self.showAlert(title: error.localizedDescription)
        }
    }
    
    @IBAction func reverseGeocoder(_ sender: UIButton) {
        guard let coordinate = self.location?.coordinate else {
            self.showAlert(title: "Click Locate First")
            return
        }
        AMap.reverseGeocoder(coordinate: coordinate, onSuccess: { (response) in
            self.showAlert(title: response.regeocode.formattedAddress)
        }) { (error) in
            self.showAlert(title: error.localizedDescription)
        }
    }
    
    @IBAction func poiSearch(_ sender: UIButton) {
        guard let coordinate = self.location?.coordinate else {
            self.showAlert(title: "Click Locate First")
            return
        }
        AMap.searchPoi(near: coordinate, radius: 1000, keywords: "hotel", types: "", page: 1, offset: 10, sortByDistance: true, requireExtension: false, onSuccess: { (response) in
            var names = [String]()
            for item in response.pois {
                names.append(item.name)
            }
            self.showActionSheet(title: "POI Result", buttons: names)
        }) { (error) in
            self.showAlert(title: error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
