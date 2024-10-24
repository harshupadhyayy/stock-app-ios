import SwiftUI

struct NewsPopup: View {
    let data: News
    @Environment(\.presentationMode) var presentationMode
    
    func formatTimestamp(_ timestamp: Int) -> String {
        let timestampTimeInterval = TimeInterval(timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        let date = Date(timeIntervalSince1970: timestampTimeInterval)
        return dateFormatter.string(from: date)
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
            
            
            HStack {
                VStack(alignment: .leading) {
                    Text(data.related)
                        .font(.title)
                        .bold()
                    Text(formatTimestamp(data.datetime))
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
            .padding(.top)
            
            Divider()
            
            Text(data.headline)
                .font(.title2)
            
            
            Text(data.summary)
            HStack {
                Text("For more details click")
                    .foregroundStyle(.gray)
                Link("here",
                     destination: URL(string: data.url)!)
            }
            .font(.system(size: 16))
            
            HStack {
                Button(action: {
                    //reffered from: https://stackoverflow.com/questions/34809342/swift-share-text-through-twitter
                    let tweetText = data.headline
                    let tweetUrl = data.url

                    let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"

                  
                    let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

                
                    let url = URL(string: escapedShareString)

             
                    UIApplication.shared.open(url!)
                }) {
                    Image("twitter")
                        .resizable()
                        .frame(width: 60, height: 60)

                }
                                
                Button(action: {
                    let newsUrl = data.url
                    let postContent = "Check out this news: \(newsUrl)"
                    let encodedPostContent = postContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let fbUrl = URL(string: "fb://post?text=\(encodedPostContent)")!

                    if UIApplication.shared.canOpenURL(fbUrl) {
                        UIApplication.shared.open(fbUrl)
                    } else {
                        let webUrl = URL(string: "https://www.facebook.com/sharer/sharer.php?u=\(newsUrl)")!
                        UIApplication.shared.open(webUrl)
                    }
                }) {
                    Image("facebook")
                        .resizable()
                        .frame(width: 50, height: 50)
                }

            }
            
            
            Spacer()
        }
        .padding()
    }
}

struct NewsPopup_Previews: PreviewProvider {
    static var previews: some View {
        let dummyNews = News(json: ["id": 1, "category": "Finance", "datetime": 1618561900, "headline": "Dummy Headline", "image": "dummy_image", "related": "Related dummy", "source": "Dummy Source", "summary": "Dummy summary", "url": "https://dummyurl.com"])
        return NewsPopup(data: dummyNews)
    }
}

