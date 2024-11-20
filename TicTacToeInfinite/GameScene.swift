import SpriteKit

class GameScene: SKScene {
    private var player1Wins: Int = 0
    private var player2Wins: Int = 0
    private var currentPlayer: Int = 1
    private var board: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)
    private var label: SKLabelNode?
    private var winLabel: SKLabelNode?
    private var winningLine: SKShapeNode?

    private var player1Queue: [(Int, Int)] = []
    private var player2Queue: [(Int, Int)] = []

    override func didMove(to view: SKView) {
        size = CGSize(width: 390, height: 844) // iPhone dimensions
        setupBackground()
        setupUI()
        drawGrid()
    }
    
    func setupBackground() {
        backgroundColor = .gray
    }
    
    func setupUI() {
        label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label?.text = "Player 1's Turn"
        label?.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        label?.fontSize = 32
        label?.fontColor = .white
        addChild(label!)
        
        winLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        winLabel?.text = "Player 1: \(player1Wins) | Player 2: \(player2Wins)"
        winLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 150)
        winLabel?.fontSize = 24
        winLabel?.fontColor = .white
        addChild(winLabel!)
    }
    
    func drawGrid() {
        let gridSize = CGSize(width: frame.width * 0.7, height: frame.width * 0.7)
        let cellSize = gridSize.width / 3
        let gridOrigin = CGPoint(x: frame.midX - gridSize.width / 2, y: frame.midY - gridSize.height / 2)
        
        for i in 0..<3 {
            for j in 0..<3 {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize))
                cell.position = CGPoint(
                    x: gridOrigin.x + CGFloat(j) * cellSize + cellSize / 2,
                    y: gridOrigin.y + CGFloat(i) * cellSize + cellSize / 2
                )
                cell.name = "\(i)-\(j)"
                cell.alpha = 0.01
                addChild(cell)
            }
        }
        
        for i in 1..<3 {
            let startPoint = CGPoint(x: gridOrigin.x, y: gridOrigin.y + CGFloat(i) * cellSize)
            let endPoint = CGPoint(x: gridOrigin.x + gridSize.width, y: gridOrigin.y + CGFloat(i) * cellSize)
            
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            line.path = path
            line.strokeColor = .white
            line.lineWidth = 4
            addChild(line)
        }
        
        for i in 1..<3 {
            let startPoint = CGPoint(x: gridOrigin.x + CGFloat(i) * cellSize, y: gridOrigin.y)
            let endPoint = CGPoint(x: gridOrigin.x + CGFloat(i) * cellSize, y: gridOrigin.y + gridSize.height)
            
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            line.path = path
            line.strokeColor = .white
            line.lineWidth = 4
            addChild(line)
        }
    }
    
    func makeMove(row: Int, col: Int) {
        guard board[row][col] == 0 else { return } // Ensure the cell is empty
        
        var currentQueue = currentPlayer == 1 ? player1Queue : player2Queue
        
        if currentQueue.count == 3 {
            let (oldRow, oldCol) = currentQueue.removeFirst()
            board[oldRow][oldCol] = 0
            removePiece(at: (oldRow, oldCol))
        }
        
        board[row][col] = currentPlayer
        currentQueue.append((row, col))
        
        if currentPlayer == 1 {
            player1Queue = currentQueue
        } else {
            player2Queue = currentQueue
        }
        
        let markNode = createMark(for: currentPlayer)
        markNode.position = childNode(withName: "\(row)-\(col)")!.position
        markNode.name = "node_\(row)_\(col)"
        markNode.alpha = 0
        addChild(markNode)
        
        markNode.run(SKAction.fadeIn(withDuration: 0.3))
        
        if let winningCells = checkWin(for: currentPlayer) {
            if currentPlayer == 1 {
                player1Wins += 1
            } else {
                player2Wins += 1
            }
            drawWinningLine(between: winningCells)
            label?.text = "Player \(currentPlayer) Wins!"
            updateWinLabel()
            resetBoardAfterDelay() // Reset the board after a win
            label?.text = "Player \(currentPlayer)'s Turn"
        } else if checkTie() {
            label?.text = "It's a Tie!"
            resetBoardAfterDelay() // Reset the board after a tie
        } else {
            currentPlayer = currentPlayer == 1 ? 2 : 1
            label?.text = "Player \(currentPlayer)'s Turn"
        }
    }
    
    func createMark(for player: Int) -> SKShapeNode {
        let markNode = SKShapeNode()
        if player == 1 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -20, y: -20))
            path.addLine(to: CGPoint(x: 20, y: 20))
            path.move(to: CGPoint(x: -20, y: 20))
            path.addLine(to: CGPoint(x: 20, y: -20))
            markNode.path = path
            markNode.strokeColor = .black
            markNode.lineWidth = 8
            markNode.lineCap = .round
        } else {
            markNode.path = CGPath(ellipseIn: CGRect(x: -20, y: -20, width: 40, height: 40), transform: nil)
            markNode.strokeColor = .white
            markNode.lineWidth = 8
        }
        return markNode
    }
    
    func removePiece(at position: (Int, Int)) {
        let (row, col) = position
        let nodeName = "node_\(row)_\(col)"
        if let node = childNode(withName: nodeName) {
            node.removeFromParent()
        }
    }
    
    func resetBoardAfterDelay() {
        let wait = SKAction.wait(forDuration: 2.0) // Wait 2 seconds
        let fadeOut = SKAction.run { [weak self] in
            self?.fadeOutAllPieces()
        }
        let reset = SKAction.run { [weak self] in
            self?.resetBoard()
        }
        run(SKAction.sequence([wait, fadeOut, reset]))
    }
    
    func fadeOutAllPieces() {
        // Fade out all existing nodes
        for child in children where child.name?.starts(with: "node_") == true {
            child.run(SKAction.fadeOut(withDuration: 1.0), completion: {
                child.removeFromParent()
            })
        }
        winningLine?.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.winningLine?.removeFromParent()
        })
    }
    
    func resetBoard() {
        board = Array(repeating: Array(repeating: 0, count: 3), count: 3)
        player1Queue.removeAll()
        player2Queue.removeAll()
    }
    
    func checkTie() -> Bool {
        // Flatten the board array and check if all cells are filled (non-zero)
        return board.flatMap { $0 }.allSatisfy { $0 != 0 }
    }
    
    func checkWin(for player: Int) -> [(Int, Int)]? {
        for i in 0..<3 {
            if board[i][0] == player && board[i][1] == player && board[i][2] == player {
                return [(i, 0), (i, 1), (i, 2)]
            }
            if board[0][i] == player && board[1][i] == player && board[2][i] == player {
                return [(0, i), (1, i), (2, i)]
            }
        }
        if board[0][0] == player && board[1][1] == player && board[2][2] == player {
            return [(0, 0), (1, 1), (2, 2)]
        }
        if board[0][2] == player && board[1][1] == player && board[2][0] == player {
            return [(0, 2), (1, 1), (2, 0)]
        }
        return nil
    }
    
    func drawWinningLine(between cells: [(Int, Int)]) {
        guard let startCell = cells.first, let endCell = cells.last else { return }
        let cellSize = frame.width * 0.7 / 3
        let gridOrigin = CGPoint(x: frame.midX - frame.width * 0.7 / 2, y: frame.midY - frame.width * 0.7 / 2)
        
        let startPoint = CGPoint(x: gridOrigin.x + CGFloat(startCell.1) * cellSize + cellSize / 2,
                                 y: gridOrigin.y + CGFloat(startCell.0) * cellSize + cellSize / 2)
        let endPoint = CGPoint(x: gridOrigin.x + CGFloat(endCell.1) * cellSize + cellSize / 2,
                               y: gridOrigin.y + CGFloat(endCell.0) * cellSize + cellSize / 2)
        
        winningLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        winningLine?.path = path
        winningLine?.strokeColor = .cyan
        winningLine?.lineWidth = 5
        winningLine?.zPosition = 1
        addChild(winningLine!)
    }
    
    func updateWinLabel() {
        winLabel?.text = "Player 1: \(player1Wins) | Player 2: \(player2Wins)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }
    
    func handleTouch(at location: CGPoint) {
        let tappedNode = atPoint(location)
        if let name = tappedNode.name {
            let coords = name.split(separator: "-").compactMap { Int($0) }
            if coords.count == 2 {
                makeMove(row: coords[0], col: coords[1])
            }
        }
    }
}
