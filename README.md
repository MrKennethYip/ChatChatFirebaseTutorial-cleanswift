## Running Tests
Run tests via commandline: ./runTestsScript.sh
The script makes a call to xcodebuild to run the tests on iPhone 7 OS10.2. 
xcodebuild test -workspace ChatChat.xcworkspace -scheme ChatChat -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2'

## Architecture
For this application, it was simple enough that we could have gone with MVC, MVVM, ReactiveCocoa, or VIPER, in the end I chose the clean-swift architecture with a one-directional VIP. 
Reasons are below:
1. One of the primary goals of this project is to be able to swap between different backends. The idea of having workers that interface directly with any backend via a protocol decouples and allows the workers to switch between different backend implementations.

For example:
#LoginInteractor
var loginWorker: LoginWorker = LoginWorker(loginApi: FirebaseBackend())

In the future, if we need to migrate and move functionality, we can easily switch out to the new implementation scene by scene by updating the loginApi to use NewCustomBackend(). 
_var loginWorker: LoginWorker = LoginWorker(loginApi: NewCustomBackend())_

2. Simplicity. From my expereince making mobile applications, the one directional VIP makes it very clear the responsibilities of each component of ViewController, Interactor, Presenter, Worker, Router

## Refactoring 
1. Refactor and decouple networking and database logic into another class
2. Introduce the clean-swift archtiecture by updating viewcontrollers to clean swift VIP strcture and ensure it compiles
3. Update one viewcontroller at a time to clean-swift into a scene group and corresponding model, interactor, presenter, worker, and tests. 

## Testing decisions
1. For unit testing, we test boundaries between the components. For each of the methods in the boundaries, we test the input and outputs of the method.
2. In ViewController, we test to ensure the interactor is called via the _BusinessLogic_ protocol. We test to ensure that when the display logic is called from the presenter via the _DisplayLogic_ protocol it updates the views accordingly. The viewcontroller's responsibility is to manage the view - updating the view, passing data to view, receiving input from the view and etc.
3. In Interactor, we test actions made to the viewcontroller results in a call to the interactor. We also test to ensure that the corresponding calls are made to presenter via _PresentationLogic_ protocol accordingly. As the interactor holds the business logic, any business logic should also be tested here. 
4. In Presenter, we test calls made in presenter formats the data correctly and makes the corresponding to the viewController via the _DisplayLogic_ protocol to update the view. As the presenter passes data to be shown in the view, it should format the data correctly to be viewed.
5. Additional tests can be added for Backend/Networking code as needed.

![alt text](https://raw.githubusercontent.com/swiftingio/blog/%2324-Architecture-Wars/Images/VIP.png)




