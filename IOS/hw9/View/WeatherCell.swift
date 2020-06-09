//
//  WeatherCell.swift
//  hw9
//
//  Created by Tianhao Zhang on 4/26/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    var cityLable = UILabel()
    var stateLable = UILabel()
    var temperatureLable = UILabel()
    var summaryLable = UILabel()
    let summaryImage = ["Clouds":"cloudy_weather",
                        "Clear":"clear_weather",
                        "Snow":"snowy_weather",
                        "Rain":"rainy_weather",
                        "Thunderstorm":"thunder_weather",
                        "default":"sunny_weather"]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
        
        addSubview(cityLable)
        addSubview(stateLable)
        addSubview(temperatureLable)
        addSubview(summaryLable)
        
        configureCity()
        configureState()
        configureTemperature()
        configureSummary()
    }
    
    override var frame: CGRect {
      get {
          return super.frame
      }
      set (newFrame) {
          var frame =  newFrame
          frame.origin.y += 20
          frame.size.height -= 40
          super.frame = frame
      }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(weather: Weather){
        cityLable.text = weather.city
        stateLable.text = weather.state
//        temperatureLable.text = weather.temperature + ""
        let temp = Measurement(value: Double(weather.temperature)!, unit: UnitTemperature.celsius)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        temperatureLable.text = formatter.string(from: temp)
        summaryLable.text = weather.summary
        if(summaryImage[weather.summary] != nil){
//            self.backgroundColor = UIColor(patternImage: (UIImage(named: summaryImage[weather.summary]!))!)
            self.layer.contents = UIImage(named: summaryImage[weather.summary]!)?.cgImage
        }else{
            self.layer.contents = UIImage(named:"sunny_weather")?.cgImage
        }
    }
    
    func configureCell(){
//        self.backgroundColor = UIColor(patternImage: (UIImage(named: "clear_weather")?.crop(ratio: self.frame.size.width/self.frame.size.height))!)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    func configureCity(){
        cityLable.textColor = .white
        cityLable.font =  UIFont.systemFont(ofSize: 30)
        setCityLableConstraints()
    }
    
    func setCityLableConstraints(){
        cityLable.translatesAutoresizingMaskIntoConstraints = false
        cityLable.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        cityLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35).isActive = true
    }
    
    func configureTemperature(){
        temperatureLable.textColor = .white
        temperatureLable.font =  UIFont.systemFont(ofSize: 30)
        setTemperatureLableConstraints()
    }
    
    func setTemperatureLableConstraints(){
        temperatureLable.translatesAutoresizingMaskIntoConstraints = false
        temperatureLable.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        temperatureLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35).isActive = true
    }
    
    func configureState(){
        stateLable.textColor = .white
        stateLable.font = UIFont.systemFont(ofSize: 25)
        setStateLableConstraints()
    }
    
    func setStateLableConstraints(){
        stateLable.translatesAutoresizingMaskIntoConstraints = false
        stateLable.topAnchor.constraint(equalTo: topAnchor, constant: 70).isActive = true
        stateLable.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 35).isActive = true
    }
    
    func configureSummary(){
        summaryLable.textColor = .white
        summaryLable.font = UIFont.systemFont(ofSize: 20)
        setSummaryLableConstraints()
    }
    
    func setSummaryLableConstraints(){
        summaryLable.translatesAutoresizingMaskIntoConstraints = false
        summaryLable.topAnchor.constraint(equalTo: topAnchor, constant: 75).isActive = true
        summaryLable.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -35).isActive = true
    }

}
