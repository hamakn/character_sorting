require "spec_helper"
require "./lib/rankable"

class Hoge
  include Rankable
  def initialize
    initialize_score
  end
end

describe Rankable do
  before do
    @aaa = Hoge.new
    @bbb = Hoge.new
  end

  it { @aaa.score.should eq(1500) }
  it do
    @aaa.win @bbb
    @aaa.score.should eq(1516)
    @bbb.score.should eq(1484)
  end
  it do
    @aaa.score = 1600
    @bbb.score = 1400
    @aaa.win @bbb
    @aaa.score.should eq(1608)
    @bbb.score.should eq(1392)
  end
  it do
    @aaa.score = 1400
    @bbb.score = 1600
    @aaa.win @bbb
    @aaa.score.should eq(1424)
    @bbb.score.should eq(1576)
  end
end
