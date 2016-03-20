class Point
  attr_accessor :x, :y
  
  def initialize x, y, offset_x = 0, offset_y = 0
    @x, @y = x + offset_x, y + offset_y
  end

end


class AI
  def self.find_all_must_defend board
=begin
    points = board.points
    ally = board.side
    enemy = board.opposite ally
=end
  end

  def self.match_helper(board, ori_pos, points, values)
    (0...points.size).each do |i|
      dx, dy = points[i][0], points[i][1]
      puts "hehe #{ori_pos}"
      puts "hehe #{dx}"
      puts "hehe #{dy}"
      if board.get(Point.new(ori_pos.x, ori_pos.y, dx, dy)) != values[i] then
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
          if AI.match_helper(board, Point.new(x, y), [ [-2*dx, -2*dy], [-1*dx, -1*dy], [0, 0], [dx, dy], [2*dx, 2*dy] ],
                   [ NULL, side, side, side, NULL ]) 
            threes << {pos: [ [x-dx, y-dy], [x, y], [x+dx, y+dx] ], defend: [ Point.new(x-2*dx, y-2*dx), Point.new(x+2*dx, y+2*dx) ]}

          end
        end
      end
    end
    return threes
  end

  def self.guess board
    all_pos = board.empty_pos
    best_pos = nil
    best_score = 0

    ret = AI.find_real_three board, board.opposite(board.side)
    if ret.size > 0 then
      p = ret[0][:defend][0]
      return p, MAX_SCORE
    end

    all_pos.each do |pos|
      result, score = AI.test(board, pos)
      if result == board.side then
        best_pos = pos
        break;
      elsif score >= best_score then
        best_pos = pos
        best_score = score
      end
    end
    return best_pos, best_score
  end

  def self.test board, point
    board.judge(point)
  end
end

