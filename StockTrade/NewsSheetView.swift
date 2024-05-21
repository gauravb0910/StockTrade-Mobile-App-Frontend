//
//  NewsSheetView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/28/24.
//

import Foundation
import SwiftUI

struct NewsSheetView: View {
    var news_element: TopNewsElement
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, content: {
            HStack{
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding()
                        .cornerRadius(8)
                        .font(.system(size: 18))
                }
                
            }
            Text(news_element.source)
                .bold()
                .font(.system(size: 36))
            Text(Date(timeIntervalSince1970: TimeInterval(news_element.datetime)).formatted(date: .long, time: .omitted))
                .font(.system(size: 16))
                .foregroundColor(Color.gray)
                .padding(.horizontal, 2.0)
                .padding(.bottom, 14)
            Divider()
                .background(Color.gray)
                .padding(.bottom, 6)
            Text(news_element.headline)
                .font(.system(size: 20))
                .bold()
                .padding(.bottom, 1)
            Text(news_element.summary)
                .font(.system(size: 16))
                .lineLimit(16)
                .padding(.bottom, 1)
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                Text("For more details click")
                    .foregroundColor(.secondary)
                Link("here", destination: URL(string: news_element.url)!)
            })
            .font(.system(size: 14))
            HStack{
                Link(destination: URL(string: "https://twitter.com/intent/tweet?text=\(news_element.headline) \(news_element.url)")!) {
                    Image("Twitter-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.top, 20)
                }
                Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(news_element.url)&amp;src=sdkpreparse")!) {
                    Image("Facebook-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.top, 20)
                }
            }
            
            Spacer()
        })
        .font(.title)
        .padding()
    }
}

#Preview {
    NewsSheetView(news_element: TopNewsElement(category: "company", datetime: 1714251900, headline: "For Tesla Stock Investors, There Are Only Three Letters That Matter", id: 127278194, image: "https://g.foolcdn.com/editorial/images/774086/tesla-model-3.jpg", related:"TSLA", source: "Yahoo", summary: "Tesla is betting its future on autonomy.", url: "https://finnhub.io/api/news?id=85961147f546b62efeea9b48483056ea09cc7a77ee334ed359cb1226e9fbd998"))
}
