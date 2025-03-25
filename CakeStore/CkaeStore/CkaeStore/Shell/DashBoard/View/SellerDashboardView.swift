//
//  SellerDashboardView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import SwiftUI

struct SellerDashboardView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        TabIconView(icon: "house.fill", title: "Home", isSelected: selectedTab == 0)
                    }
                    .tag(0)

                OrdersView()
                    .tabItem {
                        TabIconView(icon: "list.bullet.rectangle", title: "Orders", isSelected: selectedTab == 1)
                    }
                    .tag(1)

                AddCakeView()
                    .tabItem {
                        LargeAddButton(isSelected: selectedTab == 2)
                    }
                    .tag(2)

                NotificationsView()
                    .tabItem {
                        TabIconView(icon: "bell.fill", title: "Notifications", isSelected: selectedTab == 3)
                    }
                    .tag(3)

                ProfileView()
                    .tabItem {
                        TabIconView(icon: "person.fill", title: "Profile", isSelected: selectedTab == 4)
                    }
                    .tag(4)
            }
            .accentColor(.orange) // ✅ Custom Tab Bar Tint Color
            .onAppear {
                UITabBar.appearance().isTranslucent = false
            }
        }
    }
}

struct TabIconView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding()
                .background(Circle().fill(isSelected ? Color.orange : Color.gray.opacity(0.2)))
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .shadow(radius: isSelected ? 4 : 0)

            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .primary : .gray)
        }
        .opacity(isSelected ? 1.0 : 0.6) // ✅ Fade Effect for Unselected Tabs
    }
}

struct LargeAddButton: View {
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: isSelected ? 75 : 60, height: isSelected ? 75 : 60) // ✅ Bigger When Selected
                    .shadow(radius: isSelected ? 6 : 3)

                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            .animation(.easeInOut(duration: 0.2), value: isSelected)

            Text("Add Cake")
                .font(.caption)
                .foregroundColor(isSelected ? .primary : .gray)
                .opacity(isSelected ? 1.0 : 0.6) // ✅ Fade Effect for Unselected
        }
    }
}
