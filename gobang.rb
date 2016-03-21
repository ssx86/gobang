load 'Board.rb'
load 'ai.rb'

def test_init board
  board.move(7, 7)
  board.show
  board.change_side

  board.move(7, 6)
  board.show
  board.change_side
end
board = Board.new
test_init board
while true do 
  gets
  pos, _ = AI.guess board
  puts "pos = #{pos}"
  board.move(pos[0], pos[1])
  board.show
  res, score, reason = board.judge(pos[0], pos[1])
  if res != NULL then
    puts "#{board.name(res)} won!"
    break
  end
  board.change_side
end



