# LogView

[**LogView**]([https://kean.blog/pulse/home](https://github.com/alexejn/LogView)) is a powerfull and modern log viewer for iOS. Native. Built with SwiftUI.

Inspired by new [structured debug console in Xcode 15](https://developer.apple.com/videos/play/wwdc2023/10226/) (WWDC 2023)

<img width=20% alt="image" src="https://github.com/alexejn/LogView/assets/19667729/3482113d-6131-4e76-93ac-661ecb3b4665">
<img width=20% alt="image" src="https://github.com/alexejn/LogView/assets/19667729/c2645bdd-1173-4410-b693-c7b3f33d8c05">
<img width=20% alt="image" src="https://github.com/alexejn/LogView/assets/19667729/d5de6c7a-593c-4df2-a718-a210e88068ef">

## How it works

LogView works like debug console in Xcode. Any log you write with [`Logger`](https://developer.apple.com/documentation/os/logger) will be visible in LogView
```swift
import os 

let logger = Logger(subsystem: "com.myapplication", category: "auth")

logger.error("Can't authorize - service is unavailable")

```
<img width=15% alt="image" src="https://github.com/alexejn/LogView/assets/19667729/39cf7bea-a265-4bcb-93b4-a6f10fea5500">
<img width=15% alt="image" src="https://github.com/alexejn/LogView/assets/19667729/3131f886-1884-48bc-a671-d0d3f6048c60">

## How to integrate

```swift
import LogView

struct ContenView: View {
  @State var logViewPresented: Bool = false

  var body: some View {
    Text("Its my main view")
      .onAppear {
        // Setup predicate to get only my application log, otherwise you get tons of apple system logs
        LogView.predicate = .subystemIn(["com.myapplication"], orNil: false)
      }
      // Present as sheet on shake
      .onShake { 
        logViewPresented = true
      }
      .sheet(isPresented: $logViewPresented, content: {
        // Wrap LogView in NavigationView or NavigationStack
        NavigationView { 
           // The package available since iOS 14, but to see LogView app should be run on iOS 15 and upper 
           if #available(iOS 15.0, *) {
              LogView()
            } else {
              Text("Run your app on iOS 15 and upper")
            }
        }
      })
  }
}

```
If you wonder [How to realize onShake modifier](https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-shake-gestures)

You can also specified additional filter behavior if you wish
```swift
  LogView.filterEntries = { log in
    log.sender == "DataFramework" // To get logs only from this library
  }
```

LogView is just SwiftUI View you can integrate as any other view. If you have some debug panel which you use while debug & developing, its good to integrate LogView in it. 


## How to get

LogView comes as Swift Package. Use SPM to integrate it in your app. 


## License

LogView is available under the MIT license. See the LICENSE file for more info.
