//
//  ViewController.swift
//  CoreLocationARKit
//
//  Created by Turker Koc on 15.07.2019.
//  Copyright © 2019 Turker Koc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import ARCL //downloaded as a pod for using corelocaiton on ARKit

class ViewController: UIViewController, CLLocationManagerDelegate
{

    var place :String!
    var sceneLocationView = SceneLocationView() //Creating ARKit View
    lazy private var locationManager = CLLocationManager() //lazy means it will be initialized when it is accesible
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run() //start it
        self.view.addSubview(sceneLocationView) //allowing to show camera
        
        // Do any additional setup after loading the view.
        self.title = self.place
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //accurcy setting
        self.locationManager.requestAlwaysAuthorization() //can i use your location
        self.locationManager.startUpdatingLocation() //add it into info.plist
        
        findLocalPlaces()
    
        
    }

    private func findLocalPlaces()
    {
        guard let location = self.locationManager.location else {
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = place
        
        var region = MKCoordinateRegion()
        region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if error != nil {
                return
            }
            guard let response = response else {
                return
            }
            
            for item in response.mapItems {
                let placeLocation = (item.placemark.location)!
                
                //ADDING IT INTO ARKIT VİEW
                let image = UIImage(named: "pin")!
                
                
                //customly created annotation
                let placeAnnotationNode = PlaceAnnotation(location: placeLocation, title: item.placemark.name!)
                
                //let annotationNode = LocationAnnotationNode(location: placeLocation, image: image) //creationg annotation
                //annotationNode.scaleRelativeToDistance = false //scale a size depending on the distance
                
                DispatchQueue.main.async {
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: placeAnnotationNode) //adding node
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = self.view.bounds
    }
}

