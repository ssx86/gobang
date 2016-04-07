#此状态机不考虑任何禁手问题,有其他地方判断

# judge 要负责判断禁手和五连，直接决定棋局分数。

class StateMachine
  attr_accessor :state, :state, :vip

  def initialize(side)
    @current_side = side
    @state = :o
    @vip = []
    @s1, @l1 = 0, 0
    @s2, @l2 = 0, 0
    @s3, @l3 = 0, 0
    @s4, @l4 = 0, 0
    @c5 = 0
  end

  def set_direction(dir_x, dir_y)
    @dir_x, @dir_y = dir_x, dir_y
  end

  def trans_x
    case state
    when :o then goto :x
    when :x then goto :xx
    when :_ then goto :_x

    when :xx then goto :xxx
    when :x_ then goto :x_x
    when :_x then goto :_xx

    when :x_x then goto :x_xx
    when :_x_ then goto :_x_x
    when :xxx then goto :xxxx
    when :_xx then goto :_xxx
    when :xx_ then goto :xx_x

    when :_x__ then goto :_x__x
    when :_xx_ then goto :_xx_x
    when :xx_x then collect 4, false; goto :xx
    when :_xxx then goto :_xxxx
    when :_x_x then goto :_x_xx
    when :xxxx then collect 5
    when :x_xx then collect 4, false; goto :_xxx
    when :xxx_ then collect 4, false; goto :_x

    when :_x__x then collect 1, false; goto :_xx
    when :_xxxx then collect 5
    when :_x_xx then collect 4, false; goto :_xxx
    when :_xx_x then collect 4, false; goto :_xx
    when :_xxx_ then collect 4, false; goto :_x


    else done
    end
  end

  def trans_o
    case state
    when :o
    when :_
    when :x then collect 1, false

    when :x_ then collect 1, false
    when :xx then collect_multi_sleep_one 2
    when :_x then collect 1, false

    when :xxx then collect_multi_sleep_one 3
    when :x_x then collect_multi_sleep_one 2
    when :_x_ then collect 1, false
    when :_xx then collect 2, false
    when :xx_ then collect_multi_sleep_one 2

    when :_x__ then collect 1, false; goto :_
    when :xxxx then collect_multi_sleep_one 4
    when :xxx_ then collect_multi_sleep_one 3
    when :xx_x then collect_multi_sleep_one 3
    when :x_xx then collect_multi_sleep_one 3
    when :_xxx then collect 3, false
    when :_x_x then collect 2, false
    when :x_x_ then collect_multi_sleep_one 2
    when :_xx_ then collect 2, true
    when :x__x then collect_multi_sleep_one 2
    when :long then collect 6, true

    when :_x__x then collect 2, false
    when :_xxxx then collect 4, false
    when :_xxx_ then collect 3, false
    when :_xx_x then collect 3, false
    when :_x_xx then collect 3, false
    else done
    end

    goto :o

  end

  def trans_null
    case state
    when :o then goto :_
    when :_ then goto :_
    when :x then goto :x_

    when :_x then goto :_x_
    when :xx then goto :xx_
    when :x_ then collect 1, true; goto :_

    when :_x_ then goto :_x__
    when :_xx then goto :_xx_
    when :xxx then goto :xxx_
    when :x_x then collect 2, true; goto :_
    when :xx_ then collect 2, true; goto :_

    when :_x__ then collect 1, true; goto :_
    when :_x_x then collect 2, true; goto :_
    when :xx_x then collect 3, false; goto :_
    when :_xx_ then collect 2, true; goto :_
    when :xxxx then collect 4, false; goto :_
    when :xxx_ then collect 3, false; goto :_
    when :_xxx then goto :_xxx_
    when :x_xx then collect 3, false; goto :_


    when :_x__x then collect 2, true; goto :_x
    when :_xxxx then collect 4, true; goto :_

      # important point
    when :_xx_x then collect 3, true; goto :_
    when :_x_xx then collect 3, true; goto :_
    when :_xxx_ then collect 3, true; goto :_

    else done
    end
  end

  def goto s
    @state = s
  end

  def add_vip_point points
    points.each do |delta|
      @vip << [ @cur_x - delta * @dir_x , @cur_y - delta * @dir_y ]
    end
  end

  def collect_multi_sleep_one count
    @s1 += count
  end

  def collect (length, live = false)
    case length
    when 1
      live ? @l1 +=1 : @s1 +=1
    when 2
      live ? @l2 +=1 : @s2 +=1
    when 3
      live ? @l3 +=1 : @s3 +=1
    when 4
      live ? @l4 +=1 : @s4 +=1
    when 5
      @c5 +=1
      else
    end
  end

  def done
    puts 'state_machine error!'
    exit
  end

  def move(side, x, y)
=begin
    c = case side
        when @current_side
          'trans_x'
        when -@current_side
          'trans_o'
        when NULL
          'trans_null'
        else
          'trans_o'
        end
    puts "side = #{c}, when :#{@state}"
=end
    @cur_x, @cur_y = x, y

    case side
      when @current_side
        trans_x
      when -@current_side
        trans_o
      when NULL
        trans_null
      else
        trans_o
    end
  end

  def value
    if @s4 > 0 and @l3 > 0
      return 20000
    end
        @l1 * 1 +
        @s2 * 5 +
        @l2 * 10 +
        @s3 * 15 +
        @l3 * 1000 +
        @s4 * 14000 +
        @l4 * 20000 +
        @c5 * 20000
  end

  def show
    puts @state
    puts "活1 = #{@l1} 眠1 = #{@s1}"
    puts "活2 = #{@l2} 眠2 = #{@s2}"
    puts "活3 = #{@l3} 眠3 = #{@s3}"
    puts "活4 = #{@l4} 眠4 = #{@s4}"
    puts "活5 = #{@l5} 眠5 = #{@s5}"
    puts "活6 = #{@l6} 眠6 = #{@s6}"
  end
end

