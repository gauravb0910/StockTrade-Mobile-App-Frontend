//
//  SplashScreenView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/11/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "Launchscreen-logo")
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
