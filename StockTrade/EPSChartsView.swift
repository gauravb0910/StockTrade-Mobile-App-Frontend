//
//  EPSChartsView.swift
//  StockTrade
//
//  Created by Gaurav Baisware on 4/30/24.
//

import Foundation
import SwiftUI
import WebKit

struct EPSChartsView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}


struct EPSChartsComponent: View {
    var epsChartsData: [StockEarningsElement]

    var body: some View {
        let company_earnings_series_categories = epsChartsData.compactMap({ obj in
            return "\(obj.period) <br>Surprise: \(obj.surprise)"
        });
        let company_earnings_series_actual_data = epsChartsData.compactMap({ obj in obj.actual })
        let company_earnings_series_estimate_data = epsChartsData.compactMap({ obj in obj.estimate })
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
                  text: 'Historical EPS Surprises'
                , align: 'center'
                , style: {
                    fontFamily: '"Barlow", sans-serif'
                  , fontWeight: '600'
                  , fontSize: '18px'
                  }
                },
                xAxis: {
                  categories: \(company_earnings_series_categories)
                , labels: {
                    style: {
                      textAlign: 'center'
                    }
                    , rotation: -45
                  }
                },
                yAxis: {
                  title: {
                    text: 'Quarterly EPS'
                  , x: -15
                  }
                  , tickPixelInterval: 90
                },
                legend: {
                  enabled: true
                },
                tooltip: {
                    animation: true,
                    shared: true,
                    useHTML: true,
                    formatter: function() {
                        var s = '<span style="font-size: 0.8em">' + this.x + '</span><br/>';
                        for (var i = 0; i < this.points.length; i++) {
                            var point = this.points[i];
                            s += '<span style="color:' + point.color + '">&#x25CF;</span> ' + point.series.name + ': <b>' + point.y.toFixed(2) + '</b><br/>';
                        }
                        return s;
                    }
                },
                series: [{
                  name: 'Actual',
                  type: 'spline',
                  data: \(company_earnings_series_actual_data),
                  dataLabels: { enabled: false },
                  tooltip: {
                    valueDecimals: 2
                  }
                }, {
                  name: 'Estimate',
                  type: 'spline',
                  data: \(company_earnings_series_estimate_data),
                  dataLabels: { enabled: false },
                  tooltip: {
                    valueDecimals: 2
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
                <script src="https://code.highcharts.com/modules/exporting.js"></script>
                <script src="https://code.highcharts.com/modules/export-data.js"></script>
            </head>
            <body>
                <div id="chart-container" style="height: 400px; margin: 0 auto"></div>
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
