//
//  HistoryCollectionViewCell.swift
//  WeatherApp
//
//  Created by Egor on 04.03.2021.
//

import UIKit

class HistoryCollectionViewCell: UICollectionViewCell {
    static let reuseCellId = "HistoryCollectionViewCellReuseId"
    
    private let weatherInfoView: WeatherInfoView = {
        let view = WeatherInfoView()
        view.backgroundColor = UIColor.AppColors.infoViewBackground
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    func setup(weatherHistory: WeatherHistory) {
        weatherInfoView.setup(model: weatherHistory)
    }
}

private extension HistoryCollectionViewCell {
    func setupViews() {
        contentView.addSubview(weatherInfoView)
    }
    
    func setupLayout() {
        weatherInfoView.pin
            .horizontally()
            .sizeToFit(.width)
            .vCenter()
    }
}
