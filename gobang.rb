load 'Board.rb'
load 'ai.rb'

def test_init board
  board.move(Point.new(7, 7))
  board.move(Point.new(7, 6))
end
board = Board.new
test_init board
while true do 
  gets
  pos, _ = AI.guess board
  puts pos
  board.move(pos)
end



