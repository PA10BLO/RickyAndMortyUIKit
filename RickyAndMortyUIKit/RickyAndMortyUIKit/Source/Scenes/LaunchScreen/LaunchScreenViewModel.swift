//
//  LaunchScreenViewModel.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

import UIKit

class LaunchScreenViewModel: UIViewController {
    internal func setupScene() { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }
    
    private func setupMainView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MainViewController.self))
        
        guard let mainViewController = storyboard.instantiateInitialViewController() as? MainViewController else {
            assertionFailure("Unable to instantiate MainViewController from Main.storyboard")
            return
        }
        
        mainViewController.setupScene()
        
        if let navigationController {
            navigationController.setViewControllers([mainViewController], animated: false)
        } else {
            present(mainViewController, animated: false)
        }
    }
    
}
