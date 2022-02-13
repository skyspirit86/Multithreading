//
//  ViewController.swift
//  Multithreading
//
//  Created by Zolt Varga on 02/10/22.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Private
    
    private var workItem: DispatchWorkItem?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
        
        // 1. TEST: Serial Queue
        // exampleSerialQueue()
        
        // 2. TEST: Concurrent Queue
        // exampleConcurrentQueue()
        
        // 3. TEST: Simple background - UI Switch
        // exampleBackToMain()
        
        // 4. TEST: Group Dispatch
         exampleRunDispatchGroup()
        
        // 5. TEST: Dispatch Work Item
        // exampleRunDispatchWorkItem()
        
        // 6. TEST: OperationQueue Serial
        // exampleOperationQueueSerial()
        
        // 7. TEST: OperationQueue Concurrent
        // exampleOperationQueueConcurrent()
        
        // 8. TEST: OperationQueue Groupoing with Dependecy
        // exampleOperationQueueGroupWithDepenecy()
        
        // 9. TEST: Dispatch Barrier
        // exampleDispatchBarrier()
        
        // 10. TEST: Async / Await
        // exampleAsyncAwait()
        
        // 11. TEST: DispatchSource. Monitor File changes
        // exampleDispatchSource()
    }
    
    // MARK: - Async / Await
    func exampleAsyncAwait() {
        print("Task 1")
        Task { // 2. Create Task {} Block to be in regular method to handle the Async method 'make'
            let myBool = await make() // 3. Await the method result
            print("Task 2: \(myBool)")
        }
        print("Task 3")
    }
    
    func make() async -> Bool { // 1. Create method what rsult is async
        sleep(2)
        return true
    }
    
    // MARK: - DispatchSource
    func exampleDispatchSource() {
        let urlPath = URL(fileURLWithPath: "/PathToYourFile/log.txt")
        do {
            let fileHandle: FileHandle = try FileHandle(forReadingFrom: urlPath)
            
            let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileHandle.fileDescriptor,
                                                                   eventMask: .write, // .all, .rename, .delete ....
                                                                   queue: .main) // .global, ...
            source.setEventHandler(handler: {
                print("Event")
            })
            
            source.resume()
        } catch {
            // Error
        }
    }
    
    // MARK: - Dispatch Barrier
    func exampleDispatchBarrier() {
        let concurrentQueue = DispatchQueue(label: "com.kraken.barrier", attributes: .concurrent)
        
        for a in 1...3 {
            concurrentQueue.async() {
                print("🔵 AsyncTask \(a)")
            }
        }
        for b in 4...6 {
            concurrentQueue.async(flags: .barrier) {
                print("🔴 Barrier \(b)")
            }
        }
        for c in 7...10 {
            concurrentQueue.async() {
                print("🟢 SyncTask \(c)")
            }
        }
    }
    
    // MARK: -  Operation Queue Group With Depenecy
    func exampleOperationQueueGroupWithDepenecy() {
        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }
        let taskCombine = BlockOperation {
            print("taskCombine")
        }
        taskCombine.addDependency(task1)
        taskCombine.addDependency(task2)
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        let tasks = [task1, task2, taskCombine]
        operationQueue.addOperations(tasks, waitUntilFinished: false)
    }
    
    // MARK: - Operation Queue Concurrent
    func exampleOperationQueueConcurrent() {
        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }
        let concurrentOperationQueue = OperationQueue()
        concurrentOperationQueue.maxConcurrentOperationCount = 2
        let tasks = [task1, task2]
        concurrentOperationQueue.addOperations(tasks, waitUntilFinished: false)
    }
    
    // MARK: - Operation Queue Serial
    func exampleOperationQueueSerial() {
        let task1 = BlockOperation {
            print("Task 1")
        }
        let task2 = BlockOperation {
            print("Task 2")
        }
        
        task1.addDependency(task2)
        let serialOperationQueue = OperationQueue()
        let tasks = [task1, task2]
        serialOperationQueue.addOperations(tasks, waitUntilFinished: false)
    }
    
    // MARK: - Serial Queue
    func exampleSerialQueue() {
        let serialQueue = DispatchQueue(label: "com.kraken.serial")
        serialQueue.async {
            print("SerialQueue test 1")
        }
        serialQueue.async {
            sleep(1) // Sleep execution for 1 sec
            print("SerialQueue test 2")
        }
        serialQueue.sync {
            print("SerialQueue test 3")
        }
        serialQueue.sync {
            print("SerialQueue test 4")
        }
    }
    
    // MARK: - Concurrent Queue
    func exampleConcurrentQueue() {
        let concurrentQueue = DispatchQueue.global()
        concurrentQueue.async {
            print("ConcurrentQueue test 1")
        }
        concurrentQueue.async {
            sleep(2) // Sleep execution for 2 sec
            print("ConcurrentQueue test 2")
        }
        concurrentQueue.async {
            sleep(1) // Sleep execution for 1 sec
            print("ConcurrentQueue test 3")
        }
        concurrentQueue.async {
            print("ConcurrentQueue test 4")
        }
    }
    
    // MARK: - Example of Bakckground / Main Thread Switch
    func exampleBackToMain() {
        DispatchQueue.global(qos: .background).async {
            print("🔵 DispatchQueue.global Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
            DispatchQueue.main.async {
                print("🔵 DispatchQueue.main Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
            }
        }
    }
    
    // MARK: - Example of Dispatch Group
    func exampleRunDispatchGroup() {
        print("🔴 exampleRunDispatchGroup Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
        
        // 1. Create Dispatch Group
        let group = DispatchGroup()
        
        // 2.a. Long running Task 1
        group.enter()
        runLongRunningTask1(completion: {
            print("🔴 DispatchGroup: Long running Task 1 finished. Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
            self.button1.isEnabled = true
            self.button1.backgroundColor = .blue
            group.leave()
        })
        
        // 2.b. Long running Task 2
        group.enter()
        runLongRunningTask2(completion: {
            print("🔴 DispatchGroup: Long running Task 2 finished. Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
            self.button2.isEnabled = true
            self.button2.backgroundColor = .blue
            group.leave()
        })
        
        // 2.b. Long running Task 3
        group.enter()
        runLongRunningTask3(completion: {
            print("🔴 DispatchGroup: Long running Task 3 finished. Thread name: \(Thread.current.name ?? "none") IsMain: \(Thread.isMainThread) IsMultithread: \(Thread.isMultiThreaded())")
            self.button3.isEnabled = true
            self.button3.backgroundColor = .blue
            group.leave()
        })
        
        // 3. When all are finished Notify. This notify will be configured to be on background thread
        let queueType = DispatchQueue.global(qos: .userInitiated)
        group.notify(queue: queueType) {
            print("🔴 DispatchGroup - notify: All task Finished.")
            DispatchQueue.main.async {
                self.loadingLabel.text = "🟢 Done"
            }
        }
    }
    
    // MARK: - Example of Dispatch WorkItem
    func exampleRunDispatchWorkItem() {
        // 1. Create Dispatch Queue
        let queue = DispatchQueue(label: "com.kraken.dispatch.workitem")
        
        // 2. Create Work Item
        let workItem = DispatchWorkItem() {
            print("🟢 WorkItem is executed")
        }
       
        // 3.a. Run Task 1 with WorkItem
        queue.async(execute: workItem)
        
        // 3.b. Run Task 2 with WorkItem, with delay 1s
        queue.asyncAfter(deadline: DispatchTime.now() + 1, execute: workItem)
        
        // 4. Cacel WorkItem (All the tasks till now)
        workItem.cancel()
        
        // 5. Run Task 3 with WorkItem
        queue.async(execute: workItem)
        
        // 6. Check if workItem isCancelled
        if workItem.isCancelled {
            print("🟢 WorkItem was cancelled")
        }
    }
    
    // MARK: - UI Properties
    lazy var button1: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray //.systemTeal
        button.setTitle("Task 1", for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    lazy var button2: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray // .blue
        button.setTitle("Task 2", for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    lazy var button3: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .gray // .orange
        button.setTitle("Task 3", for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundColor = .yellow
        searchBar.layer.cornerRadius = 8
        searchBar.delegate = self
        
        return searchBar
    }()
    
    lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🔴 Loading... Group of Async Operations"
        label.textAlignment = .center
        return label
    }()
}

// MARK: - Simulate
extension ViewController {
    private func runLongRunningTask1(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            completion?()
        })
    }
    
    private func runLongRunningTask2(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            completion?()
        })
    }
    
    private func runLongRunningTask3(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            completion?()
        })
    }
}

// MARK: - UI
extension ViewController {
    func setupUI() {
        view.backgroundColor = .lightGray
        
        let buttons = [button1, button2, button3]
        for (index, button) in buttons.enumerated() {
        //buttons.forEach({ button in
            self.view.addSubview(button)
            button.widthAnchor.constraint(equalToConstant: 200).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            let topDist: CGFloat = 100.0 * CGFloat(index + 1)
            button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topDist).isActive = true
        }
        
        view.addSubview(searchBar)
        searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalToConstant: 200).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(loadingLabel)
        loadingLabel.widthAnchor.constraint(equalToConstant: 350).isActive = true
        loadingLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        
    }
}

// MARK: - SearchBar
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        workItem?.cancel()
        
        let newWorkItem = DispatchWorkItem {
            print("Run API call with Query: \(searchText)")
        }
        
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: newWorkItem)
    }
}
