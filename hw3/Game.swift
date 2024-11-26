//
//  ContentView.swift
//  hw3
//
//  Created by user13 on 2024/11/19.
//

import SwiftUI
import AVFoundation

struct Game: View {
    
    @State  var players = dealCardsToPlayers()
    @State  var message = ""
    @State  var isGameOver = false
    @State  var isPlayerTurn = true // 用來控制玩家與電腦的回合
    @State  var currentPlayerIndex = 0 // 追蹤當前回合的玩家
    @State  var drawnCard: Card?  // 抽取的卡牌
    @State  var showDrawnCard = false // 控制是否顯示抽取的卡牌
    
    @State  var showSheetWin = false // 贏時跳出
    @State  var showSheetLose = false // 輸時跳出
    @State  var WinMessage = "" // 贏顯示的訊息
    @State  var LoseMessage = "" // 輸顯示的訊息
    
    @State private var flipped = false // 控制卡牌是否翻面
    @State private var showText = false // 控制文字顯示狀態
    
    @State private var shake = false // 控制晃動的狀態
    
    private var playerexp = PlayerExp()
    var body: some View {
        GeometryReader{ geo in
            ZStack {
                // 背景圖片，並設定透明度
                Image("map")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                // 加入深色遮罩層
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.3) // 透明的黑色遮罩，讓背景變暗
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                VStack{
                    // 顯示電腦的手牌
                    ForEach(players) { player in
                        if player.id == players[0].id { // 顯示電腦一的卡牌
                            Text("電腦1抽玩家卡牌")
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: -20)]) {
                                ForEach(player.cards) { card in
                                    CardView(card: card, shouldFlip: false) // 顯示反面
                                        .onTapGesture {
                                            if isPlayerTurn {
                                                playerTurn(selectedCard: card)
                                            }
                                        }
                                    
                                }
                            }
                            .frame(height: geo.size.height / 6)
                        }


                        
                        
                        else if player.id == players[1].id { // 顯示電腦二的卡牌
                            Text("電腦2抽電腦1卡牌")
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: -20)]) {
                                ForEach(player.cards) { card in
                                    CardView(card: card, shouldFlip: false) // 顯示反面
                                        .offset(y: card.selected ? -30 : 0) // 如果選擇，卡牌上移
                                        .onTapGesture {
                                            // 點擊卡牌時選擇或取消選擇
                                            if let cardIndex = players[1].cards.firstIndex(where: { $0.id == card.id }) {
                                                // 先更新選擇狀態
                                                players[1].cards[cardIndex].selected.toggle()
                                                // 這裡確保選擇狀態更新後再執行玩家回合邏輯
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                    playerTurn(selectedCard: card)
                                                }
                                            }
                                        }
                                }
                            }
                            .frame(height: geo.size.height / 7)
                        }
                    }
                
                    // 動態訊息框
                    if !message.isEmpty {
                        Text(message)
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
                            .font(.headline)
                            .foregroundColor(.black)
                            .transition(.opacity.combined(with: .scale)) // 添加淡入淡出 + 縮放動畫
                            .animation(.easeInOut(duration: 0.3), value: message) // 動畫效果
                    }
      
                    // 我的手牌
                    VStack{
                        Text("玩家抽電腦2卡牌")

                            
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 115), spacing: -70)]) {
                            ForEach(players.last?.cards ?? []) { card in
                                CardView(card: card, shouldFlip: true)
                                    .padding()
                                    .onTapGesture {
                                        if isPlayerTurn {
                                            playerTurn(selectedCard: card)
                                        }
                                    }
                            }
                        }
                    }
 
                    // 電腦抽中鬼牌時顯示的Sheet
                        .sheet(isPresented: $showSheetWin) {
                            VStack {
                            ZStack {
                                Image("win")
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.8)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .clipped()
                                Image("hounter")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 320, height: 450)
                                    .clipShape(.rect(cornerRadius: 20))
                                    .shadow(
                                        color: .black,
                                        radius: flipped ? 20 : 10,
                                        y: flipped ? 20 : 10
                                    )
                                    .rotation3DEffect(
                                        .degrees(flipped ? 360 : 0),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            flipped.toggle()
                                            showText.toggle() // 顯示文字
                                        }
                                    }
                                
                                // 顯示文字
                                if showText {
                                    Text("恭喜成爲一名獵人")
                                        .font(.custom("Hiragino Mincho ProN", size: 40)) // 自定義日文字體
                                        .fontWeight(.bold) // 粗體效果
                                        .foregroundColor(.red) // 紅色文字
                                        .shadow(color: .black.opacity(0.8), radius: 5, x: 3, y: 3) // 陰影效果
                                        .transition(.scale) // 文字顯示動畫
                                        .padding(.top, 20) // 與圖片保持一定距離
                                }
                                
                            }
                            .ignoresSafeArea() // 忽略安全區域
                        }
                    }
                    
                    // 玩家抽中鬼牌時顯示的Sheet
                    .sheet(isPresented: $showSheetLose) {
                        VStack {
                            ZStack {
                                Image("lose")
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.8)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .clipped()
                                
                                Text("明年再來挑戰獵人試驗吧！")
                                    .font(.custom("Hiragino Mincho ProN", size: 30)) // 自定義日文字體
                                    .fontWeight(.bold) // 粗體效果
                                    .foregroundColor(.red) // 紅色文字
                                    .shadow(color: .black.opacity(0.8), radius: 5, x: 3, y: 3) // 增加陰影
                                    .offset(x: shake ? -10 : 10) // 根據狀態偏移位置
                                    .animation(
                                        Animation.easeInOut(duration: 0.1)
                                            .repeatForever(autoreverses: true), // 重複並反向
                                        value: shake
                                    )
                                    .onAppear {
                                        // 當視圖出現時啟動晃動效果
                                        shake = true
                                    }
                                
                                
                            }
                            
                        }
                        .ignoresSafeArea() // 忽略安全區域
                    }
                    //重新開始扭
                    Button(action: {
                        restartGame() // 當按鈕被點擊時，呼叫重置遊戲的函數
                    }) {
                        Text("重新試驗")
                            .font(.custom("Hiragino Mincho ProN", size: 20)) // 自定義日文字體
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
                            .font(.headline)
                            .foregroundColor(.black)
                    }

                }

                VStack {
                    // 將 HPBarView 添加進來
                    HPBarView()
                        .padding(.top, 750.0)
                        .environment(playerexp) // 傳遞玩家模型給 HPBarView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
    }
    
    
    
    
    // 玩家回合 - 玩家抽取電腦 2 的卡牌
    func playerTurn(selectedCard: Card) {
        guard !isGameOver else { return } // 如果遊戲已結束，停止動作
        guard let index = players[1].cards.firstIndex(where: { $0.id == selectedCard.id }) else { return }
        let card = players[1].cards.remove(at: index) // 從電腦的手牌中移除選中的卡牌
        drawnCard = card // 暫存選中的卡牌
        showDrawnCard = true // 顯示卡牌
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            players[2].cards.append(card)
            checkForJoker(card, player: "玩家") // 檢查是否抽到鬼牌

            // 玩家抽中鬼牌扣血
            if card.suit == .joker {
                playerexp.hp -= 50
                checkGameOver() // 檢查遊戲是否結束
            }
            // 如果玩家抽中鬼牌，顯示Sheet
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                if card.suit == .joker {
                    LoseMessage = "你抽到鬼牌！遊戲結束！"
                    showSheetWin = true
                }
            }*/
            guard !isGameOver else { return }
            isPlayerTurn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                computerTurn() // 自動開始電腦回合
            }
        }
        
    }

    // 電腦 2 回合 - 抽取電腦 1 的卡牌
    func computerTurn() {
        guard !isGameOver else { return }
        if let drawnCard = drawCard(from: &players[0]) { // 抽取電腦 1 的卡牌
            players[1].cards.append(drawnCard) // 加入到電腦 2 的手牌
            checkForJoker(drawnCard, player: "電腦 2") // 檢查是否抽到鬼牌
            // 電腦抽中鬼牌回血
            if drawnCard.suit == .joker {
                playerexp.hp += 25
                checkGameOver() // 檢查遊戲是否結束
            }
            // 電腦抽中鬼牌，顯示Sheet
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                if drawnCard.suit == .joker {
                    WinMessage = "獲勝！"
                    showSheetLose = true
                }
            }*/
            guard !isGameOver else { return }
            // 延遲進入電腦 1 的回合
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                computer1Turn()
            }
        }
        // 在玩家回合結束後，恢復所有卡片的選擇狀態為 false
         for index in players[1].cards.indices {
             players[1].cards[index].selected = false
         }
    }

    // 電腦 1 回合 - 抽取玩家的卡牌
    func computer1Turn() {
        guard !isGameOver else { return }
        if let drawnCard = drawCard(from: &players[2]) { // 抽取玩家的卡牌
            players[0].cards.append(drawnCard) // 加入到電腦 1 的手牌
            // 確保從玩家手牌中移除這張卡牌
            if let index = players[2].cards.firstIndex(where: { $0.id == drawnCard.id }) {
                players[2].cards.remove(at: index) // 刪除玩家手牌中的這張卡牌
            }
            checkForJoker(drawnCard, player: "電腦 1") // 檢查是否抽到鬼牌
            // 電腦抽中鬼牌回血
            if drawnCard.suit == .joker {
                playerexp.hp += 25
                checkGameOver() // 檢查遊戲是否結束
            }
            // 電腦抽中鬼牌，顯示Sheet
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                if drawnCard.suit == .joker {
                    WinMessage = "獲勝！"
                    showSheetLose = true
                }
            }*/
            guard !isGameOver else { return }
            
            // 結束電腦 1 回合，切換到玩家回合
            currentPlayerIndex = 2
            // 延遲進入玩家的回合
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPlayerTurn = true
            }
        }
    }

    // 檢查是否抽到鬼牌
    func checkForJoker(_ card: Card, player: String) {
        if card.suit == .joker {
            message = "\(player) 抽到鬼牌！"
            // 清空訊息 2 秒後隱藏
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                message = ""
            }
        }
    }
    
    // 檢查遊戲是否結束
    func checkGameOver() {
        if playerexp.hp <= 0 {
            isGameOver = true
            message = "遊戲結束！玩家血量為 0！"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSheetLose = true // 顯示勝利畫面
            }
            // 顯示結束畫面或進行其他處理
        } else if playerexp.hp >= 100 {
            isGameOver = true
            message = "遊戲結束！玩家血量達到 100！"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSheetWin = true // 顯示失敗畫面
            }
            // 顯示結束畫面或進行其他處理
        }
    }
    
    // 重置遊戲
    func restartGame() {
        players = dealCardsToPlayers()
        message = ""
        isGameOver = false
        isPlayerTurn = true
        // 將血量重置為 0
        playerexp.hp = 50
    }
    
    // 從某位玩家的手牌中隨機抽取一張卡牌
    func drawCard(from player: inout Player) -> Card? {
        guard !player.cards.isEmpty else { return nil }
        return player.cards.remove(at: Int.random(in: 0..<player.cards.count))
    }

}

struct CardView: View {
    var card: Card
    var shouldFlip: Bool // 新增條件：是否翻轉卡牌
    
    
    var body: some View {
        ZStack {
            if shouldFlip {
                // 顯示卡牌正面
                Image(card.filename)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)

            } else {
                // 顯示卡牌反面
                Image("cardBack")
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)

            }
        }
    }
}
 

#Preview {
    Game()
}

