//
//  ContentView.swift
//  hw3
//
//  Created by user13 on 2024/11/19.
//

import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "soundEffect", withExtension: "mp4") else {
            print("Sound file not found!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
}

// 擴展 Color 來支持十六進制顏色
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}



struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showSheet = false
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                ZStack{
                    Image("board")
                        .resizable() // 讓圖片可以調整大小
                        .frame(width: 350, height: 200) // 設定圖片的寬度和高度
                        .scaledToFit() // 保持圖片比例
                    
                    VStack {
                        // 試驗說明
                        Button(action: {
                            showSheet.toggle()
                        }) {
                            Text("試驗說明")
                                .font(.custom("Hiragino Mincho ProN", size: 25)) // 自定義日文字體
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .padding(15)
                                .background(
                                    ZStack {
                                        // 漸變背景
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.7),
                                                Color.purple.opacity(0.4)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .cornerRadius(12)
                                        
                                        // 高光層
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.8),
                                                        Color.purple.opacity(0.8)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                            .blur(radius: 1)
                                    }
                                )
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                        .fullScreenCover(isPresented: $showSheet) {
                            ZStack {
                                    Color(hex: "dcc3d9") // 填滿背景
                                        .ignoresSafeArea() // 無視安全區域，填滿整個螢幕

                                    VStack {
                                        Text("ハンター×抽鬼牌遊戲")
                                            .font(.custom("Hiragino Mincho ProN", size: 40)) // 自定義日文字體
                                            .fontWeight(.bold) // 粗體效果
                                            .foregroundColor(.red) // 紅色文字
                                            .shadow(color: .black.opacity(0.8), radius: 5, x: 3, y: 3) // 增加陰影
                                      
                                            VStack(alignment: .leading, spacing: 15) {
                                                Text("遊戲玩法：")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                Text("1. 每位玩家隨機分配 8 張牌，其中可能包含 1 或 2 張鬼牌。")
                                                Text("2. 抽到以下圖示為鬼牌 每回合會有２張鬼牌")
                                                Image("joker one")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 230)
                                                    .clipped()
                                                Text("3. 當玩家抽到鬼牌時EXP值會減少50 當電腦抽到鬼牌時玩家會增加EXP值25")
                                                Text("4. EXP值100時玩家獲勝 0時玩家失敗(EXP值在一開始為50)")
                                                Image("exp")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 60)
                                                    .clipped()
                                            }
                                            .padding()
                                            .cornerRadius(8)
                                        
                                        Spacer() // 將按鈕推到視圖底部
                                        Button("返回") {
                                            showSheet = false
                                        }
                                        .font(.custom("Hiragino Mincho ProN", size: 15)) // 自定義日文字體
                                        .multilineTextAlignment(.leading)
                                        .padding(15)
                                        .background(
                                            ZStack {
                                                // 漸變背景
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.7),
                                                        Color.purple.opacity(0.4)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                .cornerRadius(12)
                                                
                                                // 高光層
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color.white.opacity(0.8),
                                                                Color.purple.opacity(0.8)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 2
                                                    )
                                                    .blur(radius: 1)
                                            }
                                        )
                                        .font(.title3)
                                        .foregroundColor(.black)
                                    }
                                    
                                }
                            
                        }
                        // NavigationLink 包裹按鈕樣式
                        
                        NavigationLink(destination: Game()) {
                            Text("試驗開始")
                                .font(.custom("Hiragino Mincho ProN", size: 25)) // 自定義日文字體
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .padding(15)
                                .background(
                                    ZStack {
                                        // 漸變背景
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.7),
                                                Color.purple.opacity(0.4)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .cornerRadius(12)
                                        
                                        // 高光層
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.white.opacity(0.8),
                                                        Color.purple.opacity(0.6)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                            .blur(radius: 1)
                                    }
                                )
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            audioManager.playSound() // 播放音效
                        })

                    }
                }
                .padding(.top, 120.0)
            }
            .navigationBarHidden(true)  // 隐藏导航栏
            
        }
    }
}



#Preview {
    ContentView()
}


