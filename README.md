# EasyMap
EasyMap provids a more easy wat to deal with maps. (MapKit, [百度地图](http://lbsyun.baidu.com/), [高德地图](http://lbs.amap.com/) )

### Why use EasyMap?

Here is a sample code to get current location

```swift
class ViewController: UIViewController, CLLocationManagerDelegate 
...
let clManager = CLLocationManager()
clManager.distanceFilter = kCLLocationAccuracyHundredMeters
clManager.desiredAccuracy = 100
clManager.delegate = self
clManager.startUpdatingLocation()

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // Do something
}
    
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
}
```

Well, I'm a lazy person, too many lines of codes here.

Let's see how many lines left by using EasyMap.

```swift
Map.getLocation(onSuccess: { (location) in
    // Do something
}) { (error) in
    
}
```

### Usage

EasyMap contains three Map Services. There is just a slighty difference.

- Map == MapKit
- AMap == [高德地图](http://lbs.amap.com/)
- BMap == [百度地图](http://lbsyun.baidu.com/)

##### Locate

```swift
Map.getLocation(onSuccess: { (location) in
            
}) { (error) in
            
}
```

##### ReverseGeocoder

```swift
BMap.reverseGeocoder(coordinate: coordinate, onSuccess: { (result) in
    
}) { (errorCode) in
    
}
```

##### Get suggestions when typing

```swift
AMap.searchInputTips(keywords: "plaza", onSuccess: { (response) in
    
}, onFail: { (error) in
    
})
```

##### Search nearby pois

```swift
BMap.searchPoi(near: coordinate, radius: 1000, keyword: "hotel", onSuccess: { (result) in
    
}, onFail: { (errorCode) in
    
})
```

### TODO

- [ ] Demo Project
- [ ] More Features
- [ ] Cocopods

### Contribute

- Pull Request is more than welcome
- Found a bug or need a new feature, feel free to open an issue.
