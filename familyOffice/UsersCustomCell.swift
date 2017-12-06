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
//
//public class UsersController : UIViewController, UITableViewDelegate, UITableViewDataSource, TypedRowControllerType {
//
//
//    public var row: RowOf<UserEntity>!
//
//    public var onDismissCallback: ((UIViewController) -> ())?
//
//    private var families : Results<FamilyEntitie>!
//    private var notificationToken: NotificationToken? = nil
//    private var tableView: UITableView!
//
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    convenience public init(_ callback: ((UIViewController) -> ())?){
//        self.init(nibName: nil, bundle: nil)
//        onDismissCallback = callback
//    }
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        families = rManager.realm.objects(FamilyEntitie.self)
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "usercell")
//        let users = rManager.realm.objects(UserEntity.self)
//        tableView.dataSource = self
//        tableView.delegate = self
//        notificationToken = users.observe { [weak self] (changes: RealmCollectionChange) in
//            guard let tableView = self?.tableView else { return }
//            switch changes {
//            case .initial:
//                tableView.reloadData()
//            case .update(_, _, _, _):
//                self?.tableView.reloadData()
//                break
//            case .error(let error):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(error)")
//            }
//        }
//        tableView.isMultipleTouchEnabled = true
//    }
//
//    public func numberOfSections(in tableView: UITableView) -> Int {
//        return families != nil ? families.count : 0
//    }
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return families[section].members.count
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath)
//        let family = families[indexPath.section]
//        let familyMemberId = family.members[indexPath.row].value
//        cell.textLabel?.text = "Cargando..."
//        if let user = rManager.realm.object(ofType: UserEntity.self, forPrimaryKey: familyMemberId) {
//             cell.textLabel?.text = user.name
//             cell.imageView?.loadImage(urlString: user.photoURL)
//        }else{
//            store.dispatch(UserS(.getbyId(uid: familyMemberId)))
//        }
//        return cell
//    }
//
//    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return families[section].name
//    }
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//}

