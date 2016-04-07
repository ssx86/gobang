INFINITE = 100000000

class AI

  def guess board
    pos, score = alpha_beta board, board.side, 3, 0, 0, - INFINITE, INFINITE
  end

  def alpha_beta board, current_side, depth, px, py, alpha, beta


    if 0 == depth
      situation = board.compute
      return nil, situation[:score]
    end

    best_move = nil
    #range = situation[:vip].size > 0 ?
     #   situation[:vip] : board.valuable_points

    range = board.valuable_points
    range.each do |x, y|

      board.set x, y, current_side

      _, score_next = alpha_beta board, -current_side, depth - 1, x, y, -beta, -alpha
      score = -score_next

      board.show
      puts board.compute

      gets

      board.reset x, y

      if score >= beta
        return [x, y], beta
      end

      if score > alpha # or (score == alpha and board.get_value(x,y) > board.get_value(best_move[0], best_move[1]))
        best_move, alpha = [x, y], score
      end
    end

    return best_move, alpha
  end


=begin
  def max_min board, depth
    side = board.side
    pos, score = [0, 0], 0
    if side == BLACK
      pos, score = _max(board, side, depth, 0, 0)
    else
      pos, score = _min(board, side, depth, 0, 0)
    end
    return pos, score
  end

  def _min(board, current_side, depth, px, py)
    result, score, reason = board.judge(px, py)
    if result == current_side
      return [px, py], current_side * INFINITE
    end

    side = current_side

    best = 10000000
    pos = [0, 0]
    count = 0

    situation = board.compute
    range = situation[:vip].size > 0 ? 
      situation[:vip] : board.valuable_points

    range.each do |x, y|

      count += 1
      board.set x, y, side

      if 0 == depth
        score = board.compute[:score]
      else
        _, score = _max(board, -side, depth - 1, x, y)
      end
      board.reset x, y

      if score < best # or (score == best and board.get_value(x,y) > board.get_value(pos[0], pos[1]))
        best = score
        pos = [x, y]
      end
    end

    return pos, best
  end

  def _max(board, current_side, depth, px, py)
    result, score, reason = board.judge(px, py)
    if result == current_side
      return [px, py], current_side * INFINITE
    end

    side = current_side

    best = -INFINITE
    pos = [0, 0]
    count = 0

    situation = board.compute
    range = situation[:vip].size > 0 ? 
      situation[:vip] : board.valuable_points

    range.each do |x, y|

      count += 1
      board.set x, y, side
      if 0 == depth
        score = board.compute[:score]
      else
        _, score = _min(board, -side, depth - 1, x, y)
      end
      board.reset x, y

      if score > best # or (score == best and board.get_value(x,y) > board.get_value(pos[0], pos[1]))
        best = score
        pos = [x, y]
      end
    end
    return pos, best
  end
=end

end
