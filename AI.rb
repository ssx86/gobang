class AI
  def self.find_all_must_defend board
=begin
    points = board.points
    ally = board.side
    enemy = board.opposite ally
=end
  end

  def self.guess board
    all_pos = board.empty_pos
    best_pos = nil
    best_score = 0
    all_pos.each do |pos|
      x, y = pos[:x], pos[:y]
      result, score = AI.test(board, x, y)
      if result == board.side then
        best_pos = pos
        break;
      elsif score >= best_score then
        if score > best_score or rand(50) > 40 then
          best_pos = pos
        end
        best_score = score
      end
    end
    return best_pos, best_score
  end

  def self.test board, x, y
    board.judge(x, y)
  end
end

