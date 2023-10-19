//
//  TaskListViewController.swift
//  Lesson 3.6 CoreData
//
//  Created by Артём Потёмкин on 12.10.2023.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let viewContext = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "Task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(whithTitle: "Add New Task", andMessage: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try viewContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription )
        }

    }
    
    private func showAlert(whithTitle title: String, andMessage message: String, andText text: String? = nil, indexPath: IndexPath? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            save(task)
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty, task != text else { return }
            edit(task, indexPath: indexPath! )
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        guard text != nil else {
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
            present(alert, animated: true)
            return
        }
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = text
        }
        present(alert, animated: true)
    
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.create(taskName) { task in
            taskList.append(task)
        }
       
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
       
    }
    private func edit(_ taskName: String, indexPath: IndexPath) {
        
        let task = Task(context: viewContext)
        task.title = taskName
        taskList[indexPath.row].title = taskName
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
       
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableView Data source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableView delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(
            whithTitle: "Edit task",
            andMessage: "What do you want to change",
            andText: task.title,
        indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(task)
        }
    }
}
