//
//  utils.swift
//  hw9
//
//  Created by Tianhao Zhang on 4/27/20.
//  Copyright © 2020 Tianhao Zhang. All rights reserved.
//

import Foundation
import SwiftyJSON

func setStorage(news:News){
    let defaults = UserDefaults.standard
    var newsDic = Dictionary<String, String>()
    newsDic["imageUrl"] = news.imageUrl
    newsDic["articleId"] = news.articleId
    newsDic["section"] = news.section
    newsDic["time"] = news.time
    newsDic["timediff"] = news.timediff
    newsDic["title"] = news.title
    newsDic["isBookmarked"] = "true"
    
    var dic_list : [Dictionary<String, String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            dic_list.append(newsDic)
        }
        catch{
            print("decode error")
        }
    }else{
        dic_list = [newsDic]
    }
    
    //write to storage
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do{
        let result = try encoder.encode(dic_list)
        let res_str = String(data: result, encoding: .utf8)!
        defaults.set(res_str, forKey: "bookmark")
    }
    catch{
        print("encode error")
    }
}

func checkStorage(news:News) -> Bool{
    let defaults = UserDefaults.standard
    var dic_list : [Dictionary<String,String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            for index in 0..<dic_list.count{
                let dic = dic_list[index]
                if(dic["articleId"] == news.articleId){
                    return true;
                }
            }
        }
        catch{
            print("decode error")
        }
    }else{
        print("no storage")
    }
    return false;
}

func checkStorage(articleId:String) -> Bool{
    let defaults = UserDefaults.standard
    var dic_list : [Dictionary<String,String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            for index in 0..<dic_list.count{
                let dic = dic_list[index]
                if(dic["articleId"] == articleId){
                    return true;
                }
            }
        }
        catch{
            print("decode error")
        }
    }else{
        print("no storage")
    }
    return false;
}

func getStorage() -> [Dictionary<String,String>]{
    let defaults = UserDefaults.standard
    var dic_list : [Dictionary<String,String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
//        defaults.removeObject(forKey: "bookmark")
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            for index in 0..<dic_list.count{
                let dic = dic_list[index]
            }
            return dic_list
        }
        catch{
            print("decode error")
        }
    }else{
        print("no storage")
    }
    return []
}

func deleteStorage(news:News){
    let defaults = UserDefaults.standard
    var dic_list : [Dictionary<String,String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            for index in 0..<dic_list.count{
                let dic = dic_list[index]
                if(dic["articleId"] == news.articleId){
//                    print("found")
//                    print(dic_list[index])
                    dic_list.remove(at: index)
                    break;
                }
            }
        }
        catch{
            print("decode error")
        }
    }else{
        print("no storage")
    }
    
    //write to storage
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do{
        let result = try encoder.encode(dic_list)
        let res_str = String(data: result, encoding: .utf8)!
        defaults.set(res_str, forKey: "bookmark")
    }
    catch{
        print("encode error")
    }
}

func deleteStorage(articleId:String){
    let defaults = UserDefaults.standard
    var dic_list : [Dictionary<String,String>] = []
    if let storage = defaults.string(forKey: "bookmark") {
        let decoder = JSONDecoder()
        do{
            dic_list = try decoder.decode([Dictionary<String,String>].self, from: storage.data(using: .utf8)!)
            for index in 0..<dic_list.count{
                let dic = dic_list[index]
                if(dic["articleId"] == articleId){
                    dic_list.remove(at: index)
                    break;
                }
            }
        }
        catch{
            print("decode error")
        }
    }else{
        print("no storage")
    }
    
    //write to storage
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do{
        let result = try encoder.encode(dic_list)
        let res_str = String(data: result, encoding: .utf8)!
        defaults.set(res_str, forKey: "bookmark")
    }
    catch{
        print("encode error")
    }
}
