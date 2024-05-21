//
//  FooterSection.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/15/24.
//

import SwiftUI

struct FooterSection: View {
    var body: some View {
        Section {
            HStack {
                Spacer()
                Link("Powered by Finnhub.io", destination: URL(string: "https://finnhub.io/")!)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                Spacer()
            }
        }
    }
}

