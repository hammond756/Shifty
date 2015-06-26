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

###### LoginViewController
Has an empty view that is the intial viewcontroller. In the `viewDidAppear` method of the view controller, an instance of a customized subclass of `PFLoginViewController` is created. This handles all login and signup functionality of the application. That code is predefined in the object.

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

###### Content: HasDate, ExistsInParse, Equatable
Superclass for all data that is displayed in the application.
- date: NSDate
- owner: PFUser
- objectID: String
- dateString: String
- init(date: NSDate, owner: PFUser, objectID: String)
- conveniece init(parseObject: PFObject)
- func getWeekOfYear() -> String
- func isOnSameDayAs(other: NSDate) -> Bool

###### Request: Content
Most related subclass of Content. Only implements its own convenience init to get values from PFObject and then calls super.init

###### Shift: Content
More elaborate subclass of Content. Adds the following properties and adapted initializers
- var timeString: String
- var status: String
- var createdFrom: PFObject
- var acceptedBy: PFUser?
- var suggestedTo: PFObject?

###### Helper
Strictly called by other classes/viewcontrollers. This class is a collection of frequently used fuctions. Because there many similar operation that need to be preformed on different datatypes and that data has to be stored in a different proprety. For this  reason the code started out with a lot of semi-ducplicate function. It was a challenge to comprise them into general functions. Finally found a fix by using protocals and generic argument types.

###### Rooster
Gets the information needed for the Content subclasses from the database and stores it locally. This is the model of the application. All information displayed by the view controllers comes from the Rooster class. Its properties are:
- ownedShifts: [[Shift]]
- suppliedShifts: [[Shift]]
- requestedShifts: [[Request]]
The data is stored in two-dimensional arrays, in which each sub-array consists of shifts/requets in a certain week. This matches well with the way a `UITableView` loads its data.

###### ActionSheet
This class is dedicated to the creation of `UIAlertController` instances. Because the definition of some `UIAlertActions` are very long and those actions are used in more than one place in the code, I decided to group them all in a single class. Each action has it's own function creating it. That function stores it in an array called actionList: [UIAlertAction]. Then there is a function called includeActions(actions: [String]) that iterates over the supplied actions. In each iteration a switch statement is checked and the creation function corresponding to the action string is executed. Finally, to create the 'UIAlertController', a viewcontroller calls the getAlertController() method which includes all the created actions.
Some ations may show a `UIAlertView` in some cases. These are also defined in the class.

###### Constants (not a class)
A collection of structs that declacre constants commonly used in the code. This was a practical and stylistic decision. I encountered a lot of errors due to typo's in strings. This fixed that, since the string-literal only has to be typed one. The constants are seperated into catogories:

- constant (uncategorized)
- weekday ("Maandag" tm/ "Zondag")
- segue (Segue identifiers)
- status (Possible shift statusses)
- action (strings used to include `UIAlertAction`)
- label (labels vor `UIAlertController` butttons)
- highlight (color definitions)
- parseClass (names of database classes)
- parseKey (titles of database keys)

##### Database

|User|objectId|username|password|authData|emailVerified|email|createdAt|updatedAt|ACL|
|----|--------|--------|--------|--------|-------------|-----|---------|---------|---|
|    |String|String|String(hidden)|authData|Boolean|String|Date|Date|ACL|
After signing up with a username, password and email adress, a user object gets created in the database. As for now there is not yet email verification or a group identifier. But this can be of use in the future to verify and distinguish between groups of employees.

|FixedShifts|objectId|Day|Hour|Minute|Owner|lastEntry|createdAt|updatedAt|ACL|
|-----------|--------|---|----|------|-----|---------|---------|---------|---|
|           |String|String|Number|Number|Pointer<_User>|Date|Date|Date   |ACL|
When a user registers a fixed shift, the day and time get stored in FixedShifts allong with a pointer the the user that created it. the lastEntry key is used for keeping shifts generated for enough weeks ahead

|RequestedShifts|objectId|Date|requestedBy|createdAt|updatedAt|ACL|
|---------------|--------|----|-----------|---------|---------|---|
|               |String  |Date|Pointer<_User>|Date  |Date     |ACL|
This table saves all the request made by user (relevant data are Date andt requestedBy)

|Shifts|objectId|Date|Owner|Satus|acceptedBy|suggestedTo|createdFrom|createdAt|updatedAt|ACL|
|------|--------|----|-----|-----|----------|-----------|-----------|---------|---------|---|
||String|Date|Pointer<_User>|String|Pointer<_User>|Pointer<_RequestedShift>|Pointer<_FixedShift>|Date|Date|ACL|
Shifts is the main table in the database. All shifts get stored here, with information about ownership and status. When the status is Suggested or Awaitting approval, suggestedTo and acceptedBy indicate either the related Request or User respectively. createdFrom is a pointer to the fixed shift that corresponds with the date and user.


## Experience

##### Hurdles
- Asynchronous operations (getting/saving data)
- Corner cases (consistent data)

This was the first time working with a database. But luckily, thanks to Parse.com, that wasn't such a big issue. The issue was that the retrieving and saving of data happens asynchonously. Therefore it wasn't so clear cut as wat to do with respects to modularization. At first, all code that retrieved data for a certain view was inside that views controller. But I soon found that unworkable and verry messy. Then I found out about callbacks, which gave me the capablities to seperate the retrieving of the data and the loading of the views. Although I find this a good solution, it still feels off. There is a somewhat intricate web of callbacks that makes it somewhat tougher to see what's going on under the hood.
Another issue, that I only found out this week, was that my application was very leaky with respects to the data. Jaap did a stress test to find bugs, and he did. So I've spent some time torture proofing the app. In this process I found out that it is like a game of wack-a-mole. Fix something, another thing pops up. In the future it will be wise to list all the corner cases I can think of beforehand, and base the design on that list.

##### Gained insights
- Delegation
- Callback functions
- Generic types

The good thing about hurdles is that they give you the opportunity to learn. Because the database and all related issue are critical to my application, I had to find a way to solve the problems and this helped shape my understanding of them. During the AppStudio course, there was a lecture about delegation but I never really understood it's use. But, while implementing the ActionSheet class I ran in to the problem of wanting to reload a `UITableView` with no reference to in inside the class. First I passed the `UIViewController` instance as an agrument to the initializer (that was dumb, I know). But then a classmate (Elias) suggested delegation and it was the perfect solution for my issue. As mentioned above, I also started using callbacks for the first time. I first encountered them in the findObjectsInBackgroundWithBlock() { } functions, but didn't know what they were exactly. Later, I started defining my own functions with callbacks (still not knowing what's really going on). One moment, it just snapped and I got the hang of it. I might have gone overboard though..
Another feauture of swift (and maybe of other laguages as well) I was exited about finding is the use of generics. Because I had some function that did exactly the same operations on different data types, I could delete dozens of lines of code by just defining a protocol an writing the function for a generic type with that protocol.

##### Recommendations to self
I came up with the idea for this app because of the unorganized way that my colleauges and I trade our shifts. In the four weeks we had for this project, I think I've made incrediple progress and built a good application. However, it is not yet fit for the real world. The functionality that has to be added in order for this to be viable are:
- Direct shift-for-shift trading
- Administrator access to approve shifts remotely and manuge the fixed shifts
- Web-based acces for non-iOS users
- Streamlining the UI

This was the last course of the minor programming (which I really enjoyed). I signed up because I've always been interested in programming, but never got to really doing it on my own. Now I think I have reached a level of skill that is sufficient to keep on building things on my own and improve myself. I hope to continue work on Shifty and roll-out a real-world test at the restaurant where I work.
