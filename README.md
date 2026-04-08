# Vision Quest

**Vision Quest** is an iOS application that scans the user’s Photo Library, detects faces in images using Apple’s Vision Framework, and allows users to identify and tag individuals.

## Features
- **Photo Library Integration:** Gracefully requests and handles read/write permissions to the user's photo gallery.
- **Background Scanning & Detection:** Efficiently scans the photo library for images containing faces using `VNDetectFaceRectanglesRequest`.
- **Bounding Box Overlay:** Accurately calculates and overlays bounding boxes on detected faces in the Image detail view.
- **Tagging System:** Allows users to tap on any detected face and enter a name to "tag" the individual.
- **Search & Suggestions:** A clean UI to see suggestions of previously tagged people, making the tagging process smoother.
- **Offline Persistence:** Uses Core Data to store face detection results, scanned assets, and tagged individuals so scanning only happens for new photos.

## Architecture & Design Patterns
This application follows a strict **Clean MVVM Architecture** enhanced with **Builder** and **Router** patterns (a hybrid of MVVM and VIPER), aiming for a clear separation of concerns, testability, and modularity.

- **View:** Display UI and forward interactions to the ViewModel.
- **ViewModel:** Handles presentation logic and communicates with Workers.
- **Builder:** Responsible for dependency injection and Module construction.
- **Router:** Handles navigation logic between different modules.
- **Worker / Service:** Abstract the business logic and external APIs (Photo Library, Vision, Core Data).
- **Repository Pattern:** Abstracted Data Access Layer for Core Data (e.g., `FaceRepository`, `ScanStatusRepository`).

## Assumptions Made
- The app should prioritize the user's privacy; everything is scanned and processed locally on-device. No data leaves the device.
- Vision's face detection `VNDetectFaceRectanglesRequest` provides the bounding boxes, but the app does not do automatic face *recognition* (clustering). The user is meant to manually tag faces.
- Core Data is used as the single source of truth for "which photos have been scanned" and "who has been tagged".
- UI must gracefully handle various states (e.g. Loading, Empty, Permission Denied), ensuring a smooth UX layer.

## Design Decisions & Rationale

**1. Why Core Data over UserDefaults or FileManager?**
- **UserDefaults:** Best suited for lightweight, simple key-value pairs (like user preferences). It is inefficient and unsafe for storing complex object graphs or large arrays of data.
- **FileManager:** While storing custom data files on disk is possible, it lacks native querying. Finding a specific face or filtering assets would require loading the entire dataset into memory.
- **Core Data:** Selected because it provides robust object graph management backed by SQLite. It offers fast querying (fetching only unscanned photos), efficient memory management through faulting, and built-in support for complex entity relationships.

**2. Why the Repository Pattern?**
- **Abstraction & Separation of Concerns:** It hides the complexities of Core Data (like `NSManagedObjectContext` and `NSFetchRequest`) behind a clean, protocol-based interface.
- **Testability:** By depending on repository interfaces, we can easily inject mock repositories during unit testing.
- **Reusability:** It centralizes data access logic, preventing boilerplate Core Data code from bleeding into ViewModels or Workers.

**3. Why use different classes for Core Data (Entity) and Data (Domain Model)?**
- **Loose Coupling:** By mapping `NSManagedObject` instances (like `CDFace`) to pure Swift struct models (like `Face`) at the repository boundary, we prevent Core Data frameworks and context-threading constraints from leaking into the UI or Business Logic layers.
- **Flexibility:** If we ever switch to another persistent storage solution (like SwiftData or Realm), we only have to rewrite the mapping inside the Repository. The UI and application logic remain completely unaffected.

**4. Why use so many dependencies and architectural layers?**
- **Scalability and Maintenance:** Utilizing Builders, Routers, ViewModels, Workers, and Repositories explicitly demonstrates the ability to build scalable, production-ready iOS apps. 
- **Avoiding Massive View Controllers:** This architecture strictly enforces the Single Responsibility Principle, making the codebase highly modular, easy to read, testable, and straightforward to expand in an enterprise environment.

## Challenges & Solutions
**1. Performance and Memory Management when Scanning:**
- **Challenge:** Scanning thousands of photos for faces simultaneously can easily lead to memory warnings and app crashes, especially when loading full-resolution images.
- **Solution:** Moved face detection to a background queue (`DispatchQueue.global`). Used autoreleasepools inside the detection loops to immediately release memory from heavy `CGImage` and `VNImageRequestHandler` objects instead of waiting for the thread to complete.

**2. Asynchronous Bounding Box Coordinates:**
- **Challenge:** Apple's Vision framework returns bounding boxes in a normalized coordinate system (0.0 to 1.0) with a bottom-left origin. Translating this to UIKit's coordinate system (top-left origin) accurately across different screen sizes and aspect ratios (`aspectFit`) is tricky.
- **Solution:** Implemented coordinate transformation logic within `FaceBoxView` and ViewModel to properly scale and flip the Y-axis based on the displayed image's absolute pixel size and layout constraints.

**3. Efficient Re-Scanning Strategy:**
- **Challenge:** Every time the app launches, re-scanning the entire library would be very slow and battery-intensive.
- **Solution:** Tracked `CDScannedAsset` in CoreData. The app only fetches new or unscanned asset identifiers, performing delta updates to significantly improve performance.

## How to Run The App
1. Clone this repository to your local machine.
2. Open `Vision Quest.xcodeproj` using Xcode 15 or later.
3. Ensure the active scheme is set to **Vision Quest**.
4. Select a Simulator or physical iOS device (iOS 15.0+).
5. Press `Cmd + R` or click the **Play** button to build and run the application.

https://github.com/user-attachments/assets/8638eafd-fa68-4c22-a184-71eced4258c3

https://github.com/user-attachments/assets/d199d320-66a1-411b-a9db-806d0fc7e04c
