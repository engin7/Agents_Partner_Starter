import UIKit
import RealmSwift

//
// MARK: - Categories Table View Controller
//
class CategoriesTableViewController: UITableViewController {
  //
  // MARK: - Variables And Properties
  //
  let realm = try! Realm()  // better to use do-catch, here simplified.
  lazy var categories: Results<Category> = { self.realm.objects(Category.self) }() // fetch objects
  var selectedCategory: Category!

  //
  // MARK: - Helper Methods
  //
    
  private func populateDefaultCategories() {
      if categories.count == 0 { // database has no Category records
        try! realm.write() { // add some records to the database.
          let defaultCategories =
            ["Birds", "Mammals", "Flora", "Reptiles", "Arachnids" ]
          
          for category in defaultCategories { // For each category name, you create a new instance of Category, populate name and add the object to realm
            let newCategory = Category()
            newCategory.name = category
            
            realm.add(newCategory)
          }
        }
        
        categories = realm.objects(Category.self) // fetch them'll
      }
  }

    
  //
  // MARK: - View Controller
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    populateDefaultCategories()

  }
}

//
// MARK: - Table View Data Source
//
extension CategoriesTableViewController {
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    let category = categories[indexPath.row]
    cell.textLabel?.text = category.name
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedCategory = categories[indexPath.row]
    return indexPath
  }
}

// It’s nice to see the categories show up in the app, but it’s always reassuring to see the records in the database. You can do this via the Realm Browser.
// print(Realm.Configuration.defaultConfiguration.fileURL!)

