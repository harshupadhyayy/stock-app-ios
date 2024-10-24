import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher


struct StockInfo: View {
    let watchlistViewModel = WatchlistViewModel()
    let symbol: String
    @State private var stockData: JSON = JSON()
    @State private var profileData: JSON = JSON()
    @State private var peersData: JSON = JSON()
    @State private var sentimentData: JSON = JSON()
    @State private var newsData: JSON = JSON()
    @State private var watchlistedOrNot: Bool = false
       
    @ObservedObject var wViewModel: WatchlistViewModel
    @State private var loading = true
    @State private var selectedTab = 0
    @State private var isTradeSheetPresented = false
    @State private var showToast = false
    @State private var toastMsg = ""
    @State private var buttonClicked = ""
    @State private var purchasedOrNot: Bool = false

    @ObservedObject var pViewModel: PortfolioViewModel
    
    var htmlString: String {
            """
            <!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Insights Stack Chart</title>
              <!-- Include Highcharts library -->
              <script src="https://code.highcharts.com/highcharts.js"></script>
            </head>
            <body>
              <div id="container"></div>
            
              <script>

                fetch('API/api/v1/stock/recommendation?symbol=\(symbol)')
                  .then(response => response.json())
                  .then(data => {
            
                    const categories = data.map(item => item.period.slice(0, 7));
            
                    const filteredData = data.reduce((acc, item) => {
                      acc.strongBuy.push(item.strongBuy);
                      acc.buy.push(item.buy);
                      acc.hold.push(item.hold);
                      acc.sell.push(item.sell);
                      acc.strongSell.push(item.strongSell);
                      return acc;
                    }, { strongBuy: [], buy: [], hold: [], sell: [], strongSell: [] });
            
                
                    const options = {
                      chart: {
                        type: "column",
                        backgroundColor: '#f8f8f8',
                        renderTo: 'container'
                      },
                      title: {
                        text: "Recommendation Trends",
                        align: "center",
                      },
                      xAxis: {
                        categories: categories,
                      },
                      yAxis: {
                        min: 0,
                        title: {
                          text: "#Analysis",
                        },
                        stackLabels: {
                          enabled: false,
                        },
                      },
                      legend: {
                        align: "center",
                        layout: 'horizontal',
                        backgroundColor: "#f8f8f8",
                        borderColor: "#CCC",
                        borderWidth: 0,
                        shadow: false,
                      },
                      tooltip: {
                        headerFormat: "<b>{point.x}</b><br/>",
                        pointFormat: "{series.name}: {point.y}<br/>Total: {point.stackTotal}",
                      },
                      plotOptions: {
                        column: {
                          stacking: "normal",
                          dataLabels: {
                            enabled: true,
                          },
                        },
                      },
                      series: [
                        {
                          name: "Strong Buy",
                          data: filteredData.strongBuy,
                          color: "#266331"
                        },
                        {
                          name: "Buy",
                          data: filteredData.buy,
                          color: "#3faf4a"
                        },
                        {
                          name: "Hold",
                          data: filteredData.hold,
                          color: "#ac7e17"
                        },
                        {
                          name: "Sell",
                          data: filteredData.sell,
                          color: "#e85150"
                        },
                        {
                          name: "Strong Sell",
                          data: filteredData.strongSell,
                          color: "#722c2b"
                        },
                      ],
                    };
            
                    
                    const chart = new Highcharts.Chart(options);
                  })
                  .catch(error => {
                    console.error('Error fetching data:', error);
                  });
              </script>
            </body>
            </html>
            """
        }
    
