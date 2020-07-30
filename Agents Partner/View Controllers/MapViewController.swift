 
 
import CoreLocation
import MapKit
import UIKit

//
// MARK: - Map View Controller
//
class MapViewController: UIViewController {
  //
  // MARK: - IBOutlets
  //
  @IBOutlet weak var mapView: MKMapView!
  
  //
  // MARK: - Constants
  //
  let kDistanceMeters: CLLocationDistance = 500
  
  //
  // MARK: - Variables And Properties
  //
  var lastAnnotation: MKAnnotation!
  var locationManager = CLLocationManager()
  var userLocated = false
  
  //
  // MARK: - IBActions
  //
  @IBAction func addNewEntryTapped() {
    addNewPin()
  }
  
  @IBAction func centerToUserLocationTapped() {
    centerToUsersLocation()
  }
  
  @IBAction func unwindFromAddNewEntry(segue: UIStoryboardSegue) {
    if let lastAnnotation = lastAnnotation {
      mapView.removeAnnotation(lastAnnotation)
    }
    
    lastAnnotation = nil
  }
  
  //
  // MARK: - Private Methods
  //
  func addNewPin() {
    if lastAnnotation != nil {
      let alertController = UIAlertController(title: "Annotation already dropped",
                                              message: "There is an annotation on screen. Try dragging it if you want to change its location!",
                                              preferredStyle: .alert)
      
      let alertAction = UIAlertAction(title: "OK", style: .destructive) { alert in
        alertController.dismiss(animated: true, completion: nil)
      }
      
      alertController.addAction(alertAction)
      
      present(alertController, animated: true, completion: nil)
      
    } else {
      let specimen = SpecimenAnnotation(coordinate: mapView.centerCoordinate, title: "Empty", subtitle: "Uncategorized")
      
      mapView.addAnnotation(specimen)
      lastAnnotation = specimen
    }
  }
  
  func centerToUsersLocation() {
    let center = mapView.userLocation.coordinate
    let zoomRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, latitudinalMeters: kDistanceMeters, longitudinalMeters: kDistanceMeters)
    
    mapView.setRegion(zoomRegion, animated: true)
  }
  
  //
  // MARK: - View Controller
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Map"
    
    locationManager.delegate = self
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else {
      locationManager.startUpdatingLocation()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if (segue.identifier == "NewEntry") {
      let controller = segue.destination as! AddNewEntryViewController
      let specimenAnnotation = sender as! SpecimenAnnotation
      controller.selectedAnnotation = specimenAnnotation
    }
  }
}

//MARK: - LocationManager Delegate
extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    status != .notDetermined ? mapView.showsUserLocation = true : print("Authorization to use location data denied")
  }
}

//MARK: - Map View Delegate
extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if let specimenAnnotation =  annotationView.annotation as? SpecimenAnnotation {
      performSegue(withIdentifier: "NewEntry", sender: specimenAnnotation)
    }
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
               didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
    
    if newState == .ending {
      view.dragState = .none
    }
  }
  
  func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    for annotationView in views {
      if (annotationView.annotation is SpecimenAnnotation) {
        annotationView.transform = CGAffineTransform(translationX: 0, y: -500)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
          annotationView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
      }
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let subtitle = annotation.subtitle! else {
      return nil
    }
    
    if (annotation is SpecimenAnnotation) {
      if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: subtitle) {
        return annotationView
      } else {
        let currentAnnotation = annotation as! SpecimenAnnotation
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: subtitle)
        
        switch subtitle {
        case "Uncategorized":
          annotationView.image = UIImage(named: "IconUncategorized")
        case "Arachnids":
          annotationView.image = UIImage(named: "IconArachnid")
        case "Birds":
          annotationView.image = UIImage(named: "IconBird")
        case "Mammals":
          annotationView.image = UIImage(named: "IconMammal")
        case "Flora":
          annotationView.image = UIImage(named: "IconFlora")
        case "Reptiles":
          annotationView.image = UIImage(named: "IconReptile")
        default:
          annotationView.image = UIImage(named: "IconUncategorized")
        }
        
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        
        let detailDisclosure = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = detailDisclosure
        
        if currentAnnotation.title == "Empty" {
          annotationView.isDraggable = true
        }
        
        return annotationView
      }
    }
    
    return nil
  }
}
