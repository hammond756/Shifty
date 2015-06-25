# REPORT

## Structure

##### ViewControllers

###### RoosterViewController
This is the main view of the application. It consists of a UITableView that shows all shifts that are owned  
by the user. The class has an upadateSchedule() method that ensures the user's fixed shifts are always preloaded  
eight weeks ahead. Cells are highlighted to indicate their status. Selecting a row in the UITableView summons a UIActionController with actions related to the  
status of the shift. The "+" sign in the upper right corner triggers a segue to the SubmitRoosterViewController. 
   - Has segue to: SubmitRoosterViewController

###### AangebodenViewController
This is the marketplace. All shift that are supplied by users are displayed. Also for this view goes, that selections prompts
a UIALertController Shifts owned (ergo supplied) by the current userare highlighted in red and can be revoked. Once a shift
has been revoked or accepted, it dissapears from the marketplace. This means that accepting a supplied shift is final. The
accept action makes the shift go through a set of checks to make sure it is a legal action (eg. whether the user already owns
a shift on that day).

###### GezochtViewController
Whenever a user has free time on his/her hands and want to work some extra shifts, instead of looking through the marketplace for a match, he/she can post requests in the GezochtViewController. Requests are done by date and their can be as much as one wants. Requests made by the current user are (like in the rest of the application) highlighted in red. Selecting a row triggers a segue to either the SuggestionOverviewViewController or the SuggestionViewController, depending on ownership of the request. The segue is prepared by storing the objectID of the selected request in a property of the destinationViewController.
   - Has segue to: SuggestionOverviewViewController
   - Has segue to: SuggestionViewController



##### Classes






## Experience

##### Hurdles
##### Gained insights
