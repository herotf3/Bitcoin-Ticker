//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    //URL for get BTC's price in a specific currency
    //api : GET baseURL<currency>
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var finalURL = ""
    
    //icon up & down
    let iconUp=UIImage(named: "up")
    let iconDown=UIImage(named: "down")

    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var percentInday: UILabel!
    @IBOutlet weak var percentInMonth: UILabel!
    @IBOutlet weak var iconStatusDay: UIImageView!
    @IBOutlet weak var iconStatusMonth: UIImageView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.delegate=self
        currencyPicker.dataSource=self
    }

    
    //UIPickerView delegate methods
    //number of columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pick \(currencyArray[row])")
        //call api
        let finalUrl=baseURL+currencyArray[row]
        getPriceData(url: finalUrl)
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getPriceData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {

                    print("Sucess! Got the price data")
                    let weatherJSON : JSON = JSON(response.result.value!)

                    self.updatePriceData(json: weatherJSON)

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
                }
            }

    }


    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updatePriceData(json : JSON) {
        print(json)
        if let priceRes = json["bid"].double {
            self.bitcoinPriceLabel.text=String(priceRes)
            //status overview
            let changePercent = json["changes"]["percent"]
            let dayRating=changePercent["day"].double
            let monthRating=changePercent["month"].double
            
            changeIconStatus(ofImage: iconStatusDay, isIncrease: dayRating!>0.0)
            changeIconStatus(ofImage: iconStatusMonth, isIncrease: monthRating!>0.0)
            percentInday.text="\(dayRating ?? 0)%"
            percentInMonth.text="\(monthRating ?? 0)%"
        }
    }
    
    //MARK: Update UI
    func changeIconStatus(ofImage:UIImageView, isIncrease:Bool){
        if isIncrease {
            ofImage.image=iconUp
        }else{
            ofImage.image=iconDown
        }
    }



}

