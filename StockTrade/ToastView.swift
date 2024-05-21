//
//  ToastView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/29/24.
//

import Foundation
import SwiftUI

struct Toast<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    var body: some View {
        if self.isShowing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                  self.isShowing = false
                }
            }
        }
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenting()
//                    .blur(radius: self.isShowing ? 1 : 0)
                VStack {
                    self.text
                }
                .padding(.horizontal, 34)
                .padding(.vertical, 24)
                .font(.system(size: 18))
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(40)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}