    var epsChart: String {
            """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Historical EPS Surprises</title>
      <!-- Include Highcharts library -->
      <script src="https://code.highcharts.com/highcharts.js"></script>
    </head>
    <body>
      <!-- Container for the chart -->
      <div id="chart-container"></div>

      <script>
    
        fetch('API/api/v1/stock/earnings?symbol=\(symbol)')
          .then(response => response.json())
          .then(data => {
    
            const processedData = data.map(item => ({
              actual: item.actual !== null ? item.actual : 0,
              estimate: item.estimate !== null ? item.estimate : 0,
              period: item.period !== null ? item.period : 0,
              quarter: item.quarter !== null ? item.quarter : 0,
              surprise: item.surprise !== null ? item.surprise : 0,
              surprisePercent: item.surprisePercent !== null ? item.surprisePercent : 0,
              symbol: item.symbol !== null ? item.symbol : 0,
              year: item.year !== null ? item.year : 0,
            }));

    
            const actualData = processedData.map((item, idx) => [idx, item.actual]);
            const estimateData = processedData.map((item, idx) => [idx, item.estimate]);
            const categories = processedData.map((item, idx) => item.period);
            const surpriseMapping = {};
            processedData.forEach((item) => {
              surpriseMapping[item.period] = item.surprise;
            });

        
            const options = {
              chart: {
                type: "spline",
                inverted: false,
                backgroundColor: "#f8f8f8",
              },
              title: {
                text: "Historical EPS Surprises",
                align: "center",
              },
              xAxis: {
                reversed: false,
                categories: categories,
                labels: {
                  formatter: function () {
                    return (
                      this.value + "<br>" + "Surprise: " + surpriseMapping[this.value]
                    );
                  },
                },
                maxPadding: 0.05,
                showLastLabel: true,
              },
              yAxis: {
                title: {
                  text: "Quarterly EPS",
                },
                labels: {
                  format: "{value}",
                },
                lineWidth: 2,
              },
              legend: {
                enabled: true,
              },
              tooltip: {
                shared: true,
                useHTML: true,
                
                formatter: function () {
                  const dateX = this.points[0].point.category;
                  const surprise = surpriseMapping[dateX];
                  let html = `${this.x}<br/>Surprise: ${surprise}<br>`;
                  this.points.forEach((point) => {
                    html += `<span style="color:${point.color}">●</span> ${point.series.name}: ${point.y}<br/>`;
                  });
                  return html;
                },
              },
              plotOptions: {
                spline: {
                  marker: {
                    enable: false,
                  },
                },
              },
              series: [
                {
                  name: "Actual",
                  data: actualData,
                },
                {
                  name: "Estimate",
                  data: estimateData,
                },
              ],
            };

    
            Highcharts.chart('chart-container', options);
          })
          .catch(error => {
            console.error('Error fetching data:', error);
          });
      </script>
    </body>
    </html>


    """
        }
    
