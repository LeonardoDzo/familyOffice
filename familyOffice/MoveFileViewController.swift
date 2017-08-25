//
//  MoveFileViewController.swift
//  familyOffice
//
//  Created by Developer on 8/25/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class MoveFileViewController: UIViewController {
    let userId = store.state.UserState.user?.id!

    @IBOutlet weak var tableView: UITableView!
    
    var folders:[SafeBoxFile] = []
    var currentFolder = "root"
    var tree = ["", "root"]
    var file:SafeBoxFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: #colorLiteral(red: 0.3137395978, green: 0.1694342792, blue: 0.5204931498, alpha: 1)]
        self.navigationItem.title = "Mover a..."
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        let moveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.moveFile))
        moveButton.tintColor = #colorLiteral(red: 1, green: 0.2793949573, blue: 0.1788432287, alpha: 1)
        self.navigationItem.rightBarButtonItems = [moveButton]
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.tableView.addGestureRecognizer(swipeRight)

        
        folders = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({NSString(string: $0.filename).pathExtension == "" && $0.parent == "root"}) ?? []
        
        // Do any additional setup after loading the view.
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        print ("Swiped right")
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.right:
                if(self.currentFolder != "root"){
                    self.tree.popLast()
                    self.currentFolder = self.tree[self.tree.count - 1]
                    self.folders = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({NSString(string: $0.filename).pathExtension == "" && $0.parent == self.currentFolder}) ?? []
                    self.tableView.reloadData()
                }
                break
            default:
                break
            }
        }
    }

    
    func moveFile() {
        print(self.tree)
        print(self.currentFolder)
        
        let alert = UIAlertController(title: "Mover archivo", message: "Seguro desea mover el archivo \(file.filename!) a la carpeta \(self.currentFolder) ", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { (UIAlertAction) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { (UIAlertAction) in
            self.file.parent = self.currentFolder
            store.dispatch(UpdateSafeBoxFileAction(item: self.file))
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: { 
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MoveFileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentFolder = self.folders[indexPath.row].filename!
        self.folders = store.state.safeBoxState.safeBoxFiles[userId!]?.filter({NSString(string: $0.filename).pathExtension == "" && $0.parent == self.currentFolder}) ?? []
        self.tree.append(self.currentFolder)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "folderID") as! FolderTableViewCell
        cell.folderNameLbl.text = self.folders[indexPath.row].filename
        
        return cell
    }
    
}
