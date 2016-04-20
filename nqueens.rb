require './agent.rb'
require 'thor'

class Actions
  @UP = 'Up'
  @DOWN = 'Down'
  @STOP = 'Stop'
  class << self
    attr_accessor :UP, :DOWN, :STOP
  end
end

class Queen
  attr_reader :x, :y

  def initialize(boardsize, pos=[0,0])
    @x, @y = pos
    @boardsize = boardsize
  end

  def set_queen_pos(pos)
    @x, @y = pos
  end

  def get_queen_pos
    [@x, @y]
  end

  def get_legal_actions
    legal_actions = [[Actions.STOP, 0]]
    legal_actions << [Actions.DOWN, @y] if not @y.zero?
    legal_actions << [Actions.UP, @boardsize - 1 - @y] if not @y == @boardsize - 1
    return legal_actions
  end

  def action(action, distance=1)
    if self.get_legal_actions.collect { |x| x.first }.include? action
      @y += distance if action == Actions.UP
      @y -= distance if action == Actions.DOWN
    end
  end
end

class GameStateData
  attr_accessor :queens

  def initialize(boardsize, prev_state=nil)
    if prev_state.nil?
      @queens = Array.new(boardsize){Queen.new(boardsize)}.each_with_index { |q, i| q.set_queen_pos [i, i] }
    else
      @queens = prev_state.queens.map { |x| x.dup }
    end
  end
end

class GameState
  attr_reader :data
  def initialize(boardsize, prev_state=nil)
    @boardsize = boardsize
    if prev_state.nil?
      @data = GameStateData.new(boardsize)
    else
      @data = GameStateData.new(boardsize, prev_state.data)
    end
  end

  def is_queen?(pos)
    self.get_board[pos[0]][pos[1]] == 'Q'
  end

  def collision
    count = 0
    @data.queens.combination(2).lazy.to_a.each do |p|
      count += 1 if p[0].x == p[1].x or p[0].y == p[1].y or (p[0].x - p[1].x).abs == (p[0].y - p[1].y).abs
    end
    count
  end

  def get_board
    board = Array.new(self.get_queen_num){Array.new(self.get_queen_num)}
    board.collect.with_index { |x, i| x.collect.with_index { |y, j| [i, j] == @data.queens[i].get_queen_pos ? 'Q' : 'X' } }
  end

  def get_boardsize
    @boardsize
  end

  def print_board
    self.get_board.each { |line| puts "#{line}" }
  end

  def get_queen_num
    @boardsize
  end

  def set_queen_pos(queen_index, pos)
    @data.queens[queen_index].set_queen_pos pos
  end

  def queen_action(queen_index, action, distance)
    @data.queens[queen_index].action(action, distance)
  end

  def generator_successor(queen_index, action, distance)
    state = GameState.new(boardsize=@boardsize, prev_state=self)
    state.queen_action(queen_index, action, distance)
    return state
  end

  def get_legal_queen_action(queen_index)
    @data.queens[queen_index].get_legal_actions
  end

  def is_win?
    self.collision.zero?
  end
end

class Problem
  def initialize(agent, boardsize=8)
    @state = GameState.new(boardsize)
    @agent = agent
  end

  def solve
    @state.queen_action *(@agent.get_action @state) until @state.is_win?
    puts "#{@state.get_queen_num} Queens Solution By #{@agent.class}:"
    @state.print_board
  end
end

def test
  g = GameState.new(8)
  puts g.is_queen? [0, 0]
  puts g.is_queen? [0, 1]
  puts g.collision
  g.print_board
  newg = g.generator_successor(0, Actions.UP, 1)
  newg = g.generator_successor(0, Actions.UP, 1)
  newg.print_board
end

class NQueens < Thor
  desc "N Queens Puzzle", "Use Agent to Solve N Queens Puzzle"
  method_option :queen_num, :aliases => "-n", :desc => "the number of queens", :default => 8
  method_option :agent, :aliases => "-a", :desc => "the agent", :default => "SimulatedAnnealingAgent"
  def default
    agent = Object.const_get(options[:agent]).new
    problem = Problem.new(agent=agent, boardsize=options[:queen_num].to_i)
    problem.solve
  end
  default_task :default
end

NQueens.start(ARGV)
