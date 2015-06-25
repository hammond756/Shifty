# REPORT

## Structure

##### ViewControllers

###### RoosterViewController: ContentViewController, UITableViewDelegate, ActionSheetDelegate
This is the main view of the application. It consists of a `UITableView` that shows all shifts that are owned  
by the user. The class has an upadateSchedule() method that ensures the user's fixed shifts are always preloaded  
eight weeks ahead. Cells are highlighted to indicate their status. Selecting a row in the UITableView summons a `UIActionController` with actions related to the  
status of the shift. The `+` sign in the upper right corner triggers a segue to the SubmitRoosterViewController. 
   - Has segue to: SubmitRoosterViewController

###### AangebodenViewController: ContentViewController, UITableViewDelegate, ActionSheetDelegate
This is the marketplace. All shift that are supplied by users are displayed. Also for this view goes, that selections prompts
a `UIALertController` Shifts owned (ergo supplied) by the current userare highlighted in red and can be revoked. Once a shift
has been revoked or accepted, it dissapears from the marketplace. This means that accepting a supplied shift is final. The
accept action makes the shift go through a set of checks to make sure it is a legal action (eg. whether the user already owns
a shift on that day).

###### GezochtViewController: ContentViewController, UITableViewDelegate
Whenever a user has free time on his/her hands and want to work some extra shifts, instead of looking through the marketplace for a match, he/she can post requests in the GezochtViewController. Requests are done by date and their can be as much as one wants. Requests made by the current user are (like in the rest of the application) highlighted in red. Selecting a row triggers a segue to either the SuggestionOverviewViewController or the SuggestionViewController, depending on ownership of the request. The segue is prepared by storing the objectID of the selected request in a property of the destinationViewController.
   - Has segue to: SuggestionOverviewViewController
   - Has segue to: SuggestionViewController

###### SubmitRoosterViewController
Simple View with two `UITextField` and a `UIButton` to submit. One textfield is for the day of the week, one textfield is for the starting time of the shift. The inputfield of the textfields is a `UIPickerView` with two components: day and  time. Pressing the button will save the shift to the FixedShift class in the database. Also, a function will be called to generate Shift objects in the database for eight weeks ahead.

###### CustomPFLoginViewController: PFLoginViewController
Has an empty view that is the intial viewcontroller. In the `viewDidAppear` method of the view controller, a `PFLoginViewController` is created. This handles all login and signup functionality of the application.

###### SelectRequestViewController, UITableViewDelegate
`UITableView` that shows dates on which the user is able to take on an extra shift. The table view allows multiple selection so the user can post a request for multiple dates at once. Loading time is fairly long. Seperate queries has to be made to the database and those results have to be checked againt a set of generated dates. I have an idea to already retrieve this information in the previous viewcontroller, and have it ready when needed. But I didn't have the time to implement this.

###### SuggestionViewController: ContentViewController, UITableViewDelegate
Shows a `UITableView` with the current user's personal schedule. The difference with the RoosterViewController is that shifts that are irrelevant to the associated request, are inactive. Only shifts on the corresponding day can be selected and suggested.

###### SuggestionOverviewViewController: ContentViewController, UITableViewDelegate, ActionSheetDelegate
Shows a `UITableView` with shifts that are suggested the the request by other users. The current user can select one of the suggestions and accept it. After accepting, it has to be approved until the change is made final. When it is final, the associated request gets deleted from the database and the other suggested shifts get reset to idle.

##### Protocols
- HasDate (Used to get sections header titles and get their contents)
   - var date
   - func getWeekOfYear() // returns "Week 27" for june 30th
- ExistsInParse (Used to make function with generic type <T: ExistsInParse where T: HasDate>)
   - init(parseObject: PFObject)
- AcitonSheetDelegate (to be able to call certain ViewController functions from the ActionSheet)
   - func getData()
   - func setActivityViewActive(on: Bool)
   - optional func popViewController()
   - optional func showAlert(alertView: UIAlertController)
   - optional func showAlertMessage(message: String)

##### Classes

###### Content
###### Shift: Content
###### Request: Contnet
###### Helper
###### Rooster
###### ActionSheet
###### Constants (not a class)

##### Database






## Experience

##### Hurdles
##### Gained insights
##### Recommendations to self
