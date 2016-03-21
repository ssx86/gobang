class AI

  def self.valuate board, side

  end

  def self.guess board
    best_pos = nil
    best_score = 0

    board.iter_xy do |x, y|
      unless board.empty? x, y
        break
      end
      result, score = AI.test(board, x, y)
      if result == board.side
        best_pos = [x, y]
        break
      elsif score >= best_score then
        best_pos = [x, y]
        best_score = score
      end
    end

    return best_pos, best_score
  end


  def self.test board, x, y
    board.judge(x, y)
  end

end