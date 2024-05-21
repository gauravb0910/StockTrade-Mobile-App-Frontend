//
//  HistoricalChartView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/29/24.
//

import Foundation
import SwiftUI
import WebKit

struct HistoricalChartView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


struct HistoricalChartComponent: View {
    var stockTicker: String
    var historicalChartData: [PointDetails]

    var body: some View {
        let ohlc_chart = historicalChartData.compactMap { obj in
            return [ obj.t, obj.o, obj.h, obj.l, obj.c ]
        }
        let volume_chart = historicalChartData.compactMap { obj in
            return [obj.t, obj.v]
        }
        let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <script src="https://code.highcharts.com/stock/highstock.js"></script>
                <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
                <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
                <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
                <script src="https://code.highcharts.com/modules/accessibility.js"></script>
            </head>
            <body>
                <div id="chart-container" style="max-height: 380px; margin: 0 auto"></div>
                <script type="text/javascript">
                    Highcharts.chart('chart-container', {
                chart: {
                    style: {
                       fontSize: '16px'
                      }
                },
                title: {
                    text: "\(stockTicker) Historical"
                },
                subtitle: {
                    text: 'With SMA and Volume by Price technical indicators'
                },
                legend: {
                    enabled: false
                },
                rangeSelector: {
                    enabled: true,
                    selected: 2,
                    inputEnabled: true
                },
                tooltip: {
                      split: true
                    , shared: false
                },
                navigator: {
                    enabled: true
                },
                credits: {
                    enabled: true,
                    href: 'https://polygon.io/',
                    text: 'Source: Polygon.io'
                },
                xAxis: {
                    maxRange: 2 * 365 * 24 * 3600 * 1000,
                    type: 'datetime',
                    dateTimeLabelFormats: {
                        hour: '%M:%Y'
                    }
                },
                yAxis: [
                    {
                        startOnTick: false,
                        endOnTick: false,
                        labels: {
                            align: 'right',
                            x: -3
                        },
                        title: {
                            text: 'OHLC'
                        },
                        height: '60%',
                        lineWidth: 2,
                        opposite: true,
                        resize: {
                            enabled: true
                        }
                    },
                    {
                        labels: {
                            align: 'right',
                            x: -3
                        },
                        title: {
                            text: 'Volume'
                        },
                        top: '65%',
                        height: '35%',
                        offset: 0,
                        opposite: true,
                        lineWidth: 2
                    }
                ],
                series: [
                    {
                        type: 'candlestick',
                        name: '\(stockTicker)',
                        id: '\(stockTicker)',
                        zIndex: 2,
                        data: \(ohlc_chart)
                    },
                    {
                        type: 'column',
                        name: 'Volume',
                        id: 'volume',
                        data: \(volume_chart),
                        yAxis: 1
                    },
                    {
                        type: 'vbp',
                        linkedTo: '\(stockTicker)',
                        params: {
                            volumeSeriesID: 'volume'
                        },
                        dataLabels: {
                            enabled: false
                        },
                        zoneLines: {
                            enabled: false
                        }
                    },
                    {
                        type: 'sma',
                        linkedTo: '\(stockTicker)',
                        zIndex: 1,
                        marker: {
                            enabled: false
                        }
                    }
                ]
            });
                </script>
            </body>
            </html>
        """

        return VStack {
            HistoricalChartView(htmlString: htmlString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
