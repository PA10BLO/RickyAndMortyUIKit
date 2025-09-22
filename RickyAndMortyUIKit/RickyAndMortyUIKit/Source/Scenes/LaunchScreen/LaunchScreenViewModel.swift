//
//  LaunchScreenViewModel.swift
//  RickyAndMortyUIKit
//
//  Created by Pablo on 22/9/25.
//

import UIKit

protocol BaseViewControllerProtocol {
    func setupScene()
}

class LaunchScreenViewModel: UIViewController, BaseViewControllerProtocol {
    func setupScene() { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
    }
    
    private func setupMainView() {
        self.navigationController?.pushViewController(MainViewController(), animated: false)
    }
    
}
