//
//  OrdersView.swift
//  CkaeStore
//
//  Created by JIDTP1408 on 25/03/25.
//

import Foundation
import SwiftUI

struct OrdersView: View {
    let orders = [
        "Order #1023 - Chocolate Cake",
        "Order #1024 - Red Velvet Cake",
        "Order #1025 - Vanilla Cupcake",
        "Order #1026 - Blueberry Muffin"
    ]

    var body: some View {
        VStack {
            Text("Your Orders")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            List(orders, id: \.self) { order in
                Text(order)
                    .font(.headline)
            }
        }
    }
}