    var historicalChart : String {
            """
    <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Charts</title>
          <!-- Include Highcharts library -->
          <script src="https://code.highcharts.com/stock/highstock.js"></script>

        <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>

        <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
        <script src="https://code.highcharts.com/stock/indicators/bollinger-bands.js"></script>
        <script src="https://code.highcharts.com/stock/indicators/ema.js"></script>

        <script src="https://code.highcharts.com/stock/modules/annotations-advanced.js"></script>

        <script src="https://code.highcharts.com/stock/modules/full-screen.js"></script>
        <script src="https://code.highcharts.com/stock/modules/price-indicator.js"></script>
        <script src="https://code.highcharts.com/stock/modules/stock-tools.js"></script>
        <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
        <script src="https://code.highcharts.com/modules/accessibility.js"></script>
        </head>
        <body>
          <div id="chart-container" style="height: 380px; background-color: #f8f8f8;"></div>
          <script>
            document.addEventListener('DOMContentLoaded', function () {
                var twoYearsAgo = new Date();
              twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2);
              var formattedTwoYearsAgo = twoYearsAgo.toISOString().slice(0,10);

        
              var currentDate = new Date().toISOString().slice(0,10);
              fetch(`API/api/v1/stock/chart?symbol=AAPL&from=${formattedTwoYearsAgo}&to=${currentDate}`)
                .then(response => response.json())
                .then(data => {
                  var ohlc = data.results.map(result => [
                    result.t,
                    result.o,
                    result.h,
                    result.l,
                    result.c
                  ]);

                  var volume = data.results.map(result => [
                    result.t,
                    result.v
                  ]);

    //               const options = {
    //     chart: {
    //       height: 550,
    //       backgroundColor: '#f8f8f8',
    //     },

    //     rangeSelector: {
    //       selected: 2,
    //     },

    //     title: {
    //       text: `${symbol} Historical`,
    //     },

    //     subtitle: {
    //       text: "With SMA and Volume by Price technical indicators",
    //     },

    //     yAxis: [
    //       {
    //         startOnTick: false,
    //         endOnTick: false,
    //         labels: {
    //           align: "right",
    //           x: -3,
    //         },
    //         title: {
    //           text: "OHLC",
    //         },
    //         height: "60%",
    //         lineWidth: 2,
    //         resize: {
    //           enabled: true,
    //         },
    //       },
    //       {
    //         labels: {
    //           align: "right",
    //           x: -3,
    //         },
    //         title: {
    //           text: "Volume",
    //         },
    //         top: "65%",
    //         height: "35%",
    //         offset: 0,
    //         lineWidth: 2,
    //       },
    //     ],

    //     tooltip: {
    //       split: true,
    //     },

    //     plotOptions: {
    //       series: {
    //         dataGrouping: {
    //           enabled: false,
    //           units: groupingUnits,
    //         },
    //       },
    //     },

    //     series: [
    //       {
    //         type: "candlestick",
    //         name: `${symbol}`,
    //         id: `${symbol}`,
    //         zIndex: 2,
    //         data: ohlc,
    //       },
    //       {
    //         type: "column",
    //         name: "Volume",
    //         id: "volume",
    //         data: volume,
    //         yAxis: 1,
    //       },
    //       {
    //         type: "vbp",
    //         linkedTo: `${symbol}`,
    //         params: {
    //           volumeSeriesID: "volume",
    //         },
    //         dataLabels: {
    //           enabled: false,
    //         },
    //         zoneLines: {
    //           enabled: false,
    //         },
    //       },
    //       {
    //         type: "sma",
    //         linkedTo: `${symbol}`,
    //         zIndex: 1,
    //         marker: {
    //           enabled: false,
    //         },
    //       },
    //     ],
    //   };

                  var options = {
                    chart: {
                      height: 380,
                      backgroundColor: '#f8f8f8',
                      renderTo: 'chart-container',
                      type: 'line'
                    },
                    rangeSelector: {
                      selected: 2
                    },
                    title: {
                      text: data.ticker + ' Historical'
                    },
                    subtitle: {
                      text: 'With SMA and Volume by Price technical indicators'
                    },
                    yAxis: [{
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
                      resize: {
                        enabled: true
                      }
                    }, {
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
                      lineWidth: 2
                    }],
                    tooltip: {
                      split: true
                    },
                    series: [{
                      type: 'candlestick',
                      name: data.ticker,
                      id: data.ticker,
                      zIndex: 2,
                      data: ohlc
                    }, {
                      type: 'column',
                      name: 'Volume',
                      id: 'volume',
                      data: volume,
                      yAxis: 1
                    },
                    {
                    type: "vbp",
                    linkedTo: data.ticker,
                    params: {
                    volumeSeriesID: "volume",
                    },
                    dataLabels: {
                    enabled: false,
                    },
                    zoneLines: {
                    enabled: false,
                    },
          },
          {
            type: "sma",
            linkedTo: data.ticker,
            zIndex: 1,
            marker: {
              enabled: false,
            },
          },
                ]
                  };

                  Highcharts.stockChart('chart-container', options);
                })
                .catch(error => {
                  console.error('Error fetching data:', error);
                });
            });
          </script>
        </body>
        </html>

    """
        }
    
