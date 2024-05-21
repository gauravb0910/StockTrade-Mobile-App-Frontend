//
//  Portfolio.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/13/24.
//

import Foundation
import Alamofire
import SwiftyJSON

struct PortFolioElement: Identifiable, Decodable {
    var id: String?
    var _id: String?
    var stock_ticker: String
    var quantity: Int64
    var stock_company: String
    var total_cost: Double
    
    private enum CodingKeys: String, CodingKey {
        case id
        case _id
        case stock_ticker
        case quantity
        case stock_company
        case total_cost
    }
}

struct PortFolioUpdateResponse: Decodable {
    var acknowledged: Bool
    var modifiedCount: Int64
    var upsertedId: String?
    var upsertedCount: Int64
    var matchedCount: Int64
    
    private enum CodingKeys: String, CodingKey {
        case acknowledged, modifiedCount, upsertedId, upsertedCount, matchedCount
    }
}

struct WalletUpdateResponse: Decodable {
    var acknowledged: Bool
    var modifiedCount: Int64
    var upsertedId: String?
    var upsertedCount: Int64
    var matchedCount: Int64
    
    private enum CodingKeys: String, CodingKey {
        case acknowledged, modifiedCount, upsertedId, upsertedCount, matchedCount
    }
}

struct WalletAccount: Decodable  {
    var _id: String?
    var amount: Double
}

struct Portfolio: Decodable  {
    var portfolio: [PortFolioElement]
    var wallet_account: WalletAccount
}

struct StockPortfolioElement: Decodable  {
    var portfolio_data: PortFolioElement?
    var wallet_account: WalletAccount
}

func fetchPortfolioAndWallet(completion: @escaping (Result<Portfolio, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/walletAndPortfolio/get"

    AF.request(url).responseDecodable(of: Portfolio.self) { response in
        switch response.result {
        case .success(let portfolio):
            var updatedPortfolio = portfolio
            print("Hey : \(portfolio)")
            for i in 0..<updatedPortfolio.portfolio.count {
                updatedPortfolio.portfolio[i].id = updatedPortfolio.portfolio[i].id ?? updatedPortfolio.portfolio[i]._id
            }
            completion(.success(updatedPortfolio))
        case .failure(let error):
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
}

func fetchStockPortfolioAndWallet(stock_ticker: String, completion: @escaping (Result<StockPortfolioElement, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/portfolio/findOne/" + stock_ticker
    
    AF.request(url).responseDecodable(of: StockPortfolioElement.self) { response in
        switch response.result {
        case .success(let stock_portfolio):
            completion(.success(stock_portfolio))
        case .failure(let error):
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
}

func updatePortfolio(stock_ticker: String, stock_company: String, quantity: Int64, total_cost: Double, completion: @escaping (Result<PortFolioUpdateResponse, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/portfolio/updateOne/" + stock_ticker
    let parameters: [String: Any] = [
        "stock_ticker": stock_ticker,
        "stock_company": stock_company,
        "quantity": quantity,
        "total_cost": total_cost
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .responseDecodable(of: PortFolioUpdateResponse.self) { response in
            switch response.result {
            case .success(let resp):
                completion(.success(resp))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
}

func deleteFromPortfolio(stock_ticker: String, completion: @escaping (Result<DeleteElement, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/portfolio/deleteOne/" + stock_ticker
    
    AF.request(url).responseDecodable(of: DeleteElement.self) { response in
        switch response.result {
        case .success(let resp):
            completion(.success(resp))
        case .failure(let error):
            print("Error: \(error)")
            completion(.failure(error))
        }
    }
}

func updateWallet(amount: Double, completion: @escaping (Result<WalletUpdateResponse, Error>) -> Void) {
    let url = "https://assignment-3-backend-lctarnhjkq-wl.a.run.app/wallet/update"
    let parameters: [String: Any] = [
        "amount": amount
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .responseDecodable(of: WalletUpdateResponse.self) { response in
            switch response.result {
            case .success(let resp):
                completion(.success(resp))
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
}

func getDefaultPortfolioElement(ticker: String, name: String) -> PortFolioElement{
    return PortFolioElement( stock_ticker: ticker, quantity: 0, stock_company: name, total_cost: 0)
}
