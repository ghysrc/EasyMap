//
//  BMapViewController.swift
//  EasyMapDemo
//
//  Created by ghysrc on 2017/1/10.
//  Copyright © 2017年 ghysrc. All rights reserved.
//

import UIKit

class BMapViewController: UIViewController {
    
    private var location:CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        let manager = BMKMapManager()
        manager.start("s0f0se2iZ3W5QpHl6EN3nnUDwCO3FWt8", generalDelegate: nil)
        // Do any additional setup after loading the view.
    }
    @IBAction func startLocating(_ sender: UIButton) {
        BMap.getLocation(onSuccess: { (location) in
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
        BMap.reverseGeocoder(coordinate: coordinate, onSuccess: { (result) in
            self.showAlert(title: result.address)
        }) { (errorCode) in
            self.showAlert(title: "errorCode = \(errorCode)")
        }
    }
    
    @IBAction func poiSearch(_ sender: UIButton) {
        guard let coordinate = self.location?.coordinate else {
            self.showAlert(title: "Click Locate First")
            return
        }
        BMap.searchPoi(near: coordinate, radius: 1000, keyword: "food", onSuccess: { (result) in
            var names = [String]()
            for item in result.poiInfoList as! [BMKPoiInfo] {
                names.append(item.name)
            }
            self.showActionSheet(title: "POI Result", buttons: names)
        }) { (errorCode) in
            self.showAlert(title: "errorCode = \(errorCode)")
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
