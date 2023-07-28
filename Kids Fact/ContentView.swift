//
//  ContentView.swift
//  Kids Fact
//
//  Created by Abhay's Mac on 27/07/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var managerObj = ApiManager()
    @State private var isAnswer = false
    @State private var isPunchline = false
    @State private var count: Int = 0
    @State private var indexCount: Int = 0
    @State private var animalName = ""
    @State private var isSlogan = false
    @State private var lastIndex: Int? = nil
    
    let functions: [(ApiManager) -> Void] = [
        { object in
            object.loadRiddle()
        },
        { object in
            object.loadJokeAndPunchline()
        },
        { object in
            object.loadAnimalSlogn(animalName: "")
        }
    ]
    
    var body: some View {
        VStack {
            VStack {
                if indexCount == 0 {
                    if let riddle = managerObj.riddleObj {
                        Text(riddle.title)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 25, weight: .semibold, design: .rounded))
                            .padding(.vertical, 5)
                        
                        Text(riddle.question)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        if isAnswer {
                            Text("- \(riddle.answer)")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .padding(.vertical, 5)
                        }
                    }
                    
                } else if indexCount == 1 {
                    if !managerObj.joke.isEmpty {
                        if let joke = managerObj.joke {
                            Text(joke)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            if isPunchline {
                                if let punchline = managerObj.punchLine {
                                    Text("- \(punchline)")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    
                } else if indexCount == 2 {
                    if managerObj.isInvalidUrl {
                        Text("Something went wrong!!")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                    } else {
                        
                        if isSlogan {
                            if !managerObj.slogan.isEmpty {
                                if let slogan = managerObj.slogan {
                                    Text(slogan)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .multilineTextAlignment(.center)
                                }
                                
                            } else {
                                Text(managerObj.errorOnSlogan)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                            }
                            
                            
                        } else {
                            
                            TextField("Enter animal name", text: $animalName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .padding(10)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                        }
                    }
                }
            }
            
            
            HStack {
                Button {
                    withAnimation {
                        if indexCount == 0 {
                            isAnswer.toggle()
                            if !isAnswer {
                                managerObj.loadRiddle()
                            }
                            
                        } else if indexCount == 1 {
                            if isPunchline {
                                managerObj.loadJokeAndPunchline()
                                isPunchline = false
                            } else {
                                isPunchline = true
                            }
                            
                        } else if indexCount == 2 {
                            if !animalName.isEmpty {
                                managerObj.isInvalidUrl = false
                                isSlogan.toggle()
                                managerObj.loadAnimalSlogn(animalName: animalName)
                                animalName = ""
                                UIApplication.shared.endEditing()
                                
                            } else {
                                isSlogan = false
                            }
                        }
                    }
                    count += 1
                    if count == 2 {
                        count = 0
                        getRandomFunction()
                    }
                    
                } label: {
                    if indexCount == 0 {
                        if managerObj.riddleObj == nil {
                            Text("Loading...")
                            
                        } else {
                            Text(isAnswer ? "Tap Me!" : "Show Answer")
                        }
                        
                    } else if indexCount == 1 {
                        if managerObj.joke.isEmpty {
                            Text("Loading...")
                            
                        } else {
                            Text(isPunchline ? "Tap Me!" : "Show Punchline")
                        }
                        
                    } else if indexCount == 2 {
                        if managerObj.slogan.isEmpty && isSlogan {
                            if !managerObj.errorOnSlogan.isEmpty {
                                Text("Tap Me!")
                            }
                            
                            if managerObj.isInvalidUrl {
                                Text("Tap Me!")
                            }
                            
                        } else {
                            Text(isSlogan ? "Tap Me!" : "Animal Slogan!")
                        }
                    }
                }
                .font(.system(size: 15, weight: .black, design: .rounded))
                .buttonStyle(CartoonButton())
                .frame(width: 200, height: 60)
                .foregroundColor(.white)
                .disabled(managerObj.isDisable)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 10)
        }
        .padding()
        .onAppear {
            getRandomFunction()
        }
    }
    
    func getRandomFunction() {
        let randomIndex = Int.random(in: 0..<functions.count)
        functions[randomIndex](managerObj)
        indexCount = randomIndex
        print("indexCount :: ",indexCount)
        managerObj.buttonTitle = "Loading..."
        if indexCount == 0 && managerObj.riddleObj != nil {
            managerObj.buttonTitle = ""
            managerObj.buttonTitle = "Show Answer!"
            
        } else if indexCount == 1 && !managerObj.joke.isEmpty {
            managerObj.buttonTitle = ""
            managerObj.buttonTitle = "Punchline!"
            
        } else if indexCount == 2 && !managerObj.slogan.isEmpty {
            managerObj.buttonTitle = ""
            managerObj.buttonTitle = "Animal Slogan!"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
