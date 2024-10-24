import SwiftUI
import SwiftyJSON
import Kingfisher

struct NewsList: View {
    var data: JSON
    @State private var isSheetPresented = false
    
    var newsData: [News] {
        data.arrayValue.map { News(json: $0.dictionaryObject ?? [:]) }
    }
    
    func convertTimestampToDate(_ timestamp: TimeInterval) -> String {
            let date = Date(timeIntervalSince1970: timestamp)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            return dateFormatter.string(from: date)
        }
    

    //reference taken from chatgpt: prompt -> convert timestamp to x hours, y minutes ago format in swiftui
    func formatTimeDifference(_ timestamp: Int) -> String {
        let currentDate = Date()
        let dateFromTimestamp = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateFromTimestamp, to: currentDate)
        
        if let year = components.year, year > 0 {
            return "\(year) year\(year == 1 ? "" : "s") ago"
        } else if let month = components.month, month > 0 {
            return "\(month) month\(month == 1 ? "" : "s") ago"
        } else if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: newsData[0].image))
                .resizable(resizingMode: .stretch)
                .frame(height: 200)
                .cornerRadius(10.0)
                .padding()
            
            HStack {
                Text("\(newsData[0].source) \(formatTimeDifference(newsData[0].datetime))")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Spacer()
            }
            
            HStack {
                Text(newsData[0].headline)
                    .font(.system(size: 15))
                Spacer()
            }
        }
        .onTapGesture {
            isSheetPresented = true
        }
        .sheet(isPresented: $isSheetPresented) {
            NewsPopup(data: newsData[0])
        }
//        .padding()
        
        ForEach(newsData.dropFirst()) { news in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(news.source) \(formatTimeDifference(news.datetime))")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text(news.headline)
                            .font(.system(size: 15))
                    }
                    Spacer()
                    
                    KFImage(URL(string: news.image))
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(5.0)
                        .padding()
                }
                .onTapGesture {
                    isSheetPresented = true
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                NewsPopup(data: news)
            }
//            .padding()
        }
        
    }
}

struct NewsList_Previews: PreviewProvider {
    static var previews: some View {
        let jsonData = """
        [
            {"category":"company","datetime":1713106815,"headline":"Antitrust fervor is gripping Washington and Silicon Valley. But lawsuits have been declining.","id":127004320,"image":"https://s.yimg.com/ny/api/res/1.2/PLV5yy4qC1iKChuclksF1Q--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02NzU-/https://s.yimg.com/os/creatr-uploaded-images/2022-08/ae65d230-1d6e-11ed-afe1-6c773982d44d","related":"AAPL","source":"Yahoo","summary":"Antitrust lawsuits have declined since the pandemic despite a high-profile push by Washington to limit the concentration of power in key industries.","url":"https://finnhub.io/api/news?id=163e71fe95b27c11da4171938ed7fa46ffe8aaa9d0540dd2c4bba7d15ac00d5e"},
            {"category":"company","datetime":1713105011,"headline":"Big Tech will outperform in a high interest rate environment: Wall Street pros","id":127004018,"image":"https://s.yimg.com/ny/api/res/1.2/ZSX_Y8bxFbRJkenO4F1sOw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD04MDA-/https://s.yimg.com/os/creatr-uploaded-images/2024-04/eef2bc40-f996-11ee-b79f-272b1200db6d","related":"AAPL","source":"Yahoo","summary":"Big tech was back in favor with investors last week, despite a hot inflation report guaranteeing higher for longer interest rates.","url":"https://finnhub.io/api/news?id=097e4009cbf134f97227c6eb8a90695c169edf7e20b8959a9d6bef7061cac6bd"},
            {"category":"company","datetime":1713097844,"headline":"Why Nvidia's stock sell-off matters and what people are saying about it","id":127003552,"image":"https://s.yimg.com/ny/api/res/1.2/kZfJGl3VqUmX8XcUPhIHXg--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD04ODE-/https://s.yimg.com/os/creatr-uploaded-images/2024-03/26d1cd10-e62b-11ee-9eb5-c3fc14a1b8e7","related":"AAPL","source":"Yahoo","summary":"Is it a big deal that Nvidia's stock is lagging?","url":"https://finnhub.io/api/news?id=44f0b5990a8a0b2b8c93394f5e2892ab1cafdb0f0135aa93f1cffcbd02655951"}
        ]
        """.data(using: .utf8)!
        
       
        NewsList(data: JSON(jsonData))
    }
}
