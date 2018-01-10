//
//  UsersCustomCell.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 28/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Eureka
import UIKit
import RealmSwift
import ReSwift

public struct UserListSelected : Equatable {
    
    public var list = [String]()
    
    public static func ==(lhs: UserListSelected, rhs: UserListSelected) -> Bool {
        if lhs.list.count != rhs.list.count  {
            return false
        }
        // get count of the matched items
        let result = zip(lhs.list, rhs.list).enumerated().filter() {
            $1.0 == $1.1
            }.count
        
        if result == lhs.list.count {
            return true
        }
        
        return false
        
    }
    public var description: String {
        return "\(list.count)"
    }
    
}

public final class UsersRow: OptionsRow<PushSelectorCell<UserListSelected>>, PresenterRowType, RowType {
    
    public typealias PresenterRow = UsersController
    
    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    open var familyId: String?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return UsersController(){ _ in } }, onDismiss: { vc in _ = vc.navigationController?.popViewController(animated: true) })
        
        displayValueFor = {
            guard let users = $0 else { return "0" }
            return  users.description
        }
    }
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}
public class UsersController : UIViewController, UITableViewDelegate, UITableViewDataSource, TypedRowControllerType {


    public var row: RowOf<UserListSelected>!

    public var onDismissCallback: ((UIViewController) -> ())?

    private var families : Results<FamilyEntity>!
    private var notificationToken: NotificationToken? = nil
    var userList = UserListSelected()
    
    private var tableView: UITableView!

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        userList = row.value ?? UserListSelected()
        let myId = getUser()!.id
        if !userList.list.contains(myId) {
            userList.list.append(getUser()!.id)
        }
        families = rManager.realm.objects(FamilyEntity.self)
        if let row = row as? UsersRow, let fam = row.familyId {
            families = families.filter("id == '\(fam)'")
        }
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "usercell")
        let users = rManager.realm.objects(UserEntity.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(MapViewController.tappedDone(_:)))
        button.title = "Done"
        navigationItem.rightBarButtonItem = button
        
        notificationToken = users.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, _, _, _):
                self?.tableView.reloadData()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        tableView.isMultipleTouchEnabled = true
        self.view.addSubview(tableView)
    }
    
    @objc func tappedDone(_ sender: UIBarButtonItem){
        if userList != row.value {
            row.value = userList
            onDismissCallback?(self)
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return families != nil ? families.count : 0
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return families[section].members.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userid = families[indexPath.section].members[indexPath.row].value
        if let index = userList.list.index(where: {$0 == userid}) {
            userList.list.remove(at: index)
        }else{
            userList.list.append(userid)
        }
        self.tableView.reloadData()
        
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let family = families[indexPath.section]
        let familyMemberId = family.members[indexPath.row].value
        if familyMemberId == getUser()!.id { return nil }
        return indexPath
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath)
        let family = families[indexPath.section]
        let familyMemberId = family.members[indexPath.row].value
        cell.textLabel?.text = "Cargando..."
        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: familyMemberId) {
             cell.textLabel?.text = user.name
             cell.imageView?.loadImage(urlString: user.photoURL)
             cell.imageView?.circleImage()
        }else{
            store.dispatch(UserS(.getbyId(uid: familyMemberId)))
        }
        
        if userList.list.contains(familyMemberId){
            cell.accessoryType = .checkmark
        }else{
             cell.accessoryType = .none
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return families[section].name
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}

