INFINITE = 100000000

class AI

  def valuate board, side

  end

  def guess board
    pos, score = max_min board, 2, 1
  end

  def max_min board, depth, current
    side = board.side
    pos, score = [0, 0], 0
    if side == BLACK
      pos, score = _max(board, depth, current, 0, 0)
    else
      pos, score = _min(board, depth, current, 0, 0)
    end
    return pos, score

  end

  def _min(board, depth, current, px, py)
    result, score, reason = board.judge(px, py)
    if result == WHITE
      return [px, py], -INFINITE
    end

    side = board.side * ((current % 2 == 1) and 1 or -1)

    best = 10000000
    pos = [0, 0]
    count = 0

    situation = board.compute
    range = situation[:vip].size > 0 ? 
      situation[:vip] : board.valuable_points

    range.each do |x, y|

      count += 1
      board.set x, y, side

      if current == depth
        score = board.compute[:score]
      else
        _, score = _max(board, depth, current + 1, x, y)
      end
      board.reset x, y

      if score < best or (score == best and board.get_value(x,y) > board.get_value(pos[0], pos[1]))
        best = score
        pos = [x, y]
        print "\r#{best}: #{[x, y]}               " if current == 1
      end
    end

    #puts "level #{current}, searched #{count} points"
    return pos, best
  end

  def _max(board, depth, current, px, py)
    result, score, reason = board.judge(px, py)
    if result == BLACK
      return [px, py], INFINITE
    end

    side = board.side * ((current % 2 == 1) and 1 or -1)

    best = -INFINITE
    pos = [0, 0]
    count = 0

    situation = board.compute
    range = situation[:vip].size > 0 ? 
      situation[:vip] : board.valuable_points

    range.each do |x, y|

      count += 1
      board.set x, y, side
      if current == depth
        score = board.compute[:score]
      else
        _, score = _min(board, depth, current + 1, x, y)
      end
      board.reset x, y

      if score > best or (score == best and board.get_value(x,y) > board.get_value(pos[0], pos[1]))
        best = score
        pos = [x, y]
        print "\r#{best}: #{[x, y]}               " if current == 1
      end
    end
    #puts "level #{current}, searched #{count} points"
    return pos, best
  end


end
