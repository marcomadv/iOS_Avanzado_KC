//
//  SplashViewController.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 20/10/23.
//

import UIKit

//MARK: - View Protocol
protocol SplashViewControllerDelegate {
    var viewState: ((SplashViewState) -> Void)? { get set }
    var loginViewModel: LoginViewControllerDelegate { get }
    var heroesViewModel: HeroesViewControllerDelegate { get }
    
    func onViewAppear()
    func clearToken()
    func deleteAllData()
}
//MARK: - View State
enum SplashViewState {
    case loading (_ isLoading: Bool)
    case navigateToLogin
    case navigateToHeroes
}
//MARK: - Class
class SplashViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    // MARK: - IBAction
    @IBAction func myUnwindActionSplash(unwindSegue: UIStoryboardSegue) {
        viewModel?.clearToken()
        viewModel?.deleteAllData()
    }
    
    var viewModel: SplashViewControllerDelegate?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.onViewAppear()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SPLASH_TO_LOGIN":
            guard let loginViewController = segue.destination as? LoginViewController else { return }
            loginViewController.viewModel = viewModel?.loginViewModel
            
        case "SPLASH_TO_HEROES":
            guard let heroesViewController = segue.destination as? HeroesViewController else { return }
            heroesViewController.viewModel = viewModel?.heroesViewModel
            
        default:
            break
        }
    }
    
    //MARK: - Private functions
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading(let isLoading):
                    self?.loading.isHidden = !isLoading
                    
                case.navigateToLogin:
                    self?.performSegue(withIdentifier: "SPLASH_TO_LOGIN", sender: nil)
                    
                case.navigateToHeroes:
                    self?.performSegue(withIdentifier: "SPLASH_TO_HEROES", sender: nil)
                }
            }
        }
    }
}
