//
//  CartoonButton.swift
//  Kids Fact
//
//  Created by Abhay's Mac on 27/07/23.
//

import SwiftUI

struct CartoonButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            
            let offset: CGFloat = 5.0
            Image("bg")
                .resizable()
                .offset(y: offset)
            
            Image("cartoonbtn1")
                .resizable()
                .offset(y: configuration.isPressed ? offset : 0)
            
            configuration.label
                .offset(y: configuration.isPressed ? offset : 0)
        }
    }
}

struct CartoonButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Button") {
            
        }
        .foregroundColor(.white)
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .frame(width: 120, height: 50)
        .buttonStyle(CartoonButton())
    }
}
