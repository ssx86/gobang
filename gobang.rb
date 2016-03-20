load 'Board.rb'
load 'ai.rb'

def test_init board
  board.move(7, 7)
  board.move(7, 6)
end
board = Board.new
test_init board
while true do 
  gets
  pos, _ = AI.guess board
  puts "pos = #{pos}"
  board.move(pos[0], pos[1])
end



