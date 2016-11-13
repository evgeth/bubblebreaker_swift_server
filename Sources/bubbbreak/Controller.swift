/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Kitura
import SwiftyJSON
import LoggerAPI
import Foundation
import CloudFoundryEnv

public class Controller {

  let router: Router
  let appEnv: AppEnv

  var port: Int {
    get { return appEnv.port }
  }

  var url: String {
    get { return appEnv.url }
  }

  init() throws {
    appEnv = try CloudFoundryEnv.getAppEnv()

    // All web apps need a Router instance to define routes
    router = Router()

    // Serve static content from "public"
    router.all("/", middleware: StaticFileServer())

    // API endpoint
    router.get("/matchingArticle", handler: matchingArticle)

  }

  public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("POST - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    if let name = try request.readString() {
      try response.status(.OK).send("Hello \(name), from Kitura-Starter!").end()
    } else {
      try response.status(.OK).send(String(describing: request.queryParameters)).end()
    }
  }

  public func matchingArticle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /json route handler...")
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    
    
    var jsonResponse = JSON([:])
    if let urlString = request.queryParameters["url"], let _ = NSURL(string: urlString) {
      
      let jsonArticle = self.article(url: "http://www.foxnews.com/politics/2016/11/12/clinton-tells-fundraisers-fbi-comey-letter-sank-presidential-bid.html",
                                     title: "Clinton tells fundraisers FBI Comey letter sank presidential bid",
                                     author: "Serafin Gomez",
                                     sourceName: "FoxNews",
                                     tone: "political, argessive",
                                     summary: "summary")
      
      let jsonMatchingArticle1 = self.article(url: "http://www.breitbart.com/news/clinton-campaign-blames-james-comey-for-loss-to-donald-trump/",
                                             title: "Clinton campaign blames James Comey for loss to Donald Trump",
                                             author: "UPI",
                                             sourceName: "Breitbart",
                                             tone: "political, argessive",
                                             summary: "summary")
      
      let jsonMatchingArticle2 = self.article(url: "http://www.huffingtonpost.com/entry/jim-comey-fbi-hillary-clinton_us_581b5051e4b01a82df652541",
                                              title: "James Comey Adviser Blames Reporters For Blowing FBI Director’s Clinton Letter Out Of Proportion",
                                              author: "Ryan J. Reilly",
                                              sourceName: "The Huffington Post",
                                              tone: "political, argessive",
                                              summary: "summary")
      
      jsonResponse["article"] = jsonArticle
      jsonResponse["matchingArticle1"] = jsonMatchingArticle1
      jsonResponse["matchingArticle2"] = jsonMatchingArticle2
    } else {
      jsonResponse["error"].stringValue = "Incorrect URL"
    }
    try response.status(.OK).send(json: jsonResponse).end()
  }
  
  public func article(url: String, title: String, author: String, sourceName: String, tone: String, summary: String) -> JSON {
    var jsonArticle = JSON([:])
    jsonArticle["url"].stringValue = url
    jsonArticle["articleTitle"].stringValue = title
    jsonArticle["author"].stringValue = author
    jsonArticle["sourceName"].stringValue = sourceName
    jsonArticle["articleTone"].stringValue = tone
    jsonArticle["summary"].stringValue = summary
    return jsonArticle
  }

}
