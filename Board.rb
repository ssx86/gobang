BLACK, WHITE, NULL, NO_VALUE, OTHER = -1, 1, 0, -2, -3
BOARD_SIZE = 15
FIVE = 5


class Board
  attr_accessor :side
  attr_accessor :empty_pos
  attr_accessor :white_map
  attr_accessor :black_map


  def copy
    Board.new(self)
  end

  def initialize(board = nil)
    @id = 1
    @side = BLACK
    @last_pos = nil
    #@empty_pos = []
    # moves saves in a hash table
    if board
      @white_map = board.white_map.clone
      @black_map = board.black_map.clone
      @empty_pos = board.empty_pos.clone
    else
      #
      @white_map = Array.new(BOARD_SIZE, 0)
      @black_map = Array.new(BOARD_SIZE, 0)
      @empty_pos = Array.new(BOARD_SIZE, 0xFFFF)
    end
  end


  def valid_move(x, y)
    x>=0 and x<BOARD_SIZE and y>=0 and y<BOARD_SIZE
  end

  def opposite(side)
    -side
  end

  def change_side
    @side = -@side
  end

  def reset(x, y)
    @black_map[x] &= (0xFFFF ^ (1 << y))
    @white_map[x] &= (0xFFFF ^ (1 << y))
    @empty_pos[x] |= (1 << y)
  end

  def set(x, y, side = @side)
    case side
      when BLACK
        @black_map[x] |= (1 << y)
      when WHITE
        @white_map[x] |= (1 << y)
      else
        exit
    end
    @empty_pos[x] &= (0xFFFF ^ (1 << y))
  end

  def empty?(x, y)
    return NO_VALUE unless valid_move(x, y)
    bit_x = x
    bit_y = (1 << y)

    @empty_pos[bit_x] & bit_y > 0
  end

  def get(x, y)
    return NO_VALUE unless valid_move(x, y)
    bit_x = x
    bit_y = (1 << y)

    if (@black_map[bit_x] & bit_y) > 0
      BLACK
    elsif (@white_map[bit_x] & bit_y) > 0 then
      return WHITE
    else
      NULL
    end
  end

  def show
    iter do |x, y|
      print('%2d ' % (x+1)) if y == 0
      c = get(x, y)
      case c
        when WHITE
          print 'o '
        when BLACK
          print 'x '
        else
          print '. '
      end
      print "\n" if y == BOARD_SIZE-1
    end
    puts '   A B C D E F G H I J K L M N O '
    if @last_pos
      x = (@last_pos[1] + 'A'.ord).chr
      y = @last_pos[0] + 1
      puts "[#{@id}手:#{name(@side)}, 落子: #{x}#{y}]"
    end

  end

  def move(x, y)
    @last_pos = [x, y]
    set(x, y)
    @id = @id + 1
  end

  def name(side)
    case side
      when BLACK
        return 'BLACK'
      when WHITE
        return 'WHITE'
      else
        return 'N/A'
    end
  end

  # judge one move, 
  # return result, score, reason(for win)
  def judge(x, y)
    dir = [[1, 0], [0, 1], [1, 1], [1, -1]]

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
    iter do |x, y|
      if get(x, y) == NULL
        ret << [x, y]
      end
    end
    ret
  end

  def iter
    (0...BOARD_SIZE).each do |x|
      (0...BOARD_SIZE).each do |y|
        yield x, y
      end
    end
  end

  def iter_empty
    (0...BOARD_SIZE).each do |x|
      (0...BOARD_SIZE).each do |y|
        next unless empty? x, y
        yield x, y
      end
    end
  end

  def iter_color side
    (0...BOARD_SIZE).each do |x|
      (0...BOARD_SIZE).each do |y|
        next unless get(x, y) == side
        yield x, y
      end
    end
  end

  def match_pattern(start_x, start_y, dx, dy, offset, pattern, side)

    def eq(x, value)
      if value == OTHER
        x == -side or x == NO_VALUE
      else
        x == value
      end
    end

    i = 0
    x, y = start_x - offset*dx, start_y - offset*dy
    while i < pattern.size
      return false unless eq(get(x, y), pattern[i])
      x, y = x + dx, y + dy
      i = i + 1
    end
    true
  end

  def score

    def score_color side
      dirs = [[0, 1], [1, 0], [1, 1], [1, -1]]
      #先判断输赢
      iter_color side do |x, y|
        dirs.each do |dx, dy|
          return side, 0 if match_pattern(x, y, dx, dy, 4, [side, side, side, side, side, OTHER], side)
        end
      end



      l1, l2, l3, l4, s1, s2, s3, s4 = 0, 0, 0, 0, 0, 0, 0, 0
      #活1在每个方向上都算一个
      iter_color side do |x, y|
        dirs.each do |dx, dy|
          l1 = l1 + 1 if match_pattern(x, y, 1, 0, 2, [NULL, side, NULL], side)
        end
      end

      iter_color side do |x, y|
        dirs.each do |dx, dy|
          l2 = l2 + 1 if match_pattern(x, y, dx, dy, 2, [NULL, side, side, NULL], side)
          l2 = l2 + 1 if match_pattern(x, y, dx, dy, 3, [NULL, side, NULL, side, NULL], side)
        end
      end

      iter_color side do |x, y|
        dirs.each do |dx, dy|
          s2 = s2 + 1 if match_pattern(x, y, dx, dy, 2, [NULL, side, side, OTHER], side)
          s2 = s2 + 1 if match_pattern(x, y, dx, dy, 2, [OTHER, side, side, NULL], side)
          s2 = s2 + 1 if match_pattern(x, y, dx, dy, 3, [NULL, side, NULL, side, OTHER], side)
          s2 = s2 + 1 if match_pattern(x, y, dx, dy, 3, [OTHER, side, NULL, side, NULL], side)
        end
      end

      iter_color side do |x, y|
        dirs.each do |dx, dy|
          l3 = l3 + 1 if match_pattern(x, y, dx, dy, 3, [NULL, side, side, side, NULL], side)
          l3 = l3 + 1 if match_pattern(x, y, dx, dy, 4, [NULL, side, side, NULL, side, NULL], side)
        end
      end

      iter_color side do |x, y|
        dirs.each do |dx, dy|
          s3 = s3 + 1 if match_pattern(x, y, dx, dy, 3, [NULL, side, side, side, OTHER], side)
          s3 = s3 + 1 if match_pattern(x, y, dx, dy, 3, [OTHER, side, side, side, NULL], side)
          s3 = s3 + 1 if match_pattern(x, y, dx, dy, 4, [NULL, side, side, NULL, side, OTHER], side)
          s3 = s3 + 1 if match_pattern(x, y, dx, dy, 4, [OTHER, side, side, NULL, side, NULL], side)
        end
      end

      iter_color side do |x, y|
        dirs.each do |dx, dy|
          l4 = l4 + 1 if match_pattern(x, y, dx, dy, 4, [NULL, side, side, side, side, NULL], side)
        end
      end

      s4 = 0
      iter_color side do |x, y|
        dirs.each do |dx, dy|
          s4 = s4 + 1 if match_pattern(x, y, dx, dy, 4, [OTHER, side, side, side, side, NULL], side)
          s4 = s4 + 1 if match_pattern(x, y, dx, dy, 4, [NULL, side, side, side, side, OTHER], side)
          s4 = s4 + 1 if match_pattern(x, y, dx, dy, 5, [OTHER, side, NULL, side, side, side, OTHER], side)
          s4 = s4 + 1 if match_pattern(x, y, dx, dy, 5, [OTHER, side, side, NULL, side, side, OTHER], side)
          s4 = s4 + 1 if match_pattern(x, y, dx, dy, 5, [OTHER, side, side, side, NULL, side, OTHER], side)
        end
      end


      #puts "#{name(side)}:\n活一: #{l1}, 活二: #{l2}, 活三: #{l3}, 活四: #{l4}\n眠二: #{s2}, 眠三 #{s3}, 眠四 #{s4}"
      l1*2 + l2 * 10 + l3 * 50 + l4 * 100000 + s1 + s2 * 7 + s3 * 30 + s4 * 5000
    end

    ret = score_color(@side) - score_color(-@side)
    return NULL, ret
  end
end
