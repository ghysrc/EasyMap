//
//  Created by ghysrc on 2017/1/4.
//  Copyright © 2017年 ghysrc. All rights reserved.
//

typealias AMapLocateSuccessHandler = ((CLLocation) -> Void)
typealias AMapLocateFailHandler = ((Error) -> Void)
typealias AMapReGeocoderSuccessHandler = ((AMapReGeocodeSearchResponse) -> Void)
typealias AMapGeocoderSuccessHandler = ((AMapGeocodeSearchResponse) -> Void)
typealias AMapSearchFailHandler = ((Error) -> Void)
typealias AMapPoiSearchSuccessHandler = ((AMapPOISearchResponse) -> Void)
typealias AMapInputTipSearchSuccessHandler = ((AMapInputTipsSearchResponse) -> Void)

let AMap:AMapManager = AMapManager()

class AMapManager: NSObject, AMapLocationManagerDelegate, AMapSearchDelegate {
    
    private let locationManager: AMapLocationManager
    private let searchApi: AMapSearchAPI
    private var locateSuccess: AMapLocateSuccessHandler?
    private var locateFail: AMapLocateFailHandler?
    private var regeocoderSuccess: AMapReGeocoderSuccessHandler?
    private var geocoderSuccess: AMapGeocoderSuccessHandler?
    private var inputTipSearchSuccess: AMapInputTipSearchSuccessHandler?
    private var poiSearchSuccess: AMapPoiSearchSuccessHandler?
    private var searchFail: AMapSearchFailHandler?
    
    override init() {
        self.locationManager = AMapLocationManager()
        self.searchApi = AMapSearchAPI()
        super.init()
        self.locationManager.delegate = self
        self.searchApi.delegate = self
    }
    
    func requestAuthorization(whenInUse:Bool = true) {
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == .denied {
            print("Location Service disabled or authorization denied.")
            return
        }
        let clManager = CLLocationManager()
        if whenInUse {
            clManager.requestWhenInUseAuthorization()
        } else {
            clManager.requestAlwaysAuthorization()
        }
    }
    
    /**
     
     * Start continuouts locating
     
     * Default desiredAccuracy is kCLLocationAccuracyHundredMeters
     
     * Default distanceFilter is 200 meters
     
     */
    func getLocation(withAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, distanceFilter: CLLocationDistance = 200, onSuccess: @escaping AMapLocateSuccessHandler, onFail: @escaping AMapLocateFailHandler) {
        requestAuthorization()
        locateSuccess = onSuccess
        locateFail = onFail
        locationManager.desiredAccuracy = withAccuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
        locateSuccess?(location)
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        locateFail?(error)
    }
    
    /// coordinate to address
    func reverseGeocoder(coordinate:CLLocationCoordinate2D, requireExtension:Bool = false, onSuccess:@escaping AMapReGeocoderSuccessHandler, onFail: @escaping AMapSearchFailHandler) {
        let searchRequest = AMapReGeocodeSearchRequest()
        searchRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        searchRequest.requireExtension = requireExtension
        regeocoderSuccess = onSuccess
        searchFail = onFail
        searchApi.aMapReGoecodeSearch(searchRequest)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        regeocoderSuccess?(response)
    }
    
    /// address to coordinate, city can be empty
    func geocoder(address:String, city:String, onSuccess: @escaping AMapGeocoderSuccessHandler, onFail: @escaping AMapSearchFailHandler) {
        let searchRequest = AMapGeocodeSearchRequest()
        searchRequest.address = address
        searchRequest.city = city
        geocoderSuccess = onSuccess
        searchFail = onFail
        searchApi.aMapGeocodeSearch(searchRequest)
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        geocoderSuccess?(response)
    }
    
    /// Get suggestions by keyword
    func searchInputTips(keywords:String, city:String? = nil, onSuccess: @escaping AMapInputTipSearchSuccessHandler, onFail: @escaping AMapSearchFailHandler) {
        let searchRequest = AMapInputTipsSearchRequest()
        searchRequest.keywords = keywords
        searchRequest.city = city
        inputTipSearchSuccess = onSuccess
        searchFail = onFail
        searchApi.aMapInputTipsSearch(searchRequest)
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        inputTipSearchSuccess?(response)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        searchFail?(error)
    }
    
    /// Search nearby pois
    func searchPoi(near coordinate:CLLocationCoordinate2D, radius:Int = 3000, keywords:String = "", types:String = "", page:Int = 1, offset:Int = 20, sortByDistance:Bool = false, requireExtension:Bool = false, onSuccess: @escaping AMapPoiSearchSuccessHandler, onFail: @escaping AMapSearchFailHandler) {
        let searchRequest = AMapPOIAroundSearchRequest()
        searchRequest.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        searchRequest.radius = radius
        searchRequest.keywords = keywords
        searchRequest.types = types
        searchRequest.page = page
        searchRequest.offset = offset
        searchRequest.sortrule = sortByDistance ? 0 : 1
        searchRequest.requireExtension = requireExtension
        poiSearchSuccess = onSuccess
        searchFail = onFail
        searchApi.aMapPOIAroundSearch(searchRequest)
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        poiSearchSuccess?(response)
    }
    
}
