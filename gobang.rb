load 'Board.rb'
load 'StateMachine.rb'
load 'AI.rb'


class Gobang
  def initialize
    @board = Board.new
    @board.show
    @ai = AI.new
  end

  def judge x, y
    res, score, reason = @board.judge(x, y)
    if res != NULL
      puts "#{@board.name(res)} won!"
      exit
    end
  end

  def ai_go
    pos, _ = @ai.guess @board
    @board.move(pos[0], pos[1])
    @board.show
    judge(pos[0], pos[1])
    @board.change_side
  end

  def user_go pos=nil
    pos ||= gets.chomp
    y = pos[0].upcase.ord - 'A'.ord
    x = pos[1..-1].to_i - 1
    @board.move(x, y)
    @board.show
    @board.score
    judge(x, y)
    @board.change_side
  end


  def play
    @board.move(7, 7)
    @board.show
    @board.change_side
    while true do
      ai_go
    end
  end

  def test1
    @board.move(8, 8)
    @board.move(8, 7)
    @board.move(8, 9)
    @board.move(7, 8)

    @board.show
    puts @board.score
  end

  def test2
    @board.move(0, 0)
    @board.move(0, 1)
    @board.move(0, 2)
    @board.move(1, 1)

    @board.show
    puts @board.score

  end
end

Gobang.new.play
=begin
sm = StateMachine.new(1)
sm.set_direction(0, 0)
while a = rand(3) - 1 do 
  sm.move(a, 0, 0)
end

sm = StateMachine.new(1)
[0, 1,0,-1,0,1,0,-1].each do |a|  
  sm.move(a)
  sm.value
  sm.show
  gets
end
=end
