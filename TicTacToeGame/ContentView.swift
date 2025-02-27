import SwiftUI

struct ContentView: View {
    @State private var board: [[String]] = Array(repeating: Array(repeating: "", count: 3), count: 3)
    @State private var currentPlayer = "X"
    @State private var winner: String? = nil
    @State private var gameMode: String? = nil  // "Bot" or "Friend"
    @State private var botDifficulty: String = "Beginner" // Default bot level
    @State private var showBotDifficultySelection = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Dark background
            
            VStack {
                Text("Tic-Tac-Toe")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                if gameMode == nil {
                    // Mode Selection
                    VStack {
                        Button("Play with Friend") {
                            gameMode = "Friend"
                            resetGame()
                        }
                        .modeButtonStyle()
                        
                        Button("Play with Bot") {
                            showBotDifficultySelection = true
                        }
                        .modeButtonStyle()
                    }
                    .padding()
                } else {
                    VStack {
                        ForEach(0..<3, id: \.self) { row in
                            HStack {
                                ForEach(0..<3, id: \.self) { col in
                                    Button(action: {
                                        makeMove(row: row, col: col)
                                    }) {
                                        Text(board[row][col])
                                            .font(.system(size: 50))
                                            .frame(width: 80, height: 80)
                                            .background(Color.gray.opacity(0.3))
                                            .cornerRadius(10)
                                            .foregroundColor(.white)
                                    }
                                    .disabled(board[row][col] != "" || winner != nil)
                                }
                            }
                        }
                    }
                    
                    // Show result only if the game has started
                    if winner != nil || !board.flatMap({ $0 }).contains("") {
                        Text(winner != nil ? "\(winner!) wins!" : "It's a draw!")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }

                    Button("Reset Game") {
                        resetGame()
                    }
                    .buttonStyle()

                    Button("Change Mode") {
                        gameMode = nil
                    }
                    .buttonStyle()
                }
            }
        }
        .alert("Select Bot Difficulty", isPresented: $showBotDifficultySelection) {
            Button("Beginner") { botDifficulty = "Beginner"; gameMode = "Bot"; resetGame() }
            Button("Moderate") { botDifficulty = "Moderate"; gameMode = "Bot"; resetGame() }
            Button("Advanced") { botDifficulty = "Advanced"; gameMode = "Bot"; resetGame() }
            Button("Cancel", role: .cancel) { showBotDifficultySelection = false }
        }
    }

    func makeMove(row: Int, col: Int) {
        if board[row][col] == "" {
            board[row][col] = currentPlayer
            if checkWin(player: currentPlayer) {
                winner = currentPlayer
            } else {
                currentPlayer = (currentPlayer == "X") ? "O" : "X"
                if gameMode == "Bot" && currentPlayer == "O" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        botMove()
                    }
                }
            }
        }
    }

    func botMove() {
        let move: (Int, Int)?
        
        switch botDifficulty {
        case "Beginner":
            move = findRandomMove()
        case "Moderate":
            move = findWinningMove() ?? findRandomMove()
        case "Advanced":
            move = minimaxMove()
        default:
            move = findRandomMove()
        }
        
        if let move = move {
            board[move.0][move.1] = "O"
            if checkWin(player: "O") {
                winner = "O"
            } else {
                currentPlayer = "X"
            }
        }
    }

    func findRandomMove() -> (Int, Int)? {
        let availableMoves = board.indices.flatMap { row in
            board[row].indices.compactMap { col in board[row][col] == "" ? (row, col) : nil }
        }
        return availableMoves.randomElement()
    }

    func findWinningMove() -> (Int, Int)? {
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    board[row][col] = "O"
                    if checkWin(player: "O") {
                        board[row][col] = ""
                        return (row, col)
                    }
                    board[row][col] = ""
                }
            }
        }
        return nil
    }

    func minimaxMove() -> (Int, Int)? {
        var bestScore = Int.min
        var bestMove: (Int, Int)? = nil
        
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    board[row][col] = "O"
                    let score = minimax(isMaximizing: false)
                    board[row][col] = ""
                    
                    if score > bestScore {
                        bestScore = score
                        bestMove = (row, col)
                    }
                }
            }
        }
        return bestMove
    }

    func minimax(isMaximizing: Bool) -> Int {
        if checkWin(player: "O") { return 10 }
        if checkWin(player: "X") { return -10 }
        if boardJoined().contains("") == false { return 0 }
        
        var bestScore = isMaximizing ? Int.min : Int.max
        
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == "" {
                    board[row][col] = isMaximizing ? "O" : "X"
                    let score = minimax(isMaximizing: !isMaximizing)
                    board[row][col] = ""
                    
                    bestScore = isMaximizing ? max(bestScore, score) : min(bestScore, score)
                }
            }
        }
        return bestScore
    }

    func checkWin(player: String) -> Bool {
        for i in 0..<3 {
            if board[i][0] == player && board[i][1] == player && board[i][2] == player { return true }
            if board[0][i] == player && board[1][i] == player && board[2][i] == player { return true }
        }
        if board[0][0] == player && board[1][1] == player && board[2][2] == player { return true }
        if board[0][2] == player && board[1][1] == player && board[2][0] == player { return true }
        return false
    }

    func resetGame() {
        board = Array(repeating: Array(repeating: "", count: 3), count: 3)
        currentPlayer = "X"
        winner = nil
    }

    func boardJoined() -> String {
        return board.flatMap { $0 }.joined()
    }
}

// Custom button styles
extension View {
    func buttonStyle() -> some View {
        self
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }

    func modeButtonStyle() -> some View {
        self
            .padding()
            .frame(width: 200)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
