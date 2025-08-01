//
//  ContentView.swift
//  Memory-Match-Ultimate
//
//  Created by Md Asif Hasan on 1/8/25.
//

import SwiftUI

// MARK: - Game Settings
struct GameSettings {
    var matchCount: Int = 2 // How many images need to match
    var dotsPerCard: Int = 9 // How many dots per card
    var numberOfCards: Int = 2 // How many cards total
    
    // Calculate minimum cards needed
    var minimumCards: Int {
        // If matchCount > dotsPerCard, we need at least matchCount cards (1 dot per card)
        if matchCount > dotsPerCard {
            return matchCount
        }
        // Otherwise, we need at least 2 cards minimum
        return max(2, Int(ceil(Double(matchCount * 2) / Double(dotsPerCard))))
    }
    
    // Calculate maximum cards possible (reasonable limit)
    var maximumCards: Int {
        return min(48, max(minimumCards, 48))
    }
    
    // Get valid range for number of cards
    var cardRange: ClosedRange<Int> {
        let min = minimumCards
        let max = maximumCards
        return min...max
    }
    
    // Validate if current settings are valid
    var isValid: Bool {
        return numberOfCards >= minimumCards && numberOfCards <= maximumCards && cardRange.contains(numberOfCards)
    }
    
    // Auto-adjust numberOfCards if it's outside valid range
    mutating func validateAndAdjust() {
        let range = cardRange
        if numberOfCards < range.lowerBound {
            numberOfCards = range.lowerBound
        } else if numberOfCards > range.upperBound {
            numberOfCards = range.upperBound
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var showingGame = false
    @State private var showingSettings = false
    @State private var gameSettings = GameSettings()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.6),
                        Color.pink.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Game Logo/Icon
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.9), Color.gray.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 10) {
                            Text("Memory Match")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            
                            Text("Ultimate")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Current Settings Display
                    VStack(spacing: 15) {
                        Text("Current Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            SettingRow(icon: "number.circle.fill", text: "Match \(gameSettings.matchCount) images")
                            SettingRow(icon: "circle.grid.3x3.fill", text: "\(gameSettings.dotsPerCard) dots per card")
                            SettingRow(icon: "rectangle.stack.fill", text: "\(gameSettings.numberOfCards) cards total")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 25)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Buttons
                    VStack(spacing: 20) {
                        // Settings Button
                        Button(action: {
                            showingSettings = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                Text("Game Settings")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        }
                        
                        // Start Game Button
                        NavigationLink(destination: GameView(settings: gameSettings), isActive: $showingGame) {
                            Button(action: {
                                showingGame = true
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.fill")
                                        .font(.title2)
                                    Text("Start Game")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                            }
                        }
                        .disabled(!gameSettings.isValid)
                        .opacity(gameSettings.isValid ? 1.0 : 0.6)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: $gameSettings)
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Binding var settings: GameSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                VStack(spacing: 30) {
                    // Match Count Setting
                    SettingCard(
                        title: "Images to Match",
                        subtitle: "How many identical images need to match",
                        value: $settings.matchCount,
                        range: 2...5,
                        icon: "number.circle.fill"
                    )
                    
                    // Dots per Card Setting
                    SettingCard(
                        title: "Dots per Card",
                        subtitle: "Number of dots on each card",
                        value: $settings.dotsPerCard,
                        range: 2...9,
                        icon: "circle.grid.3x3.fill"
                    )
                    
                    // Number of Cards Setting
                    SettingCard(
                        title: "Number of Cards",
                        subtitle: "Total cards in the game",
                        value: $settings.numberOfCards,
                        range: settings.cardRange,
                        icon: "rectangle.stack.fill"
                    )
                    .onChange(of: settings.matchCount) { _ in
                        settings.validateAndAdjust()
                    }
                    .onChange(of: settings.dotsPerCard) { _ in
                        settings.validateAndAdjust()
                    }
                    
                    // Info Section
                    VStack(spacing: 10) {
                        Text("Game Info")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 5) {
                            Text("Minimum cards needed: \(settings.minimumCards)")
                            Text("Maximum cards possible: \(settings.maximumCards)")
                            Text("Total images needed: \(settings.matchCount * settings.minimumCards)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Game Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Setting Card Component
struct SettingCard: View {
    let title: String
    let subtitle: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Only show slider if range is valid
            if range.lowerBound <= range.upperBound {
                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                .accentColor(.blue)
            } else {
                Text("Invalid range")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Show range info
            HStack {
                Text("Range: \(range.lowerBound) - \(range.upperBound)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Setting Row Component
struct SettingRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Game Models
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

// MARK: - Enhanced Game View
struct GameView: View {
    let settings: GameSettings
    @State private var cards: [Card] = []
    @State private var selectedDots: [Dot] = []
    @State private var moves = 0
    @State private var gameWon = false
    @State private var showingWinAlert = false
    
    // Extended image collection
    private let imageNames = [
        "star.fill", "heart.fill", "moon.fill", "sun.max.fill",
        "leaf.fill", "flame.fill", "drop.fill", "bolt.fill", "gift.fill",
        "diamond.fill", "triangle.fill", "square.fill", "circle.fill",
        "hexagon.fill", "pentagon.fill", "rhombus.fill", "oval.fill",
        "plus.circle.fill", "minus.circle.fill", "multiply.circle.fill",
        "divide.circle.fill", "equal.circle.fill", "checkmark.circle.fill",
        "xmark.circle.fill", "questionmark.circle.fill", "exclamationmark.circle.fill"
    ]
    
    var body: some View {
        ZStack {
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
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Memory Match")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 20) {
                            Text("Match \(settings.matchCount)")
                            Text("•")
                            Text("\(settings.dotsPerCard) dots")
                            Text("•")
                            Text("\(settings.numberOfCards) cards")
                        }
                        .font(.caption)
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
                    
                    // Cards Grid
                    let columns = min(4, settings.numberOfCards <= 4 ? settings.numberOfCards :
                                    settings.numberOfCards <= 8 ? 2 :
                                    settings.numberOfCards <= 16 ? 3 : 4)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: columns), spacing: 10) {
                        ForEach(cards) { card in
                            CardView(card: card, dotsPerCard: settings.dotsPerCard, columns: columns) { dot in
                                selectDot(dot, from: card)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress
                    let matchedSets = countMatchedSets()
                    let totalSets = countTotalSets()
                    
                    VStack(spacing: 8) {
                        Text("Progress: \(matchedSets)/\(totalSets) sets")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: Double(matchedSets), total: Double(totalSets))
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
                            Text("New Game")
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
                        )
                    }
                    .padding(.bottom, 30)
                }
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
            Text("You matched all sets in \(moves) moves!")
        }
    }
    
    private func selectDot(_ dot: Dot, from card: Card) {
        guard let cardIndex = cards.firstIndex(where: { $0.id == card.id }),
              let dotIndex = cards[cardIndex].dots.firstIndex(where: { $0.id == dot.id }),
              !cards[cardIndex].dots[dotIndex].isRevealed,
              !cards[cardIndex].dots[dotIndex].isMatched,
              selectedDots.count < settings.matchCount else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            cards[cardIndex].dots[dotIndex].isRevealed = true
            cards[cardIndex].dots[dotIndex].isSelected = true
        }
        
        selectedDots.append(cards[cardIndex].dots[dotIndex])
        
        if selectedDots.count == settings.matchCount {
            moves += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        // Check if all selected dots have the same image
        let firstImage = selectedDots[0].imageName
        let isMatch = selectedDots.allSatisfy { $0.imageName == firstImage }
        
        if isMatch {
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
            if countMatchedSets() == countTotalSets() {
                gameWon = true
                showingWinAlert = true
            }
        } else {
            // No match, hide dots
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
    
    private func countMatchedSets() -> Int {
        let allDots = cards.flatMap { $0.dots }
        let matchedDots = allDots.filter { $0.isMatched }
        return matchedDots.count / settings.matchCount
    }
    
    private func countTotalSets() -> Int {
        let totalDotsNeeded = settings.numberOfCards * settings.dotsPerCard
        return totalDotsNeeded / settings.matchCount
    }
    
    private func resetGame() {
        let totalDotsNeeded = settings.numberOfCards * settings.dotsPerCard
        let setsNeeded = totalDotsNeeded / settings.matchCount
        
        // Create sets of matching images
        var allDots: [Dot] = []
        for i in 0..<setsNeeded {
            let imageName = imageNames[i % imageNames.count]
            for _ in 0..<settings.matchCount {
                allDots.append(Dot(imageName: imageName))
            }
        }
        
        // Shuffle all dots
        allDots.shuffle()
        
        // Distribute dots among cards
        cards = []
        for cardIndex in 0..<settings.numberOfCards {
            let startIndex = cardIndex * settings.dotsPerCard
            let endIndex = min(startIndex + settings.dotsPerCard, allDots.count)
            let cardDots = Array(allDots[startIndex..<endIndex])
            cards.append(Card(dots: cardDots))
        }
        
        selectedDots.removeAll()
        moves = 0
        gameWon = false
    }
}

// MARK: - Enhanced Card View
struct CardView: View {
    let card: Card
    let dotsPerCard: Int
    let columns: Int
    let onDotTap: (Dot) -> Void
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 60 // Total horizontal padding (20 per side + spacing)
        let spacing: CGFloat = CGFloat(columns - 1) * 10 // Spacing between cards
        let cardSize = (screenWidth - padding - spacing) / CGFloat(columns)
        
        // Calculate dots grid based on dotsPerCard
        let dotColumns = dotsPerCard <= 4 ? 2 : dotsPerCard <= 9 ? 3 : 4
        let dotSize = (cardSize - 32) / CGFloat(dotColumns) // 32 = padding inside card (16 per side)
        
        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.9), Color.gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            .overlay(
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: dotColumns), spacing: 4) {
                    ForEach(card.dots) { dot in
                        DotView(dot: dot, size: dotSize)
                            .frame(width: dotSize, height: dotSize)
                            .onTapGesture {
                                onDotTap(dot)
                            }
                    }
                }
                .padding(16)
            )
            .frame(width: cardSize, height: cardSize)
    }
}

// MARK: - Enhanced Dot View
struct DotView: View {
    let dot: Dot
    let size: CGFloat
    
    var body: some View {
        ZStack {
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
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            if dot.isRevealed {
                Image(systemName: dot.imageName)
                    .font(.system(size: max(8, size * 0.4), weight: .medium))
                    .foregroundColor(dot.isMatched ? .green : .blue)
                    .scaleEffect(dot.isMatched ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: dot.isMatched)
            } else {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: max(4, size * 0.15), height: max(4, size * 0.15))
            }
        }
        .scaleEffect(dot.isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: dot.isSelected)
    }
}
