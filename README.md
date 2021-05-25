# Vanderhoof Chamber of Commerce App
Please visit https://www.vanderhoofchamber.com/

Technologies used:  
Flutter SDK 2.2.0,   
Firebase: FlutterFire, Firestore database, Firebase Storage. 

## Introduction
The Vanderhoof Chamber of Commerce App consists of two apps: the User App, and the Manager App.
This Readme file is for the User App. 

The Vanderhoof Chamber User App is intended for the general public. This app presents to the user 
information regarding the town of Vanderhoof, BC, which includes a business directory, events, 
hiking trails, recreational information, and additional business resources.

The users of the User App are only able to view contents while the manager app allows for the 
addition, modification, and deletion of contents.

## Navigation within the App
There is no login feature in the User App.
Navigation between the five main categories of information are done through clicking the icons in 
the bottom navigation bar.

Information in each category are displayed in a expandable list.

- Business Directory: 
Hideable Map of the town at the top of page. Icons represent the businesses 
in Vanderhoof. Clicking on a business expands the tile and reveals more information. Business Email,
Website, Phone number, and Social Media Icons can be clicked. 

- Business Resources:
Additional resources about the Chamber of Commerce and also information for prospective business 
owners on how to become a member.

- Events
Upcoming Events in the Town of Vanderhoof. 

- Hiking Trails
Trail information near the Town of Vanderhoof. Each Trail can be clicked to display additional details
and point of interests on the trail.

- Recreational
Recreational facilities in the town of Vanderhoof.

## Technical
This app was developed first with the User App, then the addition and deletion features of the app
was separated and migrated to the Manager App.

- Each of the Category has its own dart file: business.dart, resource.dart, event.dart, hike.dart, 
and recreation.dart. 
- The map.dart is used by Business Directory Page, Hiking Trails Page, and Recreational Page to 
display a GoogleMap of Town of Vanderhoof. 
- The cards.dart contains the Card UI Classes for each page. 
- The hikeInformation.dart contains details of hiking trails displayed by hike.dart.
- The fireStoreObjects.dart contains Object Classes for each page for the purpose of easy 
communication with Firebase.
- The commonFunciton.dart contains some shared functions.
- The data.dart contains hard-coded data of all the business categories (from the Vanderhoof Chamber
website).
- Scraper.dart is no longer used.

The five main pages: business.dart, resource.dart, event.dart, hike.dart, and recreation.dart are 
not connected with one another, but they share similar architecture, and use the other support 
dart files: map.dart, cards.dart, fireStoreObjects.dart, commonFunctions.dart.