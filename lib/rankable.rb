# http://ja.wikipedia.org/wiki/イロレーティング
module Rankable
  attr_accessor :score

  def initialize_score
    @score = 1500
  end

  def win(others)
    gap = gap_for(others)
    self.score += gap
    others.score -= gap
  end

  def lose(others)
    others.win self
  end

  def draw(others)
    # nothing to do
  end

  def no_interest(others)
    # 適当、両者のスコアが1%減る
    d = 0.01
    self.score -= (self.score * d).round
    others.score -= (others.score * d).round
  end

  def gap_for(others)
    gap = 16 + (others.score - self.score) * 0.04
    return 1 if gap < 1
    return 31 if gap > 31
    return gap.round
  end
end
