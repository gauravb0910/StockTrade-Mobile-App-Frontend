//
//  FavouritesSection.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/15/24.
//

import SwiftUI

struct FavouritesSection: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        Section(header: Text("FAVOURITES")) {
            List{
                ForEach($viewModel.favourites, id: \.self.id) { element in
                    NavigationLink(destination: StockDetails(stock_ticker: element.stock_ticker.wrappedValue, viewModel: self.viewModel)) {
                        VStack{
                            HStack(alignment: .center, content: {
                                Text(element.stock_ticker.wrappedValue)
                                    .font(.system(size: 24))
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(getCurrencyFormat(value: element.current_price.wrappedValue ?? 0.0))
                                    .fontWeight(.semibold)
                            })
                            HStack(alignment: .center, content: {
                                Text(element.stock_company.wrappedValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? "minus" : (element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? "arrow.up.forward" : "arrow.down.forward"))
                                    .foregroundColor(String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? .secondary :(element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? .green : .red))
                                (Text(getCurrencyFormat(value: element.change_in_price.wrappedValue ?? 0.0)) + Text(" (") + Text(getPercentageFormat(value: element.change_in_price_percentage.wrappedValue ?? 0.0)) + Text(")"))
                                    .foregroundColor(String(format: "%.2f", abs(element.change_in_price.wrappedValue ?? 0.0)) == "0.00" ? .secondary :(element.change_in_price.wrappedValue ?? 0.0 > 0.0 ? .green : .red))
                            })
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    let dispatchGroup = DispatchGroup()
                    let favouritesData: [WatchListElement] = viewModel.favourites
                    var allElementsDeleted: Bool = true
            
                    for index in indexSet {
                        dispatchGroup.enter()
                        let deletedElement = viewModel.favourites[index]
                        deleteFavourites(stock_ticker: deletedElement.stock_ticker) { response in
                            switch response {
                            case .success(let success):
                                if (success.deletedCount != 1) {
                                    allElementsDeleted.toggle()
                                }
                            case .failure(let error):
                                print("Error while deleting watchlist data: \(error.localizedDescription)")
                            }
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        if (allElementsDeleted){
                            print("1")
                            viewModel.favourites.remove(atOffsets: indexSet)
                        } else {
                            print("2")
                            viewModel.favourites = favouritesData
                        }
                        print(viewModel.favourites)
                    }
                })
                .onMove(perform: { indices, newOffset in
                    viewModel.favourites.move(fromOffsets: indices, toOffset: newOffset)
                    withAnimation {
                        viewModel.isEditable = false
                    }
                })
                .onLongPressGesture {
                    withAnimation {
                        viewModel.isEditable = true
                    }
                }
            }
            .environment(\.editMode, viewModel.isEditable ? .constant(.active) : .constant(.inactive))
            .padding(.horizontal, 5.0)
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.updateFavourites()
        }
    }
}
