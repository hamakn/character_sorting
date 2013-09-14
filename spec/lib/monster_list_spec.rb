require "spec_helper"
require "./lib/monster_list"

describe MonsterList do
  before do
    srand(11111)
    inputs = [
      { name: "aaa" },
      { name: "bbb" },
      { name: "ccc" },
      { name: "ddd" },
    ]
    monsters = inputs.map { |i| Monster.new(:attributes => i) }

    # next_matchのテストのために最初からスコアに差異を持たせておく
    monsters.first.score = 1400
    monsters[1].score = 1400

    @list = MonsterList.new(monsters)
    @list.shuffle!
  end
  it { @list.size.should eq(4) }
  it do
    @list.items.first[:monster].name.should eq "ddd"
    @list.items.first[:monster].score.should eq 1500
  end

  describe "#enough_count" do
    it do
      @list.enough_count.should eq(4)
    end
    it do
      arr = 57.times.map { { name: "aaa" } }
      monsters = arr.map { |i| Monster.new(:attributes => i) }
      list2 = MonsterList.new(monsters)
      list2.enough_count.should eq(224)
    end
  end

  describe "#next_match" do
    # TODO: もっとこう読めるテストにしたい
    it do
      # 1回戦
      # スコアの近い ccc x ddd, aaa x bbb がマッチングされる
      matches = @list.next_match
      matches[0].map {|i| i.name}.sort.should eq(["ccc", "ddd"])
      matches[1].map {|i| i.name}.sort.should eq(["aaa", "bbb"])

      matches[0][0].win matches[0][1] # ccc win ddd
      matches[1][0].win matches[1][1] # aaa win bbb

      # 2回戦
      # 1回戦の結果、スコアの近い ccc x aaa, ddd x bbb がマッチングされる
      matches = @list.next_match
      matches[0].map {|i| i.name}.sort.should eq(["aaa", "ccc"])
      matches[1].map {|i| i.name}.sort.should eq(["bbb", "ddd"])

      # 3回戦
      # 残った ccc x bbb, ddd x aaa がマッチングされる
      matches = @list.next_match
      matches[0].map {|i| i.name}.sort.should eq(["bbb", "ccc"])
      matches[1].map {|i| i.name}.sort.should eq(["aaa", "ddd"])
    end
  end

  describe "#input_match_results" do
    # TODO: 経緯がわからんのでテストの意図も全然わからんのを直す
    it do
      @list.input_match_results([0, 1, 2, 3])
      # [0]はdddで、cccに負けて(0)-16, bbbとは興味なし(3)で-15。その結果1469
      @list.items[0][:monster].score.should eq(1469)
      @list.items[1][:monster].score.should eq(1516)
      @list.items[2][:monster].score.should eq(1416)
      @list.items[3][:monster].score.should eq(1370)
    end
  end
end
