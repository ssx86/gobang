load 'Board.rb'
load 'ai.rb'

class Gobang

  def initialize
    @board = Board.new
    @board.show
  end

  def judge x, y
    res, score, reason = @board.judge(x, y)
    if res != NULL
      puts "#{@board.name(res)} won!"
      exit
    end
  end

  def ai_go
    pos, _ = AI.guess @board
    @board.move(pos[0], pos[1])
    @board.show
    judge(pos[0], pos[1])
    @board.change_side
  end

  def user_go
    pos = gets.chomp
    y = pos[0].upcase.ord - 'A'.ord
    x = pos[1..-1].to_i
    @board.move(x, y)
    @board.show
    judge(x, y)
    @board.change_side
  end

  def play
    while true do
      user_go
      ai_go
    end
  end
end

Gobang.new.play