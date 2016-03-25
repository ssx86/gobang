BLACK, WHITE, NULL, NO_VALUE, OTHER = -1, 1, 0, -2, -3
BOARD_SIZE = 15
FIVE = 5
INIFITE = 100000000


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
      @value_map = board.value_map.clone
    else
      #
      @white_map = Array.new(BOARD_SIZE, 0)
      @black_map = Array.new(BOARD_SIZE, 0)
      @empty_pos = Array.new(BOARD_SIZE, 0xFFFF)
      @value_map = Array.new(BOARD_SIZE * BOARD_SIZE, 0)
    end
  end


  def valid_pos(x, y)
    x>=0 and x<BOARD_SIZE and y>=0 and y<BOARD_SIZE
  end

  def opposite(side)
    -side
  end

  def change_side
    @side = -@side
  end

  def change_value(x, y, delta)
    values = [
      [1, 0, 0, 1, 0, 0, 1],
      [0, 2, 0, 2, 0, 2, 0],
      [0, 0, 3, 3, 3, 0, 0],
      [1, 2, 3, 0, 3, 2, 1],
      [0, 0, 3, 3, 3, 0, 0],
      [0, 2, 0, 2, 0, 2, 0],
      [1, 0, 0, 1, 0, 0, 1],
    ]
    (-3..3).each do |dx|
      next if x+dx < 0 or x+dx > BOARD_SIZE - 1
      (-3..3).each do |dy|
        next if y+dy < 0 or y+dy > BOARD_SIZE - 1
        @value_map[(y+dy) * BOARD_SIZE + (x+dx)] += delta * (values[dx+3][dy+3])
      end
    end
  end

  def get_value(x, y)
    @value_map[y * BOARD_SIZE + x]
  end

  def reset(x, y)
    @black_map[x] &= (0xFFFF ^ (1 << y))
    @white_map[x] &= (0xFFFF ^ (1 << y))
    @empty_pos[x] |= (1 << y)
    change_value(x, y, -1)
  end

  def set(x, y, side = @side)
    return unless valid_pos(x, y)
    case side
    when BLACK
      @black_map[x] |= (1 << y)
    when WHITE
      @white_map[x] |= (1 << y)
    else
      exit
    end
    @empty_pos[x] &= (0xFFFF ^ (1 << y))
    change_value(x, y, 1)
  end

  def empty?(x, y)
    return NO_VALUE unless valid_pos(x, y)
    bit_x = x
    bit_y = (1 << y)

    @empty_pos[bit_x] & bit_y > 0
  end

  def get(x, y)
    return NO_VALUE unless valid_pos(x, y)
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
    puts ""
    iter do |x, y|
      print('%2d ' % (x+1)) if y == 0
      c = get(x, y)
      case c
      when WHITE
        print ' o'
      when BLACK
        print ' x'
      else
        #v = get_value(x, y)
        #if v > 0
        #  print "%2d" % get_value(x, y) 
        #else
        #  print ' .'
        #end
        print ' .'
      end
      print "\n" if y == BOARD_SIZE-1
    end
    puts '    A B C D E F G H I J K L M N O '
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

  def valuable_points
    points = []
    iter_empty do |x, y|
      points << [x, y] if get_value(x, y) > 0
    end
    points
  end

  def compute
    def score_color( side )
      sm = StateMachine.new(side)

      # dx, dy = 1, 0
      sm.set_direction 1, 0
      x, y = 0, 0

      sm.move( NO_VALUE , x, y)
      until x == BOARD_SIZE-1 and y == BOARD_SIZE-1 do 
        sm.move( get(x, y), x, y)
        if y == BOARD_SIZE-1 
          x += 1
          y = 0
          sm.move( NO_VALUE, x, y )
        else
          y += 1
        end
      end
      sm.move( get(x, y), x, y )


      #dx, dy = 0, 1
      sm.set_direction 0, 1
      x, y = 0, 0

      sm.move( NO_VALUE, x, y)
      until x == BOARD_SIZE-1 and y == BOARD_SIZE-1 do 
        sm.move( get(x, y), x, y )
        if x == BOARD_SIZE-1 
          y += 1
          x = 0
          sm.move( NO_VALUE, x, y )
        else
          x += 1
        end
      end
      sm.move( get(x, y), x, y )


      # dx, dy = -1, 1
      sm.set_direction 1, 0
      x, y = 0, 0
      sm.move( NO_VALUE, x, y)
      until x == BOARD_SIZE-1 and y == BOARD_SIZE-1 do
        endx, endy = y, x

        until x == endx and y == endy do
          sm.move( get(x, y), x, y )
          x -= 1
          y += 1
        end
        sm.move( get(x, y), x, y )

        x, y = y, x
        if x == BOARD_SIZE-1 
          y += 1
        else
          x += 1
        end
      end
      sm.move( get(x, y), x, y )

      # dx, dy = 1, 1
      sm.set_direction 1, 0
      x, y = 0, BOARD_SIZE-1
      sm.move( NO_VALUE, x, y)
      until x == BOARD_SIZE-1 and y == 0 do

        until x == BOARD_SIZE-1 or y == BOARD_SIZE-1 do
          sm.move( get(x, y), x, y )
          x += 1
          y += 1
        end
        sm.move( NO_VALUE, x, y )

        if x == BOARD_SIZE-1 
          x, y = BOARD_SIZE-y, 0
        else
          x, y = 0, BOARD_SIZE-x-2
        end
      end
      sm.move( NO_VALUE, x, y )

#      show
      ret, vip = sm.value, sm.vip
#      sm.show
#      gets

      return ret, vip
    end

    ret_black, vip1 = score_color(BLACK)
    ret_white, vip2 = score_color(WHITE)
    return { score: ret_black - ret_white, vip: vip1+vip2 }
  end
end


