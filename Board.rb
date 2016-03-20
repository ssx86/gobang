Black, White, NULL, NA = -1, 1, 0, -2
BoardSize = 15
FIVE = 5
TRYTIME = 200000
MAX_SCORE = 100000000

class Board
  attr_accessor :side
  attr_accessor :empty_pos
  attr_accessor :points

  def log msg
    puts "    [LOG]#{msg}"
  end

  def copy
    return Board.new(self)
  end

  def initialize(board = nil)
    @id = 1
    @side = Black
    @last_pos = nil
    @state = NULL
    @empty_pos = []
    # moves saves in a hashtable
    if board then
      @points = board.points.clone 
    else
      @points = Array.new
      (0...BoardSize).each do |x|
        @points[x] = Array.new
        (0...BoardSize).each do |y|
          @points[x] << NULL

          #未下棋的格子
          @empty_pos << Point.new(x, y)
        end
      end
    end
  end


  def valid_move(point)
    point.x>=0 and point.x<BoardSize and point.y>=0 and point.y<BoardSize
  end

  def opposite(side)
    -side
  end

  def change_side
    @side = - @side
  end

  def set(point, side = @side)
    @points[point.x][point.y] = side
  end

  def get(point)
    return NA if not valid_move(point) 
    return @points[point.x][point.y]
  end

  def show
    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        c = @points[x][y]
        case c
        when White
          print "o "
        when Black
          print "x "
        when NULL
          print ". "
        end
      end
      print "\n"
    end
  end

  def move(point)
    @id = @id + 1
    puts point
    set(point)
    @empty_pos = @empty_pos - [point]
    result, score, reason = judge(point)

    show

    puts "[#{@id}手:#{name(@side)} 落子： #{point}]"
    if result != NULL then
      puts "[#{name(@side)} win!, #{reason}]"
      exit
    else
      puts "[#{name(@side)} got score: #{score}]"
    end
    change_side
  end

  def name(side)
    case side
    when Black
      return "Black"
    when White
      return "White"
    when NULL
      return "N/A"
    end
  end

  # judge one move, 
  # return result, score, reason(for win)
  def judge(point)
    dir = [ [1, 0], [0, 1], [1, 1], [1, -1] ]

    total = 0
    dir.each do |direction|
      dir_x, dir_y = direction[0], direction[1]
      result, score, reason = judge_helper(point, dir_x, dir_y)
      return result, 0, reason if result != NULL

      total = total + score
    end

    return NULL, total + 1, nil
  end

  def judge_helper(point, movex, movey)
    deltax = movex
    deltay = movey

    min_x, min_y = point.x, point.y
    max_x, max_y = point.x, point.y
    while get(Point.new(min_x, min_y, -deltax, -deltay)) == @side do 
      min_x, min_y = min_x - deltax, min_y - deltay 
    end
    while get(Point.new(max_x, max_y, deltax, deltay)) == @side do 
      max_x, max_y = max_x + deltax, max_y + deltay 
    end

    #judge connect count
    count = max_x - min_x
    count = max_y - min_y if count == 0

    if count + 1 >= FIVE then
      return @side
    else
      return NULL, count
    end
  end

  def all_space
    ret = []
    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        if @points[x][y] == NULL then
          ret << Point.new(x, y)
        end
      end
    end
    return ret
  end
end
