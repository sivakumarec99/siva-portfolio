//
//  HomeView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            // ✅ Top Navigation Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.black)
                }
                Spacer()
                
                VStack {
                    Text("Current Location")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("New York, USA")
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .padding()
            
            // ✅ Orders Summary Section
            HStack {
                OrderSummaryBox(title: "Running Orders", count: 5, color: .blue)
                OrderSummaryBox(title: "Order Requests", count: 2, color: .orange)
            }
            .padding(.horizontal)
            
            // ✅ Revenue Chart
            RevenueGraphView()
            
            // ✅ Reviews Section
            ReviewSummaryView()
            
            // ✅ Popular Items ScrollView
            PopularItemsView()
        }
        .padding(.top)
    }
}


struct OrderSummaryBox: View {
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 160, height: 100)
        .background(color)
        .cornerRadius(12)
    }
}


struct RevenueGraphView: View {
    @State private var selectedFilter = "Daily"
    let filters = ["Daily", "Monthly", "Yearly"]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total Revenue")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filters, id: \.self) { filter in
                        Text(filter).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
            
            // Dummy Graph View
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 150)
                .cornerRadius(10)
                .overlay(Text("Revenue Chart").foregroundColor(.black))
            
            HStack {
                Spacer()
                Button("Detailed View") {}
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct ReviewSummaryView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Reviews")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                Button("See All") {}
                    .foregroundColor(.blue)
            }
            
            HStack {
                Text("⭐ 4.8")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading) {
                    Text("Total Reviews: 120")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct PopularItemsView: View {
    let items = [
        "Cake 🍰", "Cookies 🍪", "Brownies 🍫", "Cupcakes 🧁", "Muffins 🥧"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Popular Items This Week")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("View All") {}
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(width: 100, height: 100)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange, lineWidth: 1))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}
