INIFITE = 100000000

class AI

  def valuate board, side

  end

  def guess board
    pos, score = max_min board, 3, 1
  end

  def max_min board, depth, current
    side = board.side
    pos, score = nil, 0
    if side == BLACK
      pos, score = _max(board, depth, current)
    else
      pos, score = _min(board, depth, current)
    end
    return pos, score

  end

  def _min(board, depth, current)

    if current == board 
      board.show
    end

    side = board.side * ((current % 2 == 1) and 1 or -1)

    best = 10000000
    pos = nil
    board.iter_empty do |x, y|
      next if board.get_value(x, y) == 0
      board.set x, y, side

      if current == depth
        score = board.score
      else
        _, score = _max(board, depth, current + 1)
      end
      board.reset x, y

      if score < best
        best = score
        pos = [x, y]
        print "\r#{best}: #{[x, y]}               " if current == 1
      end
    end
    return pos, best
  end

  def _max(board, depth, current)

    side = board.side * ((current % 2 == 1) and 1 or -1)

    best = -INIFITE
    pos = nil
    board.iter_empty do |x, y|
      next if board.get_value(x, y) == 0
      board.set x, y, side
      if current == depth
        score = board.score
      else
        _, score = _min(board, depth, current + 1)
      end
      board.reset x, y

      if score > best
        best = score
        pos = [x, y]
        print "\r#{best}: #{[x, y]}               " if current == 1
      end
    end
    return pos, best
  end


end
