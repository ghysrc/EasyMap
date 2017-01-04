//
//  Created by ghysrc on 2016/12/27.
//  Copyright © 2016年 ghysrc. All rights reserved.
//

import Foundation

typealias LocateSuccessHandler = ((CLLocation) -> Void)
typealias CommonErrorHandler = ((Error) -> Void)
typealias LocateFailHandler = ((Error) -> Void)
typealias ReGeocoderSuccessHandler = ((CLPlacemark) -> Void)
typealias SearchPoiSuccessHandler = (([MKMapItem]) -> Void)

let Map:MapManager = MapManager()

class MapManager: NSObject, CLLocationManagerDelegate {
    
    private let clManager: CLLocationManager
    private let clGeocoder: CLGeocoder
    private var locateSuccess: LocateSuccessHandler?
    private var locateFail: LocateFailHandler?
    
    override init() {
        self.clManager = CLLocationManager()
        self.clGeocoder = CLGeocoder()
        super.init()
        self.clManager.delegate = self
    }
    
    func requestAuthorization(whenInUse:Bool = true) {
        if whenInUse {
            self.clManager.requestWhenInUseAuthorization()
        } else {
            self.clManager.requestAlwaysAuthorization()
        }
    }
    
    func getLocation(withAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, distanceFilter: CLLocationDistance = 200, onSuccess: @escaping LocateSuccessHandler, onFail: @escaping LocateFailHandler) {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
            return
        }
        requestAuthorization()
        self.clManager.distanceFilter = distanceFilter
        self.clManager.desiredAccuracy = withAccuracy
        self.locateSuccess = onSuccess
        self.locateFail = onFail
        self.clManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0]
        self.locateSuccess?(newLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locateFail?(error)
    }
    
    func reverseGeocoder(location:CLLocation, onSuccess:@escaping ReGeocoderSuccessHandler, onFail: @escaping CommonErrorHandler) {
        self.clGeocoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let marks = placeMarks {
                let mark = marks[0]
                onSuccess(mark)
            } else {
                onFail(error!)
            }
        }
    }
    
    func searchPoi(near coordinate:CLLocationCoordinate2D, radius:CLLocationDistance, keyWords:String, onSuccess:@escaping SearchPoiSuccessHandler, onFail: @escaping CommonErrorHandler) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        let request = MKLocalSearchRequest()
        request.region = region
        request.naturalLanguageQuery = keyWords
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let items = response?.mapItems {
                onSuccess(items)
            } else {
                onFail(error!)
            }
        }
    }
    
}
