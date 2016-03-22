load 'Board.rb'
load 'ai.rb'


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
    judge(x, y)
    @board.change_side
  end


  def play
    @board.move(8, 8)
    @board.change_side
    @board.move(7, 7)
    @board.change_side
    @board.move(9, 7)
    @board.change_side
    @board.move(7, 9)
    @board.change_side
    @board.move(9, 6)
    @board.change_side
    @board.move(7, 8)
    @board.change_side
    @board.show
    while true do
      user_go
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

#Gobang.new.play

=begin
:start 初始状态
:sleep0 眠0 当前是对方棋子
:sleep1 眠1
:sleep2 眠2
:sleep3 眠3
:sleep4 眠4
:live0 活0
:live1 活1
:live2 活2
:live3 活3
:live4 活4

:enemy
:ally
:space

out_space
in_space
=end
class StateMachine
  attr_accessor :state, :state, :in_space, :out_space

  def initialize(side)
    @current_side = side
    @state = :start
    @space1 = 0
    @space2 = 0
    @space3 = 0
    @shape1 = []
    @shape2 = []
    @shape3 = []
    @shape4 = []
    @shape_long = []
  end

  def reset
    @space1 = 0
    @space2 = 0
    @space3 = 0
  end

  def trans_ally
    puts "ally:"
    puts "when :#{state}"
    case state
      when :start
        @state = :sleep1
      when :live0
        @state = :live1
      when :live1
        if @space2 > 0
          @state = :jump2
        else
          @state = :live2
        end
      when :live2
        if @space2 > 0
          @state = :jump3
        else
          @state = :live3
        end
      when :live3
        if @space2 > 0
          @state = :jump4
        else
          @state = :live4
        end
      when :live4
        if @space2 > 0
          @state = :jump_long
        else
          @state = :live_long
        end
      when :live_long
        if @space2 > 0
          @state = :live1
          @shape_long << [@space1, @space2, @space3]
        else
          @state = :live_long
        end
      when :sleep0
        @state = :sleep1
      when :sleep1
        @state = :sleep2
      when :sleep2
        @state = :sleep3
      when :sleep3
        @state = :sleep4
      when :sleep4
        @state = :sleep_long
      when :sleep_long
        @state = :sleep_long
      when :jump2
        @state = :live1
        @shape2 << [@space1,  @space2, @space3]
        reset
      when :jump3
        @state = :live1
        @shape3 << [@space1,  @space2, @space3]
        reset
      when :jump4
        @state = :live1
        @shape4 << [@space1,  @space2, @space3]
        reset
      when :jump_long
        @state = :live1
        @shape_long << [@space1,  @space2, @space3]
        reset
      else
        done
    end
  end

  def trans_enemy
    puts "enemy:"
    puts "when :#{state}"
    case state
      when :start
        @state = :sleep0
        reset
      when :sleep0
        reset
      when :sleep1
        @state = :sleep0
        @shape1 << [@space1,  @space2, @space3]
        reset
      when :sleep2
        @state = :sleep0
        @shape2 << [@space1,  @space2, @space3]
        reset
      when :sleep3
        @state = :sleep0
        @shape3 << [@space1,  @space2, @space3]
        reset
      when :sleep4
        @state = :sleep0
        @shape4 << [@space1,  @space2, @space3]
        reset
      when :sleep_long
        @state = :sleep0
        @shape4 << [@space1,  @space2, @space3]
        reset
      when :live0
        @state = :sleep0
        reset
      when :live1
        @state = :sleep0
        @shape1 << [@space1, @space2, @space3]
        reset
      when :live2
        @state = :sleep0
        @shape2 << [@space1, @space2, @space3]
        reset
      when :live3
        @state = :sleep0
        @shape3 << [@space1, @space2, @space3]
        reset
      when :live4
        @state = :sleep0
        @shape4 << [@space1, @space2, @space3]
        reset
      when :live_long
        @state = :sleep0
        @shape_long << [@space1, @space2, @space3]
        reset
      when :jump2
        @state = :sleep0
        @shape2 << [@space1, @space2, @space3]
        reset
      when :jump3
        @state = :sleep0
        @shape3 << [@space1, @space2, @space3]
        reset
      when :jump4
        @state = :sleep0
        @shape4 << [@space1, @space2, @space3]
        reset
      when :jump_long
        @state = :sleep0
        @shape_long << [@space1, @space2, @space3]
        reset
      else
        done
    end

  end

  def trans_null
    puts "null:"
    puts "when :#{state}"
    case state

      when :start
        @state = :live0
        @space1 = 1
      when :sleep0
        @state = :live0
        @space1 = 1
      when :sleep1
        @space2 += 1
      when :sleep2
        @space2 += 1
      when :sleep3
        @space2 += 1
      when :sleep4
        @space2 += 1
      when :sleep_long
        @space2 += 1

      when :live0
        @space2 += 1
      when :live1
        @space2 += 1
      when :live2
        @space2 += 1
      when :live3
        @space2 += 1
      when :live4
        @space2 += 1
      when :live_long
        @space2 += 1
      when :jump2
        @space3 += 1
      when :jump3
        @space3 += 1
      when :jump4
        @space3 += 1
      when :jump_long
        @space3 += 1
      else
        done
    end
  end

  def done
    puts "shape1: #{@shape1}"
    exit
  end

  def move(side)
    case side
      when @current_side
        trans_ally
      when -@current_side
        trans_enemy
      when NULL
        trans_null
      else
        done
    end

  end

end
sm = StateMachine.new(1)
1000.times do
  sm.move(rand(3) - 1)
end
sm.move(4)
