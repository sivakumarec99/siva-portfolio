//
//  AlaremBackgroundPicker.swift
//  CheckList
//
//  Created by JIDTP1408 on 12/03/25.
//

import Foundation
import SwiftUI

struct AlarmBackgroundPickerView: View {
    @Binding var selectedBackground: String
    private let backgroundOptions = ["defaultImage", "sunrise", "moon", "ocean", "forest"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Background")
                .font(.headline)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(backgroundOptions, id: \.self) { bg in
                        Image(bg)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedBackground == bg ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedBackground = bg
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
    }
}
