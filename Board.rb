BLACK, WHITE, NULL, NA = -1, 1, 0, -2
BOARD_SIZE = 15
FIVE = 5
MAX_SCORE = 100000000

class Board
  attr_accessor :side
  attr_accessor :empty_pos


  def copy
    Board.new(self)
  end

  def initialize(board = nil)
    @id = 1
    @side = BLACK
    @last_pos = nil
    @state = NULL
    @empty_pos = []
    # moves saves in a hash table
    if board
      @white_map = board.white_map.clone 
      @black_map = board.black_map.clone 
    else
      # 开始使用bit 棋盘
      @white_map = Array.new(BOARD_SIZE, 0)
      @black_map = Array.new(BOARD_SIZE, 0)
    end
  end


  def valid_move(x, y)
    x>=0 and x<BOARD_SIZE and y>=0 and y<BOARD_SIZE
  end

  def opposite(side)
    -side
  end

  def change_side
    @side = - @side
  end

  def set(x, y, side = @side)
    bit_board = case side  
                when BLACK
                  @black_map
                else
                  @white_map
                end
    bit_board[x] |= (1 << y)
    puts "bit:#{y},  #{bit_board[x] }"
  end

  def get(x, y)
    return NA unless valid_move(x, y)
    bit_x = x
    bit_y = (1 << y)
    if @black_map[bit_x] & bit_y > 0
      BLACK
    elsif @white_map[bit_x] & bit_y > 0
      WHITE
    else
      NULL
    end
  end

  def show
    puts "   A B C D E F G H I J K L M N O "
    iter_xy do |x, y|
      print("%2d " % x) if y == 0
      c = get(x, y)
      case c
        when WHITE
          print "o "
        when BLACK
          print "x "
        else
          print ". "
      end
      print "\n" if y == BOARD_SIZE-1
    end
    if @last_pos
      x = (@last_pos[0] + 'A'.ord).chr
      y = @last_pos[1]
      puts "[#{@id}手:#{name(@side)}, 落子: #{x}#{y}]"
    end

  end

  def move(x, y)
    @id = @id + 1
    @last_pos = [x, y]
    set(x, y)
  end

  def name(side)
    case side
    when BLACK
      return "BLACK"
    when WHITE
      return "WHITE"
    else
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

  def judge_helper(x, y, delta_x, delta_y)
    dx = delta_x
    dy = delta_y

    min_x, min_y = x, y
    max_x, max_y = x, y
    while get(min_x-dx, min_y-dy) == @side do
      min_x, min_y = min_x - dx, min_y - dy
    end
    while get(max_x+dx, max_y+dy) == @side do
      max_x, max_y = max_x + dx, max_y + dy
    end

    #judge connect count
    count = max_x - min_x
    count = max_y - min_y if count == 0

    if count + 1 >= FIVE
      @side
    else
      return NULL, count
    end
  end

  def all_space
    ret = []
    iter_xy do |x, y|
      if get(x, y) == NULL
        ret << [x, y]
      end
    end

    ret
  end

  def iter_xy
    (0...BOARD_SIZE).each do |x|
      (0...BOARD_SIZE).each do |y|
        yield x, y
      end
    end
  end
end
