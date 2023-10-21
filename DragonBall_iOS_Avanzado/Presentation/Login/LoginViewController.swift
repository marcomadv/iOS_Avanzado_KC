//
//  LoginViewController.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 11/10/23.
//

import UIKit

//MARK: - View Protocol
protocol LoginViewControllerDelegate {
    var viewState: ((LoginViewState) -> Void)? {  get set }
    var heroesViewModel: HeroesViewControllerDelegate { get }
    func onLoginPressed(email: String?, password: String?)
}

//MARK: - View State
enum LoginViewState {
    case loading(_ isLoading: Bool)
    case showErrorEmail(_ error: String?)
    case showErrorPassword(_ error: String?)
    case navigateToNext
}
class LoginViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailFieldError: UILabel!
    @IBOutlet weak var passwordFieldError: UILabel!
    @IBOutlet weak var loadingview: UIView!
    
    // MARK: - IBAction
    @IBAction func onLoginPressed() {
        viewModel?.onLoginPressed(
            email: emailField.text,
            password: passwordField.text
        )
    }
    //MARK: - Public properties
    var viewModel: LoginViewControllerDelegate?
    
    private enum FieldType: Int {
        case email = 0
        case password
    }
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "LOGIN_TO_HERO ",
              let heroesViewController = segue.destination as? HeroesViewController else {
            return
        }
        
        heroesViewController.viewModel = viewModel?.heroesViewModel
        
        // sin crear la variable en loginviewmodel, le asignamos el viewmodel a heroescontroller directamente
        //heroesViewController.viewModel = HeroesViewModel(apiProvider: ApiProvider(), secureDataProvider: SecureDataProvider())
    }
    
    //MARK: - Private functions
    private func initViews() {
        emailField.delegate = self
        emailField.tag = FieldType.email.rawValue
        passwordField.delegate = self
        passwordField.tag = FieldType.password.rawValue
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(dismissKeyboard)
            )
        )
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading(let isLoading):
                    self?.loadingview.isHidden = !isLoading
                    
                case .showErrorEmail(let error):
                    self?.emailFieldError.text = error
                    self?.emailFieldError.isHidden = (error == nil || error?.isEmpty == true)
                    
                case .showErrorPassword(let error):
                    self?.passwordFieldError.text = error
                    self?.passwordFieldError.isHidden = (error == nil || error?.isEmpty == true)
                    
                case .navigateToNext:
                    self?.performSegue(withIdentifier: "LOGIN_TO_HERO ", sender: nil)
                }
            }
        }
    }
}

// MARK: - Extension
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch FieldType(rawValue: textField.tag) {
        case .email:
            emailFieldError.isHidden = true
            
        case .password:
            passwordFieldError.isHidden = true
        default:
            break
            
        }
    }
}
