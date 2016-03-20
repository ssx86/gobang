Black, White, NULL, NA = -1, 1, 0, -2
BoardSize = 15
FIVE = 5
TRYTIME = 200000
MAX_SCORE = 100000000


class Board
  attr_accessor :side
  attr_accessor :empty_pos

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
      @white_map = board.white_map.clone 
      @black_map = board.black_map.clone 
    else
      # 开始使用bit 棋盘
      @white_map = Array.new(BoardSize, 0)
      @black_map = Array.new(BoardSize, 0)
    end
  end


  def valid_move(x, y)
    x>=0 and x<BoardSize and y>=0 and y<BoardSize
  end

  def opposite(side)
    -side
  end

  def change_side
    @side = - @side
  end

  def set(x, y, side = @side)
    bit_board = case side  
                when Black 
                  @black_map
                when White 
                  @white_map
                end
    bit_board[x] |= (1 << y)
    puts "bit:#{y},  #{bit_board[x] }"
  end

  def get(x, y)
    return NA if not valid_move(x, y) 
    bit_x = x
    bit_y = (1 << y)
    if @black_map[bit_x] & bit_y > 0
      return Black
    elsif @white_map[bit_x] & bit_y > 0
      return White
    else
      return NULL
    end
  end

  def show
    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        c = get(x, y)
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

  def move(x, y)
    @id = @id + 1
    set(x, y)
    result, score, reason = judge(x, y)

    show

    puts "[#{@id}手:#{name(@side)} 落子： #{[x, y]}]"
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
  def judge(x, y)
    dir = [ [1, 0], [0, 1], [1, 1], [1, -1] ]

    total = 0
    dir.each do |direction|
      dir_x, dir_y = direction[0], direction[1]
      result, score, reason = judge_helper(x, y, dir_x, dir_y)
      return result, 0, reason if result != NULL

      total = total + score
    end

    return NULL, total + 1, nil
  end

  def judge_helper(x, y, movex, movey)
    deltax = movex
    deltay = movey

    min_x, min_y = x, y
    max_x, max_y = x, y
    while get(min_x-deltax, min_y-deltay) == @side do 
      min_x, min_y = min_x - deltax, min_y - deltay 
    end
    while get(max_x+deltax, max_y+deltay) == @side do 
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
        if get(x, y) == NULL then
          ret << [x, y] 
        end
      end
    end
    return ret
  end
end
