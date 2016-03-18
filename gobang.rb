Black, White, NULL = -1, 1, 0
BoardSize = 15
FIVE = 5
TRYTIME = 200000

class Board
  attr_accessor :side

  def copy
    return Board.new(self)
  end

  def points
    @points
  end

  def initialize(board = nil)
    # moves saves in a hashtable
    @points = board.points.clone if board
    @points = Hash.new
    @points.default = Hash.new
  end

  def set(x, y, side)
    @points[x][y] = side
  end

  def show(pos)
    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        value = @points[x][y]
        case value
        when White
          if pos[:row] == x and pos[:col] == y then
            print "O<"
          else
            print "o "
          end
        when Black
          if pos[:row] == x and pos[:col] == y then
            print "X<"
          else
            print "x "
          end
        when NULL
          if pos[:row] == x and pos[:col] == y then
            print "# "
          else
            print ". "
          end
        end
      end
      print "\n"
    end
  end

  def move(x, y, side)
    @points[x][y] = side
    return judge(x, y, side)
  end

  def name(side)
    case side
    when Black
      return "x wins"
    when White
      return "o wins"
    when NULL
      return "NULL"
    end
  end

  def judge(x, y, side)
    ret, score1 = judge_helper(x, y, side, 1, 0)
    return ret if ret != NULL
    ret, score2 = judge_helper(x, y, side, 0, 1)
    return ret if ret != NULL
    ret, score3 = judge_helper(x, y, side, 1, 1)
    return ret if ret != NULL
    ret, score4 = judge_helper(x, y, side, 1, -1)
    return ret if ret != NULL

    return NULL, score1 + score2 + score3 + score4
  end

  def judge_helper(x, y, side, movex, movey)
    deltax = movex
    deltay = movey

    def valid_move(x, y)
      x>=0 and x<BoardSize and y>=0 and y<BoardSize
    end

    count = 1
    curx = x + deltax
    cury = y + deltay

    while valid_move(curx, cury) and @points[curx][cury] == side do
      count = count + 1
      curx = curx + deltax
      cury = cury + deltay
    end
    curx = x - deltax
    cury = y - deltay
    while valid_move(curx, cury) and @points[curx][cury] == side do
      count = count + 1
      curx = curx - deltax
      cury = cury - deltay
    end

    if count >= FIVE then
      return side
    else
      return NULL, count*count*count
    end
  end

  def all_space
    ret = []
    (0...BoardSize).each do |x|
      (0...BoardSize).each do |y|
        if @points[x][y] == NULL then
          ret << {row: x, col: y}
        end
      end
    end
    return ret
  end
end

board = Board.new
board.move(2, 2, Black)
board.move(2, 1, White)
current_side = Black



def max_move(moves)
  max = 0
  cur = moves[0]
  moves.each do |pos, count|
    if count > max then
      max = count
      cur = pos
    end
  end
  return cur
end

while(true) do
  next_moves = {}


  puts "thinking..."

  t = TRYTIME

  if current_side == White then
    t = 1
  end
  t.times do |time|
    temp_current_side = current_side
    temp_board = board.copy

    space = board.all_space

    next_moves.default = 0
    moves = space.shuffle
    next_move = moves[0]

    moves.each do |move|
      side, score = temp_board.move(move[:row], move[:col], temp_current_side)
      if side == temp_current_side then
        next_moves[next_move] = next_moves[next_move]+100000
        break;
      elsif side == NULL
        next_moves[next_move] = next_moves[next_move]+score
      else
        next_moves[next_move] = next_moves[next_move]-score
      end

      temp_current_side = - temp_current_side
    end
  end
  pos = max_move(next_moves)
  res = board.move(pos[:row], pos[:col], current_side)
  board.show(pos)
  if res == current_side then
    puts board.name(current_side)
    board.show(pos)
    exit;
  end
  current_side = - current_side
end
