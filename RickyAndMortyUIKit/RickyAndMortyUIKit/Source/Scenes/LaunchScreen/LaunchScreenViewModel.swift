//
//  LaunchScreenViewModel.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

import UIKit

class LaunchScreenViewModel: UIViewController {
    
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
        navigationController?.setViewControllers([mainViewController], animated: false)
    }
    
}
