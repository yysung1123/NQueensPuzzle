class Agent
  def get_action(state)
  end
end

class SimulatedAnnealingAgent < Agent
  def initialize
    @t = 10000.0
    @coolingrate = 0.3
    @heuristic = 0
  end

  def get_action(state)
    @heuristic = state.get_queen_num * (state.get_queen_num - 1) if @heuristic.zero?
    self.simulated_annealing(state)
  end

  def simulated_annealing(state)
    next_action = self.find_random_next_action(state)
    heuristic = self.heuristic(state.generator_successor(*next_action))
    if Random.rand < self.acceptance_probability(@heuristic, heuristic, @t)
      # puts "#{heuristic} #{@t}"
      @heuristic = heuristic if heuristic < @heuristic
      @t *= 1 - @coolingrate
      return *next_action
    end
    [0, Actions.STOP, 0]
  end

  def acceptance_probability(energy, newenergy, temp)
    if newenergy < energy
      return 1.0
    else
      return Math.exp((energy - newenergy) / temp)
    end
  end

  def find_random_next_action(state)
    state.get_queen_num.times.to_a.flat_map { |i| state.get_legal_queen_action(i).map { |x| [i, x].flatten } }.flat_map { |queen_index, action, distance| (1..distance).map { |dis| [queen_index, action, dis] } }.sample
  end

  def heuristic(state)
    count = 0
    state.data.queens.combination(2).lazy.to_a.each do |p|
      t = 0
      t += 1 if p[0].x == p[1].x or p[0].y == p[1].y or (p[0].x - p[1].x).abs == (p[0].y - p[1].y).abs
      count += t * t
    end
    count
  end
end

class OneSolutionAgent < Agent
  def initialize
    @solution = [[0, Actions.UP, 5], [1, Actions.UP, 2], [2, Actions.UP, 4], [3, Actions.DOWN, 3], [4, Actions.UP, 3], [5, Actions.DOWN, 4], [6, Actions.DOWN, 2], [7, Actions.DOWN, 5]]
    @step_count = -1
  end

  def get_action(state)
    @step_count += 1
    @solution[@step_count]
  end
end
