//
//  ViewController.swift
//  SignInWithAppleDemo
//
//  Created by Pushpank Kumar on 23/02/20.
//  Copyright © 2020 Pushpank Kumar. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSignInWithAppleButton()
    }
}

extension ViewController {
    
    /// create sign in with apple button
    private func setupSignInWithAppleButton() {
        let authrizationButton = ASAuthorizationAppleIDButton()
        view.addSubview(authrizationButton)
        
        authrizationButton.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 25, paddingRight: 25, height: 50)
        authrizationButton.addTarget(self, action: #selector(appleSignInButtonPressed), for: .touchUpInside)
    }
    
    /// Save item in keychain
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.signInwithApple", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
}

extension ViewController {
    
    // Request Authorization with Apple Id
    @objc func appleSignInButtonPressed() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authgrizationController = ASAuthorizationController(authorizationRequests: [request])
        authgrizationController.delegate = self
        authgrizationController.presentationContextProvider = self
        authgrizationController.performRequests()
    }
}


// MARK: ASAuthorizationControllerDelegate
extension ViewController: ASAuthorizationControllerDelegate {
    
   // If authrozation is failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error : ", error.localizedDescription)
        
    }
    
    // If authrization is successful
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create account according to your requirement
            let appleId = appleIDCredentials.user
            let firstName = appleIDCredentials.fullName?.givenName
            let lastname  = appleIDCredentials.fullName?.familyName
            let emailAddress = appleIDCredentials.email
            
            // Store this data in your keychain
            saveUserInKeychain(appleId)
            
            print("appleId \(appleId) firstName \(String(describing: firstName)) lastname \(String(describing: lastname)) emailAddress \(String(describing: emailAddress))")
            
        }
        else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            
            // Sign in using an existing iCloud Keychain credential.
            
            let appleUsername = passwordCredential.user
            let password = passwordCredential.password
            print("appleUsername \(appleUsername) password \(password)")
        }
    }
}


// Set up Presentation anchor
extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
