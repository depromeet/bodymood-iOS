//
//  LoginViewController.swift
//  depromeet-10-5
//
//  Created by 허예은 on 2021/09/28.
//

import UIKit
class LoginViewController: UIViewController {

    lazy var authViewModel: AuthViewModel = {
        let viewModel = AuthViewModel()
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func kakaoLoginDidTap(_ sender: Any) {
        authViewModel.fetchKakaoLogin()
    }
}
