class AI

  def valuate board, side

  end

  def guess board
    result, score = max_min board, 3, 0
  end


  def max_min board, depth, current
    if current % 2 == 0 then # max
      return _max(board, depth, current)
    else
      return _min(board, depth, current)
    end
  end

  def _min(board, depth, current)
    if current <= 2 then
      print "."
    end
    if current == depth
      return board.score
    end

    side = case current % 2
           when 0
             board.side
           when 1
             - board.side
           end

    best = 10000000
    result = NULL
    board.iter_empty do |x, y|
      next unless x < 10 and x > 5
      next unless y < 10 and y > 5
      board.set x, y, side
      result, score = _max(board, depth, current + 1)
      board.reset x, y

      best = score if score < best 
    end
    return result, best
  end

  def _max(board, depth, current)
    if current <= 2 then
      print "."
    end
    if current == depth
      return board.score
    end

    side = case current % 2
           when 0
             board.side
           when 1
             - board.side
           end
    best = -10000000
    result = NULL
    board.iter_empty do |x, y|
      next unless x < 10 and x > 5
      next unless y < 10 and y > 5
      board.set x, y, side
      result, score = _min(board, depth, current+1)
      board.reset x, y

      best = score if score > best 
    end
    return result, best
  end


end
