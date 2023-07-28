import Foundation
import SwiftUI

struct Riddle: Decodable {
    var title: String
    var question: String
    var answer: String
}

final class ApiManager: ObservableObject {
    
    @Published var riddleObj: Riddle?
    @Published var joke: String = ""
    @Published var punchLine: String = ""
    @Published var slogan: String = ""
    @Published var isDisable: Bool = false
    @Published var errorOnSlogan: String = ""
    @Published var buttonTitle: String = ""
    @Published var isInvalidUrl: Bool = false
    
    func loadRiddle() {
        riddleObj = nil
        buttonTitle = "Loading..."
        
        let url = URL(string: "https://riddles-by-api-ninjas.p.rapidapi.com/v1/riddles")!
        var request = URLRequest(url: url)
        request.addValue("b99494fb66msh5d68b6d3db5a825p1822b0jsn91005030092f", forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("riddles-by-api-ninjas.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.httpMethod = "GET"
        DispatchQueue.main.async {
            self.isDisable = true
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error --> ",error.localizedDescription)
            }
            
            if let data = data {
                do {
                    let jsonRiddle = try JSONDecoder().decode([Riddle].self, from: data)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [self] in
                        withAnimation {
                            riddleObj = jsonRiddle.first
                            isDisable = false
                            buttonTitle = "Show Answer!"
                        }
                    })
                    
                } catch {
                    print("Error --> ",error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    func loadJokeAndPunchline() {
        joke = ""
        punchLine = ""
        buttonTitle = "Loading..."
        
        let headers = [
            "X-RapidAPI-Key": "b99494fb66msh5d68b6d3db5a825p1822b0jsn91005030092f",
            "X-RapidAPI-Host": "dad-jokes.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://dad-jokes.p.rapidapi.com/random/joke/png")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        DispatchQueue.main.async {
            self.isDisable = true
        }
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [self] data, respose, error in
            if let error = error {
                print("Error --> ",error.localizedDescription)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any]
                    if let jsonJoke = json?["body"] as? [String : Any],
                       let joke_ = jsonJoke["setup"] as? String,
                       let jsonPunchLine = jsonJoke["punchline"] as? String {
                        DispatchQueue.main.async { [self] in
                            withAnimation {
                                joke = joke_
                                punchLine = jsonPunchLine
                                isDisable = false
                                buttonTitle = "Show Punchline!"
                            }
                        }
                    }
                    
                } catch {
                    print("Error --> ",error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    func loadAnimalSlogn(animalName: String) {
        isInvalidUrl = false
        buttonTitle = ""
        slogan = ""
        buttonTitle = "Animal Slogan!"
        errorOnSlogan = ""
        
        let headers = [
            "X-RapidAPI-Key": "b99494fb66msh5d68b6d3db5a825p1822b0jsn91005030092f",
            "X-RapidAPI-Host": "animals-by-api-ninjas.p.rapidapi.com"
        ]
        
        let urlStr = "https://animals-by-api-ninjas.p.rapidapi.com/v1/animals?name=\(animalName)"
        guard let url = URL(string: urlStr) else {
            print("Invalid URL")
            isInvalidUrl = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        buttonTitle = "Loading..."
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error --> ",error.localizedDescription)
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        if let jsonArray = json as? [[String: Any]], let firstAnimal = jsonArray.first {
                            if let characteristics = firstAnimal["characteristics"] as? [String: Any],
                               let slogan_ = characteristics["slogan"] as? String,
                               let animalName = firstAnimal["name"] as? String {
                                DispatchQueue.main.async { [self] in
                                    withAnimation {
                                        slogan = "This \(animalName) is \(slogan_)"
                                        isDisable = false
                                        buttonTitle = "Tap Me!"
                                    }
                                }
                            } else {
                                print("No slogan found for \(animalName)")
                                DispatchQueue.main.async {
                                    self.errorOnSlogan = "No slogan found for \(animalName)"
                                }
                            }
                        } else {
                            print("No data found for \(animalName)")
                            self.errorOnSlogan = "No data found for \(animalName)"
                        }
                                            
                    } catch {
                        print("Error --> ",error.localizedDescription)
                    }
                }
            }
        }
        task.resume()
    }
}
