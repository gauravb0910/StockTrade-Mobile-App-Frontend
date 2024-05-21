//
//  Watchlist.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/13/24.
//

import Foundation
import Alamofire
import SwiftyJSON

struct WatchListElement: Identifiable, Decodable {
    var id: String?
    var _id: String?
    var stock_ticker: String
    var stock_company: String
    var current_price: Double?
    var change_in_price: Double?
    var change_in_price_percentage: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case _id
        case stock_ticker
        case stock_company
        case current_price
        case change_in_price
        case change_in_price_percentage
    }
}

struct WatchlistInsertResponse: Decodable {
    var acknowledged: Bool
    var insertedId: String
    
    private enum CodingKeys: String, CodingKey {
        case acknowledged, insertedId
    }
}

func fetchFavourites(completion: @escaping (Result<[WatchListElement], Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/watchlist/findAll"
    
    AF.request(url).responseDecodable(of: [WatchListElement].self) { response in
        switch response.result {
        case .success(let watchlist):
            var modifiedWatchlist = watchlist
            for i in 0..<modifiedWatchlist.count {
                modifiedWatchlist[i].id = modifiedWatchlist[i].id ?? modifiedWatchlist[i]._id
            }
            completion(.success(modifiedWatchlist))
            
        case .failure(let error):
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
}

func fetchStockFavourite(stock_ticker: String, completion: @escaping (Result<WatchListElement?, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/watchlist/findOne/"+stock_ticker
    
    AF.request(url).responseDecodable(of: WatchListElement?.self) { response in
        switch response.result {
        case .success(let watchlist):
            completion(.success(watchlist))
        case .failure(let error):
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
}

func addToFavourite(stock_ticker: String, stock_company: String, completion: @escaping (Result<WatchlistInsertResponse, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/watchlist/insertOne"
    let parameters: [String: Any] = [
        "stock_ticker": stock_ticker,
        "stock_company": stock_company
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .responseDecodable(of: WatchlistInsertResponse.self) { response in
            switch response.result {
            case .success(let resp):
                completion(.success(resp))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
}

func deleteFavourites(stock_ticker: String, completion: @escaping (Result<DeleteElement, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/watchlist/deleteOne/"+stock_ticker
    
    AF.request(url).responseDecodable(of: DeleteElement.self) { response in
        switch response.result {
        case .success(let success):
            completion(.success(success))
        case .failure(let error):
            print("Error \(error)")
            completion(.failure(error))
        }
    }
}
