#  Photo List - VNPAY Code Challenge iOS Developer

## Functionality
The goal of this app is to display a list of images from the Picsum API.
* No external libraries used.
* Framework UIKit, with Programmatic UI
* Use UITableViewDataSourcePrefetching in ViewController to preload images of upcoming cells.
* Follows Clean Architecture Priciple - Divided into 3 layers: Presentation Layer: Contains UI (View); Domain Layer: Declare Model; Data Layer: Process API.
* Design Pattern: Singleton - By using NSCache as a singleton for image caching, it helps reduce image reloading -> optimize performance.
* Unit Test for testing fetch and load photo.

## Video demo app
Check out the app demo here:

[![Demo App](https://img.youtube.com/vi/hry51-SvgK8/0.jpg)](https://youtu.be/hry51-SvgK8)

## How to Run
- Open the project in Xcode.
- Build and run on a simulator or device (iOS 12+).