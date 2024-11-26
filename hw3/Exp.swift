//
//  Untitled.swift
//  hw3
//
//  Created by user13 on 2024/11/19.
//
import Observation
import SwiftUI

@Observable
class PlayerExp {
    var hp: Int = 50 {
        didSet {
            if hp < 0 { hp = 0 }
            if hp > maxHP { hp = maxHP }
        }
    }
    let maxHP: Int = 100
}



struct HPBarView: View {
    @Environment(PlayerExp.self) var playerexp

    var body: some View {
        VStack(spacing: 5) {
            Text("EXP: \(playerexp.hp)/\(playerexp.maxHP)")
                .bold()
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 10)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(10)
                
                Rectangle()
                    .frame(width: CGFloat(playerexp.hp) / CGFloat(playerexp.maxHP) * 300, height: 10)
                    .foregroundColor(.pink)
                    .cornerRadius(10)
            }
            .frame(width: 150)
            .animation(.easeInOut, value: playerexp.hp)
            
        }
        .padding()
    }
}
