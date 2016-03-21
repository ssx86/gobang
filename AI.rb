class AI

  def self.valuate board, side

  end

  def self.guess board
    best_pos = nil
    best_score = 0
    result, score = AI.calc board, 5
  end


  def self.calc board, depth
    if depth == 0 then
      return board.score
    end

    board.iter_empty do |x, y|
      new_board = Board.new board
      new_board.move x, y
      score = new_board.score
      
      new_board.change_side
    end


  end

end