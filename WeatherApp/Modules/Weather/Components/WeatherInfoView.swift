//
//  WeatherInfoView.swift
//  WeatherApp
//
//  Created by Egor on 04.03.2021.
//

import UIKit

class WeatherInfoView: UIView {
    
    private enum LayoutConstants {
        static let cornerRadius: CGFloat = 12
        
        static let tempLabelTopMargin: CGFloat = 10
        static let tempLabelRightMargin: CGFloat = 10
        
        static let feelsLikeLabelTopMargin: CGFloat = 10
        static let feelsLikeLabelRightMargin: CGFloat = 10
        
        static let pressureLabelTopMargin: CGFloat = 10
        static let pressureLabelRightMargin: CGFloat = 10
        
        static let humidityLabelTopMargin: CGFloat = 10
        static let humidityLabelRightMargin: CGFloat = 10
        
        static let titleLabelTopMargin: CGFloat = 10
        static let titleLabelHorizontalMargin: CGFloat = 10
        
        static let descriptionLabelTopMargin: CGFloat = 20
        static let descriptionLabelHorizontalMargin: CGFloat = 10
        
        static let bottomPadding: CGFloat = 10
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        label.textColor = UIColor.AppColors.textPrimaryColor
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = UIColor.AppColors.textSecondaryColor
        
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.AppColors.textPrimaryColor
        
        return label
    }()
    
    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.AppColors.textSecondaryColor
        
        return label
    }()
    
    private let pressureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.AppColors.textSecondaryColor
        
        return label
    }()

    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.AppColors.textSecondaryColor
        
        return label
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM\nHH:mm"
        
        return formatter
    }()
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = LayoutConstants.cornerRadius
        clipsToBounds = true
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        setupLayout()
        
        let maxY = max(descriptionLabel.frame.maxY, humidityLabel.frame.maxY) + LayoutConstants.bottomPadding
        
        return CGSize(width: size.width, height: maxY)
    }
    
    func setup(model: CurrentWeather) {
        titleLabel.text = "Сейчас"
        descriptionLabel.text = model.weatherDescription.first?.description
        
        if let info = model.weatherInfo {
            tempLabel.text = "\(info.temp) °C"
            feelsLikeLabel.text = "Ощущается: \(info.feelsLike) °C"
            humidityLabel.text = "Влажность: \(info.humidity) %"
            pressureLabel.text = "Давление: \(info.pressure) Па"
        } else {
            tempLabel.text = "-- °C"
            feelsLikeLabel.text = "Ощущается: -- °C"
            humidityLabel.text = "Влажность: -- %"
            pressureLabel.text = "Давление: -- Па"
        }
    }
    
    func setup(model: WeatherHistory) {
        titleLabel.text = dateFormatter.string(from: model.date)
        descriptionLabel.text = model.weatherDescription.first?.description
        
        tempLabel.text = "\(model.weatherInfo.temp) °C"
        feelsLikeLabel.text = "Ощущается: \(model.weatherInfo.feelsLike) °C"
        humidityLabel.text = "Влажность: \(model.weatherInfo.humidity) %"
        pressureLabel.text = "Давление: \(model.weatherInfo.pressure) Па"
    }
}

private extension WeatherInfoView {
    func setupViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(tempLabel)
        addSubview(feelsLikeLabel)
        addSubview(pressureLabel)
        addSubview(humidityLabel)
    }
    
    func setupLayout() {
        tempLabel.pin
            .sizeToFit()
            .top(LayoutConstants.tempLabelTopMargin)
            .right(LayoutConstants.tempLabelRightMargin)
        
        feelsLikeLabel.pin
            .sizeToFit()
            .below(of: tempLabel)
            .marginTop(LayoutConstants.feelsLikeLabelTopMargin)
            .right(LayoutConstants.feelsLikeLabelRightMargin)
        
        pressureLabel.pin
            .sizeToFit()
            .below(of: feelsLikeLabel)
            .marginTop(LayoutConstants.pressureLabelTopMargin)
            .right(LayoutConstants.pressureLabelRightMargin)
        
        humidityLabel.pin
            .sizeToFit()
            .below(of: pressureLabel)
            .marginTop(LayoutConstants.humidityLabelTopMargin)
            .right(LayoutConstants.humidityLabelRightMargin)
        
        titleLabel.pin
            .top(LayoutConstants.titleLabelTopMargin)
            .left(LayoutConstants.titleLabelHorizontalMargin)
            .before(of: [tempLabel, feelsLikeLabel, pressureLabel, humidityLabel])
            .marginRight(LayoutConstants.titleLabelHorizontalMargin)
            .sizeToFit(.width)
        
        descriptionLabel.pin
            .below(of: titleLabel)
            .marginTop(LayoutConstants.descriptionLabelTopMargin)
            .left(LayoutConstants.descriptionLabelHorizontalMargin)
            .before(of: [tempLabel, feelsLikeLabel, pressureLabel, humidityLabel])
            .marginRight(LayoutConstants.descriptionLabelHorizontalMargin)
            .sizeToFit(.width)
    }
}
