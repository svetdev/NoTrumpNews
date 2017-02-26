# NoTrumpNews

## About
NoTrumpNews is a mobile application that shows news articles in an easy and interactive way. iOS app written in Swift that is using API’s from New York Times.

## API
News API: https://developer.nytimes.com/

Api key: f6e2d6b3c665456682199045287b03fd

## Endpoints: 
GET: https://api.nytimes.com/svc/topstories/v2/home.json?api-key={api-key}

Example top stories for home request: 
https://api.nytimes.com/svc/topstories/v2/home.json?api-key=f6e2d6b3c665456682199045287b03fd

Example top stories for world request: https://api.nytimes.com/svc/topstories/v2/world.json?api-key=f6e2d6b3c665456682199045287b03fd

## Usage
How to run a project:
If you don’t have cocoapods installed on your mac, please follow the next steps:
* Open Terminal and type the following command
* sudo gem install cocoapods

After you install cocoapods, follow the next steps:
* Navigate to the project folder in Terminal
* Type pod install, press Enter and wait until all the frameworks are downloaded.
* Go to NoTrumpNews folder of the project and open NoTrumpNews.xcworkspace.

## Screenshots


## Features
1. No articles that has “Trump” within a title is shown
2. TableView and CollectionView
3. Save to ‘My Articles’
4. Share an article
5. Search within collection
6. UI defined in code 
