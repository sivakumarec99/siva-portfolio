//
//  AddCakeView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct AddCakeView: View {
    @State private var cakeName = ""
    @State private var price = ""
    @State private var description = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Cake Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .transition(.slide)
            
            TextField("Cake Name", text: $cakeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Price", text: $price)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                print("Cake Added Successfully")
            }) {
                Text("Add Cake")
                    .frame(width: 200, height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .scaleEffect(1.1)
                    .animation(.easeInOut(duration: 0.3))
            }
            .padding(.top, 20)
        }
        .padding()
    }
}
