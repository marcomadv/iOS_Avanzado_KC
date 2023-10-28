//
//  HeroesViewController.swift
//  DragonBall_iOS_Avanzado
//
//  Created by Marco Muñoz on 17/10/23.
//

import UIKit

//MARK: - View Protocol
protocol HeroesViewControllerDelegate {
    var viewState: ((HeroesViewState) -> Void)? { get set }
    var heroesCount: Int { get }
    func onViewAppear()
    func heroBy(index: Int) -> HeroDAO?
    func heroDetailViewModel(index: Int) -> HeroDetailViewControllerDelegate?
    func heroMapViewModel() -> HeroMapControllerDelegate?
    func addObserverErrors()
    func removeObserverErrors()
}
//MARK: - View State
enum HeroesViewState {
    case loading(_ isLoading: Bool)
    case updateData
    case apiError(_ error: String)
}
//MARK: - Class
class HeroesViewController: UIViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingview: UIView!
    @IBAction func toMap(_ sender: Any) {
       performSegue(withIdentifier: "HEROES_TO_HEROMAP", sender: nil)
    }
    @IBAction func myUnwindActionHeroes(unwindSegue: UIStoryboardSegue) {}
    //MARK: - Public Properties
    var viewModel: HeroesViewControllerDelegate?
    var secureDataProvider = SecureDataProvider()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.addObserverErrors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.onViewAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.removeObserverErrors()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "HEROES_TO_HERO_DETAIL" :
            guard let index = sender as? Int ,
                  let heroDetailViewController = segue.destination as? HeroDetailViewController,
                  let detailViewModel = viewModel?.heroDetailViewModel(index: index) else { return }
            heroDetailViewController.viewModel = detailViewModel
            
        case "HEROES_TO_HEROMAP" :
            guard let heroMapController = segue.destination as? HeroMapController,
                  let heroMapViewModel = viewModel?.heroMapViewModel() else { return }
                heroMapController.viewModel = heroMapViewModel
        default:
            break
        }
    }
    //MARK: - Private functions
    private func initViews() {
        
        tableView.register(UINib(nibName: HeroCellView.identifier, bundle: nil),
                           forCellReuseIdentifier: HeroCellView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setObservers() {
        viewModel?.viewState = { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading(let isLoading):
                    self?.loadingview.isHidden = !isLoading
                    
                case .updateData:
                    self?.tableView.reloadData()
                    
                case .apiError(let error):
                    DispatchQueue.main.async {
                        self?.loadingview.isHidden = true
                        let alert = UIAlertController(title: "Atención",
                                                      message: error,
                                                      preferredStyle: .alert)
                        let alertAction = UIAlertAction.init(title: "Ok", style: .default) { _ in
                            self?.viewModel?.onViewAppear()
                        }
                        alert.addAction(alertAction)
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
}

//MARK: - Extension
extension HeroesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.heroesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        HeroCellView.estimatedHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeroCellView.identifier, for: indexPath) as? HeroCellView else {
            return UITableViewCell()
        }
        if let hero = viewModel?.heroBy(index: indexPath.row) {
            cell.updateView(
                name: hero.name,
                photo: hero.photo,
                description: hero.heroDescription
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "HEROES_TO_HERO_DETAIL", sender: indexPath.row)
    }
}
