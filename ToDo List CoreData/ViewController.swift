//
//  ViewController.swift
//  ToDo List CoreData
//
//  Created by Nikita Shirobokov on 17.12.22.
//

import UIKit

private extension String {
    static let cellId = "cell"
}

class ViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        // Table view cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func addNewTask() {
        didTapAdd(title: "New task", message: "What do you want to do?")
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Tasks list"
        getAllItems()
    }
    
    private func didTapAdd(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(
            title: "Save",
            style: .default
        ) { [weak self] _ in
            guard let task = alert.textFields?.first,
                  let text = task.text,
                  !text.isEmpty
            else {
                print("Text field is empty")
                return
            }
            self?.createItem(name: text)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
}

extension ViewController {
    
    private func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch  {
            print("Can`t get")
        }
    }
    
    private func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch  {
            print("Can`t save")
        }
    }
    
    private func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch  {
            print("Can`t save")
        }
    }
    
}

extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellId, for: indexPath)
        
        let model = models[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = model.name
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteItem(item: item)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { _ in
            
            let alert = UIAlertController(
                title: "Edit Item",
                message: "Edit your item",
                preferredStyle: .alert
            )
            
            alert.addTextField()
            alert.textFields?.first?.text = item.name
            
            let saveAction = UIAlertAction(title: "Save", style: .cancel) { [weak self] _ in
                guard let task = alert.textFields?.first, let newName = task.text, !newName.isEmpty else {
                    print("Text field is empty")
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
            
        }
        
        sheet.addAction(cancelAction)
        sheet.addAction(editAction)
        sheet.addAction(deleteAction)
        
        present(sheet, animated: true)
    }
}
