
import UIKit
import RealmSwift

//
// MARK: - Add New Entry View Controller
//
class AddNewEntryViewController: UIViewController {
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var descriptionTextField: UITextView!
  @IBOutlet weak var nameTextField: UITextField!
  
  //
  // MARK: - Variables And Properties
  //
  var selectedAnnotation: SpecimenAnnotation!
  var selectedCategory: Category!
  var specimen: Specimen!

  //
  // MARK: - IBActions
  //
    
  // is called when the user selects a category
  @IBAction func unwindFromCategories(segue: UIStoryboardSegue) {
    if segue.identifier == "CategorySelectedSegue" {
      let categoriesController = segue.source as! CategoriesTableViewController
      selectedCategory = categoriesController.selectedCategory
      categoryTextField.text = selectedCategory.name
    }
  }
    
    //
    // MARK: - Private Methods
    //

    func addNewSpecimen() {
      let realm = try! Realm() // start instance
        
      try! realm.write { // add your new Specimen to realm
        let newSpecimen = Specimen() // create new specimen instance
          
        newSpecimen.name = nameTextField.text! // assign values
        newSpecimen.category = selectedCategory
        newSpecimen.specimenDescription = descriptionTextField.text
        newSpecimen.latitude = selectedAnnotation.coordinate.latitude
        newSpecimen.longitude = selectedAnnotation.coordinate.longitude
          
        realm.add(newSpecimen) // Add the new Specimen to the realm.
        specimen = newSpecimen // Assign the new Specimen to your specimen property
      }
    }
    
    override func shouldPerformSegue(
      withIdentifier identifier: String,
      sender: Any?
      ) -> Bool {
        if validateFields() {
          addNewSpecimen()
          // check validation
          return true
        } else {
          return false
        }
    }

  //
  // MARK: - Private Methods
  //
  
  // You’ll need some sort of validator to make sure all of the fields are populated in your Specimen
    
  func validateFields() -> Bool {
    if
      nameTextField.text!.isEmpty ||
      descriptionTextField.text!.isEmpty ||
      selectedCategory == nil {
  // This verifies that all of the fields are populated and that you’ve selected a category.

      let alertController = UIAlertController(title: "Validation Error",
                                              message: "All fields must be filled",
                                              preferredStyle: .alert)
      
      let alertAction = UIAlertAction(title: "OK", style: .destructive) { alert in
        alertController.dismiss(animated: true, completion: nil)
      }
      
      alertController.addAction(alertAction)
      
      present(alertController, animated: true, completion: nil)
      
      return false
    } else {
      return true
    }
  }
  
  //
  // MARK: - View Controller
  //
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

//
// MARK: - Text Field Delegate
//
extension AddNewEntryViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    performSegue(withIdentifier: "Categories", sender: self)
  }
}
