//
//  DataService.swift
//  DataSourcePrefetching
//
//  Created by Ashraf Uddin on 16/11/21.
//

import Foundation
class DataService {
    let APIkey = "38e61227f85671163c275f9bd95a8803"
    static let shared = DataService()
    private init() {}
    fileprivate var tasks = [URLSessionDataTask]()
    
    
    func getRequest(with query: String) -> URLRequest {

        var request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(APIkey)&query=\(query)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0) as URLRequest
        request.httpMethod = "GET"
        return request
    }
    func getMovies(with query: String, completionHandler: @escaping (MovieModel?, Error?) -> Void) {
        
        let request = getRequest(with: query)
        //guard tasks.firstIndex(where: { $0.originalRequest == request }) == nil else { return }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let movieModel = try decoder.decode(MovieModel.self, from: data)
                completionHandler(movieModel, nil)
            }catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
        tasks.append(dataTask)
    }
    
    func cancelRequest(with query: String) {
        let request = getRequest(with: query)
        guard let index = tasks.firstIndex(where: { $0.originalRequest == request }) else {
               return
        }
        
        let task = tasks[index]
        task.cancel()
        tasks.remove(at: index)
    }
}

 
struct MovieModel: Codable {
    var page: Int?
    var results: [Movie]?
}

struct Movie: Codable {
    var id: Int?
    var poster_path: String?
    
    var fullPosterPath: String? {
        guard let path = poster_path else { return nil}
        return  "https://image.tmdb.org/t/p/w185/\(path)"
    }
}
