

class AI

  def self.match_helper(board, ori_x, ori_y, points, values)
    (0...points.size).each do |i|
      dx, dy = points[i][0], points[i][1]
      if board.get(ori_x + dx, ori_y + dy) != values[i] then
        return false
      end
    end
    return true
  end

  def self.find_real_three board,side

    threes = []
    

    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        [ [1, 0], [0, 1], [1, 1], [1, -1] ].each do |dir|
          dx, dy = dir
          if AI.match_helper(board, x, y, [ [-2*dx, -2*dy], [-1*dx, -1*dy], [0, 0], [dx, dy], [2*dx, 2*dy] ],
                   [ NULL, side, side, side, NULL ]) 
            threes << {pos: [ [x-dx, y-dy], [x, y], [x+dx, y+dx] ], defend: [ [x-2*dx, y-2*dx], [x+2*dx, y+2*dx] ]}

          end
        end
      end
    end
    return threes
  end

  def self.guess board
    best_pos = nil
    best_score = 0

    ret = AI.find_real_three board, board.opposite(board.side)
    if ret.size > 0 then
      p = ret[0][:defend][0]
      return p, MAX_SCORE
    end

    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        result, score = AI.test(board, x, y) 
        if result == board.side then
          best_pos = [x, y]
          break;
        elsif score >= best_score then
          best_pos = [x, y]
          best_score = score
        end
      end
    end
    return best_pos, best_score
  end

  def self.test board, x, y
    board.judge(x, y)
  end
end

