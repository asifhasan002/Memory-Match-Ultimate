//
//  ContentView.swift
//  Memory-Match-Ultimate
//
//  Created by Md Asif Hasan on 1/8/25.
//

import SwiftUI

struct MemoryCard: Identifiable {
    let id = UUID()
    let symbol: String
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
    @State private var cards: [MemoryCard] = []
    @State private var flippedCards: [MemoryCard] = []
    @State private var moves = 0
    @State private var gameWon = false
    @State private var showingWinAlert = false
    
    private let symbols = ["star.fill", "heart.fill", "star.fill", "heart.fill"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Memory Match")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Moves: \(moves)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Game grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                flipCard(card)
                            }
                    }
                }
                .padding(.horizontal, 20)
                
                // Reset button
                Button(action: resetGame) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("New Game")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
        .onAppear {
            resetGame()
        }
        .alert("Congratulations! 🎉", isPresented: $showingWinAlert) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("You completed the game in \(moves) moves!")
        }
    }
    
    private func flipCard(_ card: MemoryCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFaceUp,
              !cards[index].isMatched,
              flippedCards.count < 2 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            cards[index].isFaceUp = true
        }
        
        flippedCards.append(cards[index])
        
        if flippedCards.count == 2 {
            moves += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        if flippedCards[0].symbol == flippedCards[1].symbol {
            // Match found
            withAnimation(.easeInOut(duration: 0.3)) {
                for flippedCard in flippedCards {
                    if let index = cards.firstIndex(where: { $0.id == flippedCard.id }) {
                        cards[index].isMatched = true
                    }
                }
            }
            
            // Check if game is won
            if cards.allSatisfy({ $0.isMatched }) {
                gameWon = true
                showingWinAlert = true
            }
        } else {
            // No match, flip cards back
            withAnimation(.easeInOut(duration: 0.3)) {
                for flippedCard in flippedCards {
                    if let index = cards.firstIndex(where: { $0.id == flippedCard.id }) {
                        cards[index].isFaceUp = false
                    }
                }
            }
        }
        
        flippedCards.removeAll()
    }
    
    private func resetGame() {
        cards = symbols.shuffled().map { MemoryCard(symbol: $0) }
        flippedCards.removeAll()
        moves = 0
        gameWon = false
    }
}

struct CardView: View {
    let card: MemoryCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: card.isFaceUp ? 
                            [Color.white, Color.gray.opacity(0.1)] : 
                            [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            if card.isFaceUp {
                Image(systemName: card.symbol)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(card.isMatched ? .green : .blue)
                    .scaleEffect(card.isMatched ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: card.isMatched)
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "questionmark")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
    }
}

#Preview {
    ContentView()
}
