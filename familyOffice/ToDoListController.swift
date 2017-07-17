//
//  ToDoListController.swift
//  familyOffice
//
//  Created by Ernesto Salazar on 6/29/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//


import UIKit
import ReSwift
import Firebase
import M13Checkbox

class ToDoListController: UITableViewController,UIViewControllerPreviewingDelegate {
    
    
    var items : [ToDoList.ToDoItem] = []
    var userId = service.USER_SERVICE.users[0].id!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        addButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItem = addButton
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Home"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        
        // Do any additional setup after loading the view.
    
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleNew() -> Void {
        self.performSegue(withIdentifier: "showItemDetails", sender: "new")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        let cellID = "ToDoItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ToDoItemCell
        
        cell.title.text = item.title
        cell.date.text = item.endDate
        
        cell.countLabel.text = "\(indexPath.row + 1)"
        cell.countLabel.layer.cornerRadius = 0.5 * cell.countLabel.bounds.size.width
        
        cell.checkFinished.boxType = .square
        cell.checkFinished.markType = .checkmark
        
        if item.status == "Pendiente" {
            cell.checkFinished.checkState = .unchecked
        } else {
            cell.checkFinished.checkState = .checked
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showItemDetails", sender: "List")
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            store.dispatch(DeleteToDoListItemAction(item: self.items[indexPath.row]))
        }
        
        return [deleteAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier!)
        let str = "\(sender!)"
        if segue.identifier == "showItemDetails"{
            if str == "List"{
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    let selectedItem = self.items[indexPath.row]
                    let detailsViewController = segue.destination as! EditItemViewController
                    detailsViewController.item = selectedItem
                }
            }
        }
        searchController.isActive = false
    }
    // MARK: - Checkbox
    @IBAction func checkboxPressed(_ sender: M13Checkbox) {
        
        let checkbox = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: checkbox)
        var currentItem = self.items[(indexPath?.row)!]
        print(currentItem)
        if sender.checkState == .checked{
            currentItem.status = "Finalizada"
        } else {
            currentItem.status = "Pendiente"
        }
        store.dispatch(UpdateToDoListItemAction(item:currentItem))
    }
    
    
    
    // MARK: - PreviewingDeleate.
    // 3D touch en cada elemento de la tabla
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView?.indexPathForRow(at: location) else {return nil}
        
        guard let cell = tableView?.cellForRow(at: indexPath) else {return nil}
        
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "EditItemViewController") as? EditItemViewController else {return nil}
        
        let item = self.items[indexPath.row]
        detailVC.item = item
        
        detailVC.preferredContentSize = CGSize(width: 0.0, height: 600)
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
}

extension ToDoListController: StoreSubscriber{
    typealias StoreSubscriberStateType = ToDoListState
    
    override func viewWillAppear(_ animated: Bool) {
        service.TODO_SERVICE.initObserves(ref: "todolist/\(userId)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            state in state.ToDoListState
        }
    }
    
    
    
    func newState(state: ToDoListState) {
        items = state.items[userId] ?? []
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.searchController.isActive = false
        store.state.ToDoListState.status = .none
        store.unsubscribe(self)
        service.TODO_SERVICE.removeHandles()
        
    }
}

extension ToDoListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let user = store.state.UserState.user?.id!
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            self.items = self.items.filter({$0.title.lowercased().contains(searchText.lowercased())})
        }else{
            self.items = store.state.ToDoListState.items[user!] ?? []
        }
        tableView.reloadData()
    }
}

