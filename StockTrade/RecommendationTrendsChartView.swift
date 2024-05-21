//
//  RecommendationTrendsChartView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/29/24.
//

import Foundation
import SwiftUI
import WebKit

struct RecommendationTrendsChartView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


struct RecommendationTrendsChartComponent: View {
    var recommendationTrendsSeriesData: [StockRecommendationElement]

    var body: some View {
        let recommendation_trends_series_data = """
        [
            { name: 'Strong Buy'
            , data: \(recommendationTrendsSeriesData.compactMap({ obj in obj.strongBuy }))
            , color: '#177b3f'
            },
            { name: 'Buy'
            , data: \(recommendationTrendsSeriesData.compactMap({ obj in obj.buy }))
            , color: '#21c15e'
            },
            { name: 'Hold'
            , data: \(recommendationTrendsSeriesData.compactMap({ obj in obj.hold }))
            , color: '#c2951f'
            },
            { name: 'Sell'
            , data: \(recommendationTrendsSeriesData.compactMap({ obj in obj.sell }))
            , color: '#f76667'
            },
            { name: 'Strong Sell'
            , data: \(recommendationTrendsSeriesData.compactMap({ obj in obj.strongSell }))
            , color: '#8c3938'
            },
        ]
        """
        let recommendation_trends_categories = recommendationTrendsSeriesData.compactMap({obj in obj.period.dropLast(3)});
        let chartOptions = """
            {
                chart: {
                    type: 'column'
                    , style: {
                       fontSize: '16px'
                      }
                },
                title: {
                  text: 'Recommendation Trends'
                , align: 'center'
                , style: {
                    fontFamily: '"Barlow", sans-serif'
                  , fontWeight: '600'
                  , fontSize: '18px'
                  }
                },
                plotOptions: {
                  column: {
                    stacking: 'normal'
                  , dataLabels: {
                      enabled: true
                    }
                  }
                },
                xAxis: {
                    categories: \(recommendation_trends_categories)
                    , style: {
                        fontSize: '16px'
                      }
                },
                yAxis: {
                  min: 0
                , title: {
                    text: '#Analysis'
                  }
                , stackLabels: {
                    enabled: false
                  }
                , style: {
                    fontSize: '16px'
                  }
                , tickPixelInterval: 90
                },
                legend: {
                  enabled: true
                },
                series: \(recommendation_trends_series_data)
              }
        """
        let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <script src="https://code.highcharts.com/highcharts.js"></script>
                <script src="https://code.highcharts.com/modules/series-label.js"></script>
                <script src="https://code.highcharts.com/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/modules/export-data.js"></script>
            </head>
            <body>
                <div id="chart-container" style="margin: 0 auto"></div>
                <script type="text/javascript">
                    Highcharts.chart('chart-container', \(chartOptions));
                </script>
            </body>
            </html>
        """

        return VStack {
            HourlyChartView(htmlString: htmlString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
