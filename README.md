# AWESOME PHOTOS

An iOS applicationn that allows users to take photo/media and store them on the Cloud (Firebase specifically). Photos/Medias can also be shared to other users.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Features
- User can register and login to our application using their email account.

- Once logged in, a user can: 
+ Change their password
+ Take a picture or a video.

- After capturing a media, the media can be uploaded to Firebase Storage. The upload/save to local process can be done manually by pressing the upload/save button or it can be set automatically in the Settings screen.

- Each user can add owner or share their medias to other users. By adding an owner, the original copy of the photo is given to the owner(s) and by sharing, a watermarked copy will be shared.

- A user can also edit the permission of their photos or videos.



### Prerequisites

What things you need to install the software and how to install them

```
Swift Version 5
Xcode 9.3 or Higher
```

### Installing
```
pod install
change bundle identifier to a unique identifier

```

## Built With

* [XCode](https://developer.apple.com/xcode/)

## Database and Services used

* [Firebase Authentication](https://firebase.google.com/docs/auth)
* [Cloud Firestore](https://firebase.google.com/docs/firestore)
* [Cloud Storage](https://cloud.google.com/storage/)
* [Cloud Functions](https://cloud.google.com/functions/)

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Pham Minh Quang** - *Initial work*
* **Minh Kha Pham** - *Initial work*
* **Pham Minh Quang** - *Initial work*
* **Nguyen Duc Thien Hieu** - *Initial work*
* **Rasmus Bak Petersen** - *Initial work*
* **Duong Viet Trung** - *Initial work*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

Libraries used: 
* https://github.com/danielgindi/Charts - Pie Chart
* https://github.com/rubygarage/media-watermark - Watermark
* https://firebase.google.com/docs/auth - Firebase Authentication
* https://firebase.google.com/docs/firestore - Firebase Firestore
* https://firebase.google.com/docs/storage - Firebase Storage
* https://github.com/SnapKit/SnapKit - Snapkit
* https://github.com/raulriera/TextFieldEffects - TextFieldEffects
* https://github.com/ReactiveX/RxSwift - RxSwift
* https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa - RxCocoa

References: 
* http://khou22.com/ios/2016/08/10/swift-navigation-basics-how-to-setup-a-simple-tab-bar-app.html
* https://www.youtube.com/watch?v=2-nxXXQyVuE
* https://www.youtube.com/channel/UCuP2vJ6kRutQBfRmdcI92mA
