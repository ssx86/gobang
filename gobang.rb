load 'Board.rb'

def test_init board
  board.move(7, 7)
  board.move(7, 6)
end
board = Board.new
test_init board
500.times do 
  gets
  shuffled_empty_pos = board.empty_pos.shuffle[0]
  x, y = shuffled_empty_pos[:x], shuffled_empty_pos[:y]
  board.move(x, y)
end