    var hourlyChart : String {
    """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Summary Chart</title>
  <!-- Include Highcharts library -->
  <script src="https://code.highcharts.com/highcharts.js"></script>
</head>
<body>
  <div id="summary-chart-container" style="width: 100%; height: 380px;"></div>

  <script>

    var flag = \(stockData["d"].doubleValue >= 0) ? 1 : 0
    var symbol = "\(symbol)"
    var chartData = []
    



    fetch(`API/api/v1/stock/summary-chart?symbol=\(symbol)&from=2024-05-01&to=2024-05-02`)
      .then(response => response.json())
      .then(data => {
     
        chartData = data["results"].map((item, idx) => {
      return [item.t, item.c]
    })

        

        const options = {
    chart: {
      backgroundColor: '#f8f8f8',
    },

    time: {
      timezone: 'America/Los_Angeles'
    },

    title: {
      text: `${symbol} Hourly Price Variation`,
      align: "center",
      style: {
        color: "grey",
        fontWeight: "light"
      }
    },

    yAxis: {
        opposite: true,
      title: {
        enabled: false,
        text: "random",
      },
    },

    xAxis: {
      type: "datetime",
    },

    legend: {
      enabled: false,
      layout: "vertical",
      align: "right",
      verticalAlign: "middle",
    },

    plotOptions: {
      series: {
        marker: {
            enabled: false,
        },
        label: {
          connectorAllowed: false,
        },
     
        color: flag ? "green" : "red"
      },
    },

    series: [
      {
        name: `${symbol}`,
        data: chartData,
      },
    ],

    responsive: {
      rules: [
        {
          condition: {
            maxWidth: 500,
          },
          chartOptions: {
            legend: {
              layout: "horizontal",
              align: "center",
              verticalAlign: "bottom",
            },
          },
        },
      ],
    },
  };
        Highcharts.chart('summary-chart-container', options);
      })
      .catch(error => {
        console.error('Error fetching data:', error);
      });
  </script>
</body>
</html>


"""
    }
    

    
    var body: some View {
        if !loading {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(profileData["name"])")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    HStack {
                        Text("$\(stockData["c"].doubleValue, specifier: "%.2f")")
                            .font(.system(size: 35))
                            .bold()
                        if(stockData["d"].doubleValue > 0.0) {
                            Image(systemName: "line.diagonal.arrow")
                                .foregroundColor(.green)
                                .font(.system(size: 22))
                        } else if(stockData["d"].doubleValue < 0.0) {
                            Image(systemName: "line.diagonal.arrow")
                                .rotationEffect(Angle(degrees: 90))
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        } else {
                            Image(systemName: "minus")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                        
                        Text("\(stockData["d"].doubleValue, specifier: "%.2f")")
                            .font(.system(size: 22))
//                            .foregroundColor(stockData["d"].doubleValue >= 0.0 ? .green : .red)
                            .foregroundColor(stockData["d"].doubleValue > 0 ? .green : (stockData["d"].doubleValue < 0 ? .red : .gray))

                        Text("(\(stockData["dp"].doubleValue, specifier: "%.2f")%)")
                            .font(.system(size: 22))
//                            .foregroundColor(stockData["d"].doubleValue >= 0.0 ? .green : .red)
                            .foregroundColor(stockData["d"].doubleValue > 0 ? .green : (stockData["d"].doubleValue < 0 ? .red : .gray))

                        Spacer()
                    }
                    
                                        TabView(selection: $selectedTab) {
                                                 
                                            WebViewContainer(htmlString: hourlyChart)
                    
                                                        .tabItem {
                                                            Image(systemName: "chart.xyaxis.line")
                                                            Text("Hourly")
                                                        }
                                                        .tag(0)
                    
                                                
                                            WebViewContainer(htmlString: historicalChart)
                                                        .tabItem {
                                                            Image(systemName: "clock.fill")
                                                            Text("Historical")
                                                        }
                                                        .tag(1)
                    
                                                }
                                        .frame(height: 450)
                    
                    //                    Text("insert portfolio section here")
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Portfolio")
                                .font(.title)
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                if let portfolioItem = pViewModel.portfolioData.first(where: { $0.symbol == symbol }) {
                                    let currentPrice = stockData["c"].doubleValue
                                    let currentTotal = Double(portfolioItem.quantity) * (currentPrice)
                                    let change = currentTotal - portfolioItem.totalPrice
                                    let avgPrice = portfolioItem.totalPrice / Double(portfolioItem.quantity)
                                    
                                    HStack {
                                        Text("Shares Owned:")
                                            .bold()
                                        Text("\(portfolioItem.quantity)")
                                    }
                                    .padding(.top, 1)
                                    HStack {
                                        Text("Avg. Cost / Share:")
                                            .bold()
                                        Text("$\(avgPrice, specifier: "%.2f")")
                                    }
                                    .padding(.top, 1)
                                    HStack {
                                        Text("Total Cost:")
                                            .bold()
                                        Text("$\(portfolioItem.totalPrice, specifier: "%.2f")")
                                    }
                                    .padding(.top, 1)
                                    HStack {
                                        Text("Change:")
                                            .bold()
                                        Text("$\(change, specifier: "%.2f")")
                                            .foregroundColor(change > 0 ? .green : (change < 0) ? .red : .gray)
                                    }
                                    .padding(.top, 1)
                                    HStack {
                                        Text("Market Value:")
                                            .bold()
                                        Text("$\(currentTotal, specifier: "%.2f")")
                                            .foregroundColor(change > 0 ? .green : (change < 0) ? .red : .gray)
                                    }
                                    .padding(.top, 1)
                                } else {
                                    Text("You have 0 shares of \(symbol).")
                                    Text("Start trading!")
                                }
                            }
                            .font(.system(size: 16))
                            .frame(width: 220, alignment: .leading)
                            
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isTradeSheetPresented.toggle()
                                    }) {
                                        Text("Trade")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.green)
                                            .cornerRadius(20)
                                    }
                                    .sheet(isPresented: $isTradeSheetPresented) {
                                        
                                        
                                        TradeSheet(pViewModel: pViewModel, symbol: profileData["ticker"].stringValue, name: profileData["name"].stringValue)
                                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Stats")
                                .font(.title)
                            Spacer()
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("High Price:")
                                        .bold()
                                    Text("$\(stockData["h"].doubleValue, specifier: "%.2f")")
                                }
                                .frame(width: 170, alignment: .leading)
                                HStack {
                                    Text("Low Price:")
                                        .bold()
                                    Text("$\(stockData["l"].doubleValue, specifier: "%.2f")")
                                }
                                .padding(.top, 1)
                            }
                            .font(.system(size: 16))
                            .padding(.top, 1)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Open Price:")
                                        .bold()
                                    Text("$\(stockData["o"].doubleValue, specifier: "%.2f")")
                                }
                                HStack {
                                    Text("Prev. Close:")
                                        .bold()
                                    Text("$\(stockData["pc"].doubleValue, specifier: "%.2f")")
                                }
                                .padding(.top, 1)
                            }
                            .font(.system(size: 16))
                            .padding(.top, 1)
                        }
                    }
                    .padding(.top, 10)
                    
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("About")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("IPO Start Date:")
                                        .bold()
                                        .frame(width: 170, alignment: .leading)
                                    Text("\(profileData["ipo"])")
                                }
                                .padding(.top, 1)
                                HStack {
                                    Text("Industry:")
                                        .bold()
                                        .frame(width: 170, alignment: .leading)
                                    Text("\(profileData["finnhubIndustry"])")
                                }
                                .padding(.top, 1)
                                HStack {
                                    Text("Webpage:")
                                        .bold()
                                        .frame(width: 170, alignment: .leading)
                                    Link("\(profileData["weburl"])",
                                         destination: URL(string: "\(profileData["weburl"])")!)
                                    .frame(width: 180, alignment: .leading)
                                }
                                .padding(.top, 1)
                                HStack {
                                    Text("Peers:")
                                        .bold()
                                        .frame(width: 170, alignment: .leading)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(peersData.arrayValue.map { $0.stringValue }, id: \.self) { symbol in
                                                NavigationLink(destination: StockInfo(symbol: symbol, wViewModel: wViewModel, pViewModel: pViewModel)) {
                                                    Text("\(symbol),")
                                                        .foregroundStyle(.blue)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .font(.system(size: 16))
                    }
                    
                    .padding(.top, 10)
                    
                    VStack {
                        HStack {
                            Text("Insights")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }
                        SentimentTable(data: sentimentData, name: profileData["name"].stringValue)
                    }
                    .padding(.top, 1)
                    
                    
                                        WebViewContainer(htmlString: htmlString)
                                            .frame(height: 410)
                                        WebViewContainer(htmlString: epsChart)
                                            .frame(height: 410)
                    
                    VStack() {
                        HStack {
                            Text("News")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }
                        NewsList(data: newsData)
//                        Text("after news")
                    }
                    
                }
                .toast1(isPresented: $showToast, message: toastMsg)
                .padding()
                .navigationTitle(symbol)
                
            }
            .navigationBarItems(
                trailing:
                    Button(action: {
                        if watchlistedOrNot {
                            AF.request("API/api/v1/delete-symbol-watchlist?symbol=\(profileData["ticker"])", method: .delete)
                                .validate()
                                .response { response in
                                    switch response.result {
                                    case .success:
                                       
                                        print("Symbol \(symbol) deleted successfully")
                                    case .failure(let error):
                                       
                                        print("Error: \(error)")
                                    }
                                }
                            wViewModel.watchlistData.removeAll { $0.symbol == profileData["ticker"].stringValue }
                            
                            toastMsg = "Removing \(profileData["ticker"]) from Favorites"
                            showToast = true
                            watchlistedOrNot.toggle()
                        } else {
                            let symbol = profileData["ticker"].stringValue
                            let name = profileData["name"].stringValue

                            
                            let parameters: [String: Any] = [
                                "symbol": symbol,
                                "name": name
                            ]
                            AF.request("API/api/v1/save-watchlist", method: .post, parameters: parameters, encoding: JSONEncoding.default)
                                .validate()
                                .responseJSON { response in
                                    switch response.result {
                                    case .success(let value):
                                        
                                        print("Response JSON: \(value)")
                                    case .failure(let error):
                                      
                                        print("Error: \(error)")
                                    }
                                }
                            let newItem = StockItem(name: profileData["name"].stringValue, symbol: profileData["ticker"].stringValue)
                            wViewModel.watchlistData.append(newItem)
                            print(wViewModel.watchlistData)
                            toastMsg = "Adding \(profileData["ticker"]) to Favorites"
                            showToast = true
                            watchlistedOrNot.toggle()
                        }
                    }) {
                        if watchlistedOrNot {
                            Image(systemName: "plus.circle.fill")
                        } else {
                            Image(systemName: "plus.circle")
                        }
                    }
            )
        }
        else {
            ProgressView()
                .onAppear{
                    fetchData(symbol: symbol)
                    getPurchasedOrNot()
                }
        }
        
        
        
    }
    
    func getPurchasedOrNot() {
        print(pViewModel.portfolioData)
        if let portfolioItem = pViewModel.portfolioData.first(where: { $0.symbol == symbol }) {
            print("Portfolio item found: \(portfolioItem)")
            self.purchasedOrNot = true
        } else {
            print("item not in portfolio")
            self.purchasedOrNot = false
        }
    }
    
    private func fetchData(symbol: String) {
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/quote?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
//                                        print(json)
                    self.stockData = json
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/stock/profile2?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //                    print(json)
                    self.profileData = json
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/stock/peers?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    //                    print(json)
                    self.peersData = json
                    //                    print(peersData)
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/stock/insider-sentiment?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.sentimentData = json["data"]
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        
    
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/company-news?symbol=\(symbol)&from=2024-04-18&to=2024-05-02").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.newsData = json
                    //                    print(self.newsData)
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            AF.request("API/api/v1/find-symbol-watchlist?symbol=\(symbol)").responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if(json == true) {
                        watchlistedOrNot = true
                    } else {
                        watchlistedOrNot = false
                    }
                    print(watchlistedOrNot)
                case .failure(let error):
                    print("Error: \(error)")
                }
                group.leave()
            }
        }
        
        
        group.notify(queue: .main) {
            loading = false
        }
    }
}

struct ToastView1: View {
    let message: String
    
    var body: some View {
        ZStack {
//            Color.black
//                .opacity(0.7)
//                .ignoresSafeArea()
            VStack {
                Spacer()
                HStack {
                    Text(message)
                        .padding()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.gray)
                .cornerRadius(40)
            .padding(.horizontal, 20)
//                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.3))
            .padding()
        }
    }
}

extension View {
    func toast1(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                ToastView1(message: message)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            }
        }
    }
}

// Preview code
struct StockInfo_Previews: PreviewProvider {
    static var previews: some View {
        let wViewModel = WatchlistViewModel()
        let pViewModel = PortfolioViewModel()
        StockInfo(symbol: "AAPL", wViewModel: wViewModel, pViewModel: pViewModel)
    }
}
