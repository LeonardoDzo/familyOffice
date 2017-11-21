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

class ToDoListController: UIViewController,UIViewControllerPreviewingDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tabBar: UITabBar!
    
    var items : [ToDoList.ToDoItem] = []
    var userId = store.state.UserState.getUser()?.id
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        tabBar.selectedItem = tabBar.items![0]
        tabBar.tintColor = #colorLiteral(red: 0.8431372549, green: 0.1019607843, blue: 0.4, alpha: 1)
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        style_1()
        
        self.navigationItem.title = "Lista de tareas"
        
        tableView.tableHeaderView = searchController.searchBar
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNew))
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "LeftChevron"), style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_bar_more_button"), style: .plain, target: self, action:  #selector(self.handleMore(_:)))
        
        self.navigationItem.rightBarButtonItems = [moreButton,addButton]
        // Do any additional setup after loading the view.
    
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    let settingLauncher = SettingLauncher()
    
    @objc func handleMore(_ sender: Any) {
        settingLauncher.showSetting()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let user = userStore?.id!
        if item.tag == 1 {
            self.items = self.items.filter({ (item) -> Bool in
                return item.status == "Finalizada"
            })
        }else{
            self.items = store.state.ToDoListState.items[user!] ?? []
        }
        tableView.reloadData()
    }
    
    @objc func back() -> Void {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleNew() -> Void {
        self.performSegue(withIdentifier: "showItemDetails", sender: "new")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.items[indexPath.row]
        let cellID = "ToDoItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ToDoItemCell
        
        cell.title.text = item.title
        cell.date.text = item.endDate == "" ? "Fecha indefinida" : item.endDate
        
        cell.countLabel.text = "\(indexPath.row + 1)"
        cell.countLabel.layer.cornerRadius = 0.5 * cell.countLabel.bounds.size.width
        
        
        cell.checkFinished.isOn = item.status == "Pendiente" ? false : true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showItemDetails", sender: "List")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            let alert = UIAlertController(title: "Eliminar tarea", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Aceptar", style: .destructive, handler: { (action) in
                self.tabBar.selectedItem = self.tabBar.items![0]
                store.dispatch(DeleteToDoListItemAction(item: self.items[indexPath.row]))
            }))
            self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func checkboxPressed(_ sender: UISwitch) {
        let checkbox = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: checkbox)
        var currentItem = self.items[(indexPath?.row)!]
        print(currentItem)
        if sender.isOn {
            currentItem.status = "Finalizada"
        } else {
            currentItem.status = "Pendiente"
        }
        tabBar.selectedItem = tabBar.items![0]
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
        service.TODO_SERVICE.initObserves(ref: "todolist/\((userStore?.id)!)", actions: [.childAdded, .childChanged, .childRemoved])
        
        store.subscribe(self){
            subcription in
            subcription.select { state in state.ToDoListState }
        }
    }

    
    func newState(state: ToDoListState) {
        items = state.items[userId!] ?? []
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
        let user = userStore?.id!
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            self.items = self.items.filter({$0.title.lowercased().contains(searchText.lowercased())})
        }else{
            if self.tabBar.selectedItem?.tag == 0 {
                self.items = store.state.ToDoListState.items[user!] ?? []
            }
            else{
                self.items = store.state.ToDoListState.items[user!] ?? []
                self.items = self.items.filter({ (item) -> Bool in
                    return item.status == "Finalizada"
                })
            }
        }
        tableView.reloadData()
    }
}


