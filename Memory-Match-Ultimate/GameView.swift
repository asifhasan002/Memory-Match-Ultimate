//
//  GameView.swift
//  Memory-Match-Ultimate
//
//  Created by Md Asif Hasan on 1/8/25.
//

import SwiftUI

struct Dot: Identifiable {
    let id = UUID()
    let imageName: String
    var isRevealed = false
    var isMatched = false
    var isSelected = false
}

struct Card: Identifiable {
    let id = UUID()
    var dots: [Dot]
}

struct GameView: View {
    @State private var cards: [Card] = []
    @State private var selectedDots: [Dot] = []
    @State private var moves = 0
    @State private var gameWon = false
    @State private var showingWinAlert = false
    
    // 9 different system images for the dots
    private let imageNames = [
        "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "leaf.fill", "flame.fill", "drop.fill", "bolt.fill", "gift.fill"
    ]
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.4),
                    Color.pink.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Text("Memory Match")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Text("Match pairs across cards!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Moves: \(moves)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding(.top, 20)
                
                // Two Cards with 3x3 dots each
                HStack(spacing: 20) {
                    ForEach(cards) { card in
                        CardView(card: card) { dot in
                            selectDot(dot, from: card)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Progress indicator
                let matchedCount = cards.flatMap { $0.dots }.filter { $0.isMatched }.count / 2
                let totalPairs = imageNames.count
                
                VStack(spacing: 8) {
                    Text("Progress: \(matchedCount)/\(totalPairs) pairs")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(matchedCount), total: Double(totalPairs))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 20)
                
                // Reset button
                Button(action: resetGame) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                        Text("New Game")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.bottom, 30)
                
                Spacer()
            }
        }
        .onAppear {
            resetGame()
        }
        .alert("🎉 Congratulations! 🎉", isPresented: $showingWinAlert) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("You matched all pairs in \(moves) moves!")
        }
    }
    
    private func selectDot(_ dot: Dot, from card: Card) {
        guard let cardIndex = cards.firstIndex(where: { $0.id == card.id }),
              let dotIndex = cards[cardIndex].dots.firstIndex(where: { $0.id == dot.id }),
              !cards[cardIndex].dots[dotIndex].isRevealed,
              !cards[cardIndex].dots[dotIndex].isMatched,
              selectedDots.count < 2 else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            cards[cardIndex].dots[dotIndex].isRevealed = true
            cards[cardIndex].dots[dotIndex].isSelected = true
        }
        
        selectedDots.append(cards[cardIndex].dots[dotIndex])
        
        if selectedDots.count == 2 {
            moves += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        if selectedDots[0].imageName == selectedDots[1].imageName {
            // Match found
            withAnimation(.easeInOut(duration: 0.4)) {
                for selectedDot in selectedDots {
                    for cardIndex in cards.indices {
                        if let dotIndex = cards[cardIndex].dots.firstIndex(where: { $0.id == selectedDot.id }) {
                            cards[cardIndex].dots[dotIndex].isMatched = true
                            cards[cardIndex].dots[dotIndex].isSelected = false
                        }
                    }
                }
            }
            
            // Check if game is won
            let allMatched = cards.flatMap { $0.dots }.allSatisfy { $0.isMatched }
            if allMatched {
                gameWon = true
                showingWinAlert = true
            }
        } else {
            // No match, hide dots back
            withAnimation(.easeInOut(duration: 0.4)) {
                for selectedDot in selectedDots {
                    for cardIndex in cards.indices {
                        if let dotIndex = cards[cardIndex].dots.firstIndex(where: { $0.id == selectedDot.id }) {
                            cards[cardIndex].dots[dotIndex].isRevealed = false
                            cards[cardIndex].dots[dotIndex].isSelected = false
                        }
                    }
                }
            }
        }
        
        selectedDots.removeAll()
    }
    
    private func resetGame() {
        // Create two cards with shuffled images
        var allImages = imageNames + imageNames // 18 total (9 pairs)
        allImages.shuffle()
        
        let firstCardDots = allImages.prefix(9).map { Dot(imageName: $0) }
        let secondCardDots = allImages.suffix(9).map { Dot(imageName: $0) }
        
        cards = [
            Card(dots: firstCardDots),
            Card(dots: secondCardDots)
        ]
        
        selectedDots.removeAll()
        moves = 0
        gameWon = false
    }
}

struct CardView: View {
    let card: Card
    let onDotTap: (Dot) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .overlay(
                    // 3x3 Grid of Dots
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(card.dots) { dot in
                            DotView(dot: dot)
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    onDotTap(dot)
                                }
                        }
                    }
                    .padding(20)
                )
        }
        .frame(width: 160, height: 160)
    }
}

struct DotView: View {
    let dot: Dot
    
    var body: some View {
        ZStack {
            // Dot background
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: dot.isRevealed ?
                            [Color.white, Color.gray.opacity(0.1)] :
                            [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            dot.isSelected ? Color.yellow : Color.clear,
                            lineWidth: 2
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            
            if dot.isRevealed {
                Image(systemName: dot.imageName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(dot.isMatched ? .green : .blue)
                    .scaleEffect(dot.isMatched ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: dot.isMatched)
            } else {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .scaleEffect(dot.isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: dot.isSelected)
    }
}

#Preview {
    GameView()
}
