# Shifty
My submission for the course Programming Project 2015.

###### Language disclaimer
This proposal and all other documentation will be written in English. However, the UI of the app will be in Dutch. For this reason, sometimes Dutch words will appear in either the code, the comments and the documentation. I will be consistent and do my best to distinguish them from the rest as good as possible.

## The idea ##
Shifty is a marketplace for shifts whithin small businesses. The app alows employees to view each others scheduele and post request for shifts that they want to be filled in by others or volunteer to work a certain shift. All this information will be available to all relevant employees at the company. This idea came to mind because I work at a restaurant where all servers are part-timers that study/have a life on the side. All this (trading shifts) is currently done via What's-app and there is no overview of all the activity, which is cause for disputes from time to time.

##### Funcionality:
- Requesting a replacement
- Volunteer to work a shift (or accept a request)
- Overview of personal scheduele
- Overview of submitted requests

## Possible complications ##
For this app to be usefull, it must have networking functionality. This is something that is new to me, but very willing to figure out. However, this may proof itself to be more complicated than expected.  
A real world issue is that the app will only be available on iOS devices and it won't reach it's full potential until the data can be shared between all (or the most common) platforms. In the future, I will write a web based application to compliment the by existing iOS app and overcome this problem.

## Planning ##

| Week | Goal | Description |
|:------:|:------:|---------|
|1     | Interface and documentations | Proposal + Design document. And also implement a working interface in the Xcode storyboard. Working segues (with hard-coded content) |
|2     | User profiles | Let new users create a profile and fill in their weekly schedule |
|3     | Interaction | User can engage with the weekly schedule and reply to requests |
|4     | Refactoring | Clean up de code and optimize performance and interaction |

## Sketches ##

##### Log in/Sign up
This is provided by the Parse framework. New users can sign up via the "SIGN UP" button. The right screen is a sketch of the sign up screen (minimum info required). A returning user can log in.  
![Log in](/doc/login.png)

##### Main view
This is where all the app functionality takes place. The main view consists of a tab controller with three subviews. *Rooster* where the user's personal schedule can be viewed (left). From here the user can send requests to the marketplace. The market place is split up into two sections: *Gezocht* (middle) and *Aangeboden* (right). In these sections a user can view requests from either poeple who are looking for a replacement and volunteering to fill-in shifts respectively.
In the *Rooster* tab, shifts that sent to the market place will be highlighted in a particular color. Shifts that are owned by the user (fixed, or taken from a colleague) are not.  

| Color | Status |
|-------|--------|
| Orange| Open request |
| Green | Awaiting approval |

![Main view](/doc/tab_view.png)

If their is no schedule known, the *Rooster* subview will show a text to let the user know it has to submit their fixed schedule.  
![Empty schedule](/doc/empty.png) ![New schedule](doc/nieuw_rooster.png)

##### Options
To send or reply to a request, the user has to swipe left on a table cell. This wil cause a button to appear that can be tapped to preform the approprate action. For now, this is either sending (left) or accepting (right) a request.
![Swipe options](/doc/swipe_options.png)

