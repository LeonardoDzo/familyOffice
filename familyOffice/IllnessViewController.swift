//
//  IllnessViewController.swift
//  familyOffice
//
//  Created by Nan Montaño on 06/dic/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class IllnessViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addLabel: UILabel!
    
    var panGesture: UIPanGestureRecognizer!
    let labels = ["Agregar medicina", "Agregar enfermedad"]
    var medicines: [MedicineEntity] = []
    var illnesses: [IllnessEntity] = []
    var familyId = getUser()!.familyActive
    var getIllnessUuid: String?
    var getMedicinesUuid: String?
    var rowActions: [UITableViewRowAction]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        (tableView as UIScrollView).delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        rowActions = [
            UITableViewRowAction(style: .normal, title: "Editar", handler: {_, i in self.edit(i)}),
            UITableViewRowAction(style: .destructive, title: "Eliminar", handler: {_, i in self.remove(i)})
        ]
        let rightButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.showEditing))
        self.navigationItem.rightBarButtonItem = rightButton
        
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width*2,
            height: scrollView.bounds.height
        )
        scrollView.showsHorizontalScrollIndicator = false
        let medImg = UIImageView(frame: scrollView.bounds)
        medImg.contentMode = .scaleAspectFill
        let illImg = UIImageView(frame: scrollView.bounds)
        illImg.contentMode = .scaleAspectFill
        medImg.image = UIImage(named: "medicine_background")
        illImg.image = UIImage(named: "illness_background")
        illImg.frame.origin.x = scrollView.bounds.width
        scrollView.addSubview(medImg)
        scrollView.addSubview(illImg)
        addLabel.text = labels[0]
        setPage(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: UIButton) {
        let ctrl = NewIllnessFormController()
        ctrl.entity = pageControl.currentPage == 0 ? MedicineEntity() : IllnessEntity()
        ctrl.action = .Create
        show(ctrl, sender: self)
    }
    
    @objc func showEditing(sender: UIBarButtonItem)
    {
        if(self.tableView.isEditing)
        {
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Editar"
        }
        else
        {
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Listo"
        }
    }
    
    func edit(_ indexPath: IndexPath) {
        let ctrl = NewIllnessFormController()
        ctrl.action = .Update
        ctrl.entity = pageControl.currentPage == 0 ? medicines[indexPath.row] : illnesses[indexPath.row]
        show(ctrl, sender: self)
        tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem?.title = "Edit"
    }
    
    func remove(_ indexPath: IndexPath) {
        if pageControl.currentPage == 0 {
            let entity = medicines.remove(at: indexPath.row)
            store.dispatch(removeMedicineAction(medicine: entity, uuid: UUID().uuidString))
        } else {
            let entity = illnesses.remove(at: indexPath.row)
            store.dispatch(removeIllnessAction(illness: entity, uuid: UUID().uuidString))
        }
    }
    
    // MARK: View
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        let t = self.scrollView.frame.height
        let v = sender.velocity(in: view).y
//        self.scrollView.frame = CGRect(
//            x: self.scrollView.frame.x,
//            y: self.scrollView.frame.y,
//            width: self.scrollView.frame.width,
//            height: height)
        print(t, v)
    }
    
    // MARK: ScrollView & PageControl
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView != self.scrollView) { return; }
        let page: Int = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        setPage(page)
    }
    
    func setPage(_ page: Int) {
        if (pageControl.currentPage == page) { return }
        addLabel.text = labels[page]
        pageControl.currentPage = page
        tableView.reloadSections(IndexSet(arrayLiteral: 0), with: UITableViewRowAnimation.fade)
    }
    
    func nah() {
        if (scrollView != self.tableView) { return }
        let height = min(280 - scrollView.contentOffset.y, 60)
        self.scrollView.bounds = CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: height)
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageControl.currentPage == 0 ? medicines.count : illnesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FirstAidTableViewCell
        if pageControl.currentPage == 0 {
            cell.title.text = medicines[indexPath.row].name
            cell.subtitle.text = medicines[indexPath.row].dosage
            cell.desc.text = medicines[indexPath.row].indications + "\n" +
                medicines[indexPath.row].restrictions + "\n" +
                medicines[indexPath.row].moreInfo
        } else {
            cell.title.text = illnesses[indexPath.row].name
            cell.subtitle.text = illnesses[indexPath.row].dosage
            cell.desc.text = illnesses[indexPath.row].medicine + "\n" +
                illnesses[indexPath.row].moreInfo
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return tableView.isEditing ? rowActions : [rowActions[1]]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            edit(indexPath)
        } else {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath), cell.isSelected {
            return 148
        }
        return 68
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension IllnessViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = RequestState
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in state.requestState }
        }
        getIllnessUuid = UUID().uuidString
        getMedicinesUuid = UUID().uuidString
        store.dispatch(getIllnessesAction(byFamily: self.familyId, uuid: getIllnessUuid!))
        store.dispatch(getMedicinesAction(byFamily: self.familyId, uuid: getMedicinesUuid!))
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: RequestState) {
        guard let iReqId = getIllnessUuid else {
            return
        }
        guard let mReqId = getMedicinesUuid else {
            return
        }
        switch state.requests[iReqId] {
        case .loading?:
            break
        case .Failed(_)?:
            break
        case .finished?:
            illnesses = rManager.realm.objects(IllnessEntity.self)
                .filter("family == '\(self.familyId)'")
                .map({$0})
            self.tableView.reloadData()
        default:
            break;
        }
        switch state.requests[mReqId] {
        case .finished?:
            medicines = rManager.realm.objects(MedicineEntity.self)
                .filter("family == '\(self.familyId)'")
                .map({$0})
            self.tableView.reloadData()
        default:
            break
        }
    }
    
}
