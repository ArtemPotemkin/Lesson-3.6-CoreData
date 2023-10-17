//
//  TaskViewController.swift
//  Lesson 3.6 CoreData
//
//  Created by Артём Потёмкин on 13.10.2023.
//

import UIKit
import CoreData

final class TaskViewController: UIViewController {
    
    var delegate: TaskListViewControllerDelegate!
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Task"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        createButton(
            withTitle: "Save Task",
            andColor: .milkBlue,
            action: UIAction { [unowned self] _ in
                save()
            }
        )
    }()
    
    private lazy var cancelButton: UIButton = {
        createButton(
            withTitle: "Cancel",
            andColor: .milkRed,
            action: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews(taskTextField, saveButton, cancelButton)
        setConstraints()
    }
    
    private func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func createButton(withTitle title: String, andColor color: UIColor, action: UIAction) -> UIButton {
        var attributes = AttributeContainer()
        attributes.font = UIFont.boldSystemFont(ofSize: 18)
        
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = color
        buttonConfiguration.attributedTitle = AttributedString(title, attributes: attributes)
        
        let button = UIButton(configuration: buttonConfiguration, primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }

    private func save() {
        let task = Task(context: viewContext)
        task.title = taskTextField.text
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        delegate.reloadData()
        dismiss(animated: true)
    }
}
