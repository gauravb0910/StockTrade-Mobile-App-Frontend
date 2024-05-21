//
//  HourlyChartView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/29/24.
//

import Foundation
import SwiftUI
import WebKit

struct HourlyChartView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


struct HourlyChartComponent: View {
    var stockTicker: String
    var hourlyChartData: [PointDetails]
    var changeInPrice: Double

    var body: some View {
        let isChangeZero = String(format: "%.2f", abs(self.changeInPrice)) == "0.00"
        let isChangePositive = self.changeInPrice > 0
        let maxTimestamp = hourlyChartData.last?.t ?? 1000000000000000000;
        let filteredData: [PointDetails] = {
            let filtered = hourlyChartData.filter { obj in
                let timestamp = obj.t
                return maxTimestamp - timestamp <= 3600 * 6 * 1000
            }
            return filtered
        }()
        let data = filteredData.compactMap { obj in
            return [obj.t, obj.c]
        }
        let chartOptions = """
            {
                chart: {
                  animation: true
                , style: {
                   fontSize: '16px'
                  }
                },
                accessibility: {
                  enabled: false
                },
                title: {
                  text: `\(stockTicker) Hourly Price Variation`
                , style: {
                    fontFamily: '"Barlow", sans-serif'
                  , fontWeight: '600'
                  , fontSize: '18px'
                  }
                },
                plotOptions: {
                  series: {
                    color: \(isChangeZero)? 'black' : (\(isChangePositive)? '#058b03' : '#fd0214')
                  }
                },
                tooltip: {
                  animation: true
                , split: true
                },
                xAxis: [
                  { type: 'datetime'
                  , crosshair: true
                  , endOnTick: true
                  , tickPixelInterval: 80
                  }
                ],
                yAxis: {
                  opposite: true
                , showLastLabel: false
                , title: {
                    text: ''
                  }
                , labels: {
                    align: 'right'
                  , x: 0
                  , y: -2
                  }
                , tickPixelInterval: 80
                },
                series: [{
                  data: \(data)
                      , showInLegend: false
                , type: 'line'
                , name:`\(stockTicker)`
                , marker: {
                    enabled: false
                  }
                }]
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
                <div id="chart-container" style="max-height: 380px; margin: 0 auto"></div>
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
