//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Egor on 03.03.2021.
//

import RxSwift
import RxCocoa
import MapKit

class WeatherViewController: UIViewController {
    
    private let viewModel: WeatherViewModel
    private let disposeBag = DisposeBag()
    
    private enum LayoutConstants {
        static let historyCollectionViewSpacing: CGFloat = 20
        static let historyCollectionCellHeight: CGFloat = 150
        static let historyCollectionCellWidth: CGFloat = 270
        
        static let currentWeatherViewHorizontalMargin: CGFloat = 25
    }
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        return view
    }()
    
    private let mapView: MKMapView = {
        let view = MKMapView()
        
        return view
    }()
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        
        return spinner
    }()
    
    private let currentWeatherView: WeatherInfoView = {
        let view = WeatherInfoView()
        view.backgroundColor = UIColor.AppColors.infoViewBackground
        
        return view
    }()
    
    private let historyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = LayoutConstants.historyCollectionViewSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: LayoutConstants.historyCollectionViewSpacing,
                                                   bottom: 0, right: LayoutConstants.historyCollectionViewSpacing)
        collectionView.setContentOffset(CGPoint(x: -LayoutConstants.historyCollectionViewSpacing, y: 0), animated: false)
        
        return collectionView
    }()
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        historyCollectionView.register(HistoryCollectionViewCell.self,
                                       forCellWithReuseIdentifier: HistoryCollectionViewCell.reuseCellId)
        
        setupNavigationBar()
        setupViews()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.onNext(())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupLayout()
    }
}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: LayoutConstants.historyCollectionCellWidth, height: LayoutConstants.historyCollectionCellHeight)
    }
}

private extension WeatherViewController {
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        view.addSubview(overlayView)
        view.addSubview(spinnerView)
        
        view.addSubview(currentWeatherView)
        view.addSubview(historyCollectionView)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сменить город", style: .plain, target: self, action: nil)
    }
    
    func setupLayout() {
        overlayView.pin
            .all()
        
        mapView.pin
            .all()
        
        spinnerView.pin
            .center()
        
        historyCollectionView.pin
            .horizontally()
            .height(LayoutConstants.historyCollectionCellHeight)
            .bottom(view.pin.safeArea)
        
        currentWeatherView.pin
            .above(of: historyCollectionView)
            .marginBottom(10)
        
        if UIDevice.current.orientation.isLandscape {
            currentWeatherView.pin
                .horizontally(view.pin.safeArea)
                .sizeToFit(.width)
        } else {
            currentWeatherView.pin
                .horizontally(LayoutConstants.currentWeatherViewHorizontalMargin)
                .sizeToFit(.width)
        }
    }
    
    func setupBindings() {
        
        // Right navigation item tap
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.input.didTapSelectCityButton)
            .disposed(by: disposeBag)
        
        // Coordinates of selected city
        viewModel.output.cityCoordinates
            .drive(onNext: { [unowned self] coordinates in
                
                guard let coordinates = coordinates else {
                    mapView.isHidden = true
                    return
                }
                
                mapView.isHidden = false
                
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let location = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                let region = MKCoordinateRegion(center: location, span: span)
                
                mapView.setRegion(region, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Name of selected city in title
        viewModel.output.cityName
            .drive(rx.title)
            .disposed(by: disposeBag)
        
        // Show loading spinner
        viewModel.output.isLoading
            .drive(spinnerView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        // Current weather view
        viewModel.output.currentWeather
            .drive(onNext: { [unowned self] weather in
                if let weather = weather {
                    currentWeatherView.setup(model: weather)
                    currentWeatherView.isHidden = false
                    
                    currentWeatherView.pin
                        .sizeToFit(.width)
                } else {
                    currentWeatherView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // Weather history collection view
        viewModel.output.weatherHistory
            .drive(historyCollectionView.rx.items) { collectionView, index, historyItem in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCollectionViewCell.reuseCellId,
                                                                    for: IndexPath(item: index, section: 0)) as? HistoryCollectionViewCell else { return UICollectionViewCell() }
                
                cell.setup(weatherHistory: historyItem)
                
                return cell
            }
            .disposed(by: disposeBag)
    }
}
