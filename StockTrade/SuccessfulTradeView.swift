//
//  SuccessfulTradeView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/28/24.
//

import Foundation
import SwiftUI

struct SuccessfulTradeView: View {
    var stockModel: StockDetailsModel
    var tradeSheet: TradeSheetView
    var stockDetailsView: StockDetails
    var allStocksSold: Bool
    var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismissSuccessfulTrade
    
    var body: some View {
        VStack(alignment: .center, content: {
            Spacer()
            Text("Congratulations!")
                .bold()
                .font(.system(size: 36))
            Text(stockModel.successfulToastMessage)
                .font(.system(size: 17))
                .foregroundColor(.white)
                .padding(.vertical, 6)
            Spacer()
            Button(action: {
                stockModel.fetchStockData()
                viewModel.fetchData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    tradeSheet.dismiss()
                    if self.allStocksSold {
                        stockDetailsView.stockDetailsPageDismiss()
                        viewModel.fetchData()
                    }
                }
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .font(.system(size: 16))
            .foregroundColor(.green)
            .background(.white)
            .frame(maxWidth: .infinity)
            .cornerRadius(30)
            .padding()
        })
        .background(.green)
        .foregroundColor(.white)
    }
}
