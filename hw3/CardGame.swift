//
//  Untitled.swift
//  hw3
//
//  Created by user13 on 2024/11/19.
//
import Foundation

enum Rank : CaseIterable{
    case one, two, three, four, five, six, seven, eight, nine, ten, Jack, Queen, King
}
enum Suit : CaseIterable{
    case diamond, love, plum, spade, joker
}

struct Card: Identifiable, Hashable{
    var rank: Rank
    var suit: Suit
    var filename: String{
        return "\(suit) \(rank)"
    }
    var isFlipped: Bool = false // 新增翻轉
    var selected: Bool = false // 新增屬性來標記卡牌是否被選擇
    
    var id = UUID()
}

typealias Stack = [Card]

struct Player: Identifiable{
    var cards: [Card] = []
    var playerIsme = false
    var id = UUID()
}

// 生成所有卡片並加入鬼牌
func generateDeck() -> [Card] {
    var deck = [Card]()
    for suit in Suit.allCases where suit != .joker {
        for rank in Rank.allCases {
            deck.append(Card(rank: rank, suit: suit))
        }
    }
    // 添加鬼牌
    deck.append(Card(rank: .one, suit: .joker)) // 鬼牌1
    deck.append(Card(rank: .one, suit: .joker)) // 鬼牌2
    return deck.shuffled() //打亂
}

// 將卡片隨機分配給 3 位玩家，每人 8 張牌，並隨機給其中一位玩家鬼牌
func dealCardsToPlayers() -> [Player] {
    let cardsPerPlayer = 3 // 每位玩家 8 張卡牌
    let playerCount = 3    // 玩家數量
    var deck = generateDeck()
    var players: [Player] = []

    // 移除兩張鬼牌並保存
    var jokerCards: [Card] = []
    jokerCards.append(contentsOf: deck.filter { $0.suit == .joker })
    deck.removeAll { $0.suit == .joker } // 從牌堆中移除鬼牌

    // 分配普通卡牌給玩家
    for i in 0..<playerCount {
        var playerCards: [Card]
        
        // 每位玩家拿取 7 張普通卡牌
        playerCards = Array(deck.prefix(cardsPerPlayer - 1))
        players.append(Player(cards: playerCards, playerIsme: i == 2)) // 假設第 3 位玩家是自己
        deck.removeFirst(cardsPerPlayer - 1) // 移除已分配的卡牌
    }

    // 隨機分配鬼牌給任意玩家，包括自己
    for joker in jokerCards {
        let randomIndex = Int.random(in: 0..<players.count) // 隨機選擇玩家索引
        players[randomIndex].cards.append(joker)
    }

    // 確保每位玩家最終都有 8 張卡牌
    for i in 0..<players.count {
        while players[i].cards.count < cardsPerPlayer {
            if let cardToAdd = deck.first {
                players[i].cards.append(cardToAdd)
                deck.removeFirst() // 移除已添加的卡牌
            }
        }
    }
    // 如果某些玩家卡牌數量超過 cardsPerPlayer，移除多餘的卡牌
    for i in 0..<players.count {
        while players[i].cards.count > cardsPerPlayer {
            players[i].cards.removeLast() // 移除最後一張卡牌
        }
    }

    return players
}

/*func select(_ card: Card,in player:Player){
    if let cardIndex = player.cards.firstIndex(where:{$0.id == card.id}){
        if let playerIndex = players.firstIndex(where:{$0.id == player.id}){
            players[playerIndex].cards[cardIndex].selected.toggle()
        }
    }
    
}*/
