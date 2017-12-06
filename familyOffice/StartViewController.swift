//
//  StartViewController.swift
//  familyOffice
//
//  Created by miguel reina on 04/01/17.
//  Copyright © 2017 Miguel Reina y Leonardo Durazo. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase
import AVFoundation
import AVKit
import ReSwift

class StartViewController: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate {
    typealias StoreSubscriberStateType = UserState
    @IBOutlet var logo: UIImageView!
    @IBOutlet var titleLogo: UIImageView!
    @IBOutlet var googleSignUp: GIDSignInButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var footer: UIStackView!
    
    var playerController = AVPlayerViewController()
    var player:AVPlayer?
    
    
    func webviewDidFinishLoad(_ : UIWebView){
        service.UTILITY_SERVICE.stopLoading(view: self.view)
        
    }
    
    override func viewDidLoad() {
        style_1()
        isAuth()
        super.viewDidLoad()
        if(UIDevice.current.model == "Iphone 5s"){
            logo.frame.origin.y = logo.frame.origin.y-20
        }
        GIDSignIn.sharedInstance().uiDelegate = self
        //Loading video
        let videoString:String? = Bundle.main.path(forResource: "background", ofType: "mp4")
        if let url = videoString {
            let videoURL = NSURL(fileURLWithPath: url)
            
            player = AVPlayer(url: videoURL as URL)
            player?.actionAtItemEnd = .none
            player?.isMuted = true
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer.zPosition = -1
            
            playerLayer.frame = view.frame
            
            view.layer.addSublayer(playerLayer)
            
            player?.play()
            
            // add observer to watch for video end in order to loop video
            NotificationCenter.default.addObserver(self, selector: #selector(StartViewController.videoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
            
            //NotificationCenter.default.addObserver(self, selector: #selector(StartViewController.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player)
            
        }else {
            debugPrint("Error al cargar video")
        }
        
        animateView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        service.UTILITY_SERVICE.enabledView()
    }
    
    @objc func videoDidReachEnd() {
        //now use seek to make current playback time to the specified time in this case (O)
        let duration : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(duration, preferredTimeScale)
        player!.seek(to: seekTime)
        player!.play()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        store.dispatch(RoutingAction(d: .signUp))
    }
    
    //signin login
    @IBAction func handleSignIn(_ sender: UIButton) {
        guard let email = emailField.text, !email.isEmpty else{
            alert()
            return
        }
        guard let password = passwordField.text, !password.isEmpty else {
            alert()
            return
        }
        service.UTILITY_SERVICE.disabledView()
        store.dispatch(AuthSvc(.login(username: email, password: password)))
        
    }
    
    func alert() -> Void {
        let alert = UIAlertController(title: "Verifica tus datos", message: "Inserte un correo electrónico y/o una contraseña", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        service.ANIMATIONS.shakeTextField(txt: emailField)
        service.ANIMATIONS.shakeTextField(txt: passwordField)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension StartViewController : StoreSubscriber {
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        store.subscribe(self) {
            subcription in
            subcription.select { state in state.UserState }
        }
    }
    
    func newState(state: UserState) {
        self.view.hideToastActivity()
        service.UTILITY_SERVICE.enabledView()

        switch state.user {
        case .failed:
            alert()
            break
        case .finished, .Finished(_):
            self.gotoView(view: .prehome, sender: getUser())
            break
        case .loading:
            self.view.makeToastActivity(.center)
            break
        default:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        store.unsubscribe(self)
    }
   
}

extension StartViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //change color status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func emailField(_ sender: Any) {
        textFieldDidBeginEditing(self.emailField)
    }
    
    @IBAction func emailFieldEnd(_ sender: Any) {
        textFieldDidEndEditing(self.emailField)
    }
    
    @IBAction func passwordFieldBeginEditing(_ sender: Any) {
        textFieldDidBeginEditing(self.passwordField)
    }
    
    @IBAction func passwordFieldEndEditing(_ sender: Any) {
        textFieldDidEndEditing(self.passwordField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -150, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: textField, moveDistance: -150, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool){
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func animateView(){
        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
        logo.transform = CGAffineTransform(translationX: 0, y: -200)
        logo.transform = CGAffineTransform(rotationAngle: 90).concatenating(scale)
        self.titleLogo.alpha = 0
        
        UIView.animate(withDuration: 2, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.logo.alpha = 1
            let scale = CGAffineTransform(scaleX: 1, y: 1)
            self.logo.transform = CGAffineTransform(rotationAngle: 0).concatenating(scale)
        },completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 1.2, options: .curveEaseInOut, animations: {
            self.titleLogo.transform = CGAffineTransform(translationX: 0, y: -20.0 )
            self.titleLogo.alpha = 1
        }, completion: nil)
        
        self.emailField.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.6, options: .curveEaseInOut, animations: {
            self.emailField.transform = CGAffineTransform(translationX: 0, y: -20.0 )
            self.emailField.alpha = 1
        }, completion: nil)
        
        self.emailField.layer.borderColor = UIColor( red: 1/255, green: 255.0/255, blue:255.0/255, alpha: 1.0 ).cgColor
        
        self.passwordField.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.6, options: .curveEaseInOut, animations: {
            self.passwordField.transform = CGAffineTransform(translationX: 0, y: -20.0 )
            self.passwordField.alpha = 1
        }, completion: nil)
        
        self.loginButton.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.8, options: .curveEaseInOut, animations: {
            self.loginButton.transform = CGAffineTransform(translationX: 0, y: -20.0 )
            self.loginButton.alpha = 1
        }, completion: nil)
        
        self.googleSignUp.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.8, options: .curveEaseInOut, animations: {
            self.googleSignUp.transform = CGAffineTransform(translationX: 0, y: -20.0 )
            self.googleSignUp.alpha = 1
        }, completion: nil)
        
        self.footer.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 2.4, options: .curveEaseInOut, animations: {
            self.footer.alpha = 1
        }, completion: nil)
        
    }
}
