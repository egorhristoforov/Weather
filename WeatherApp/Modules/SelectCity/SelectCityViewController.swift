//
//  SelectCityViewController.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift

class SelectCityViewController: UITableViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: SelectCityViewModel
    
    private let citiesCellId = "CitiesCell"
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        
        return spinner
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        
        return controller
    }()
    
    init(viewModel: SelectCityViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: citiesCellId)
        
        setupViews()
        setupNavigationBar()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            viewModel.input.didClose.onNext(())
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
    }
}

private extension SelectCityViewController {
    func setupViews() {
        view.addSubview(spinnerView)
    }
    
    func setupNavigationBar() {
        title = viewModel.output.title
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupLayout() {
        spinnerView.pin
            .center()
    }
    
    func setupBindings() {
        
        // Cities list
        viewModel.output.cities
            .drive(tableView.rx.items) { [unowned self] tableView, index, city -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: citiesCellId) else { return UITableViewCell() }
                cell.textLabel?.text = city.name
                
                return cell
            }
            .disposed(by: disposeBag)
        
        // Show loading spinner
        viewModel.output.isCitiesLoading
            .drive(spinnerView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Did select row
        tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.input.didSelectedRow)
            .disposed(by: disposeBag)
        
        // Did change text in searchBar
        searchController.searchBar.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.input.searchText)
            .disposed(by: disposeBag)
    }
}
