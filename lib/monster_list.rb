require_relative "monster"

class MonsterList
  attr_reader :items, :inputs_count

  def initialize(monsters)
    @items = []
    @inputs_count = 0
    monsters.each_with_index do |monster, i|
      @items << {
        monster: monster,
        id: i,
        select_times: 0,
        match_times: monsters.size.times.map { 0 },
      }
    end
  end

  def shuffle!
    @items.shuffle!
  end

  def size
    @items.size
  end

  def next_match
    temp_list = @items.map {|i| i}
    result = []
    while temp_list.size > 1
      # select_timesが小さい順、scoreの高い順に並べる
      temp_list.sort! do |a, b|
        a[:select_times] * 10000 + a[:monster].score * -1 <=> \
          b[:select_times] * 10000 + b[:monster].score * -1
      end
      # 先頭が選ばれる
      first = temp_list.shift

      # 1. firstとまだmatchしていない、2. スコアが近い順で並べ替える
      temp_list.sort! do |a, b|
        score_between(first, b) <=> score_between(first, a)
      end
      # 先頭が選ばれる
      second = temp_list.shift

      # match_listとselect_timesを更新する
      first[:select_times] += 1
      second[:select_times] += 1
      first[:match_times][second[:id]] += 1
      second[:match_times][first[:id]] += 1

      result << [first[:monster], second[:monster]].shuffle
    end
    return result
  end

  # マッチ結果をlistに反映する
  # inputsは、0: firstの勝ち, 1: lastの勝ち, 2: 引き分け, 3: 興味なしとして、
  # [0, 1, 2, 3] のような配列とする
  # XXX: inputsが、matchの数とピッタリ一致しないとおかしくなる
  #      なぜなら、match_timesとselect_timesはもう計算済だから
  #      そこはまー、今は気にしない。
  #      つまり、暗黙的に、matches * n = inputsでなければならず、
  #      このmethodが終了する際には、matchesは空でなければならない
  def input_match_results(inputs)
    while (input = inputs.shift)
      matches = self.next_match if !matches || matches.empty?
      match = matches.shift
      first = match.first
      last = match.last

      case input
      when 0 # first won
        first.win last
      when 1 # last won
        first.lose last
      when 2 # draw
        first.draw last
      when 3 # 興味なし
        first.no_interest last
      end

      @inputs_count += 1
    end

    #unless !matches && matches.empty?
    #  # XXX: の問題が起きている
    #end
  end

  # この回数だけ入力があれば、結果ページに遷移してもいいかなという数
  # ex: sizeが4なら4回(2巡)、sizeが57なら224回(8巡)
  def enough_count
    Math::sqrt(@items.size).ceil * (@items.size / 2).floor
  end

  def sort
    @items.sort do |a, b|
      b[:monster].score <=> a[:monster].score
    end
  end

  def print
    self.sort.each {|i| puts i[:monster].status([:score]).join(", ") }
  end

  private

  # item1とitem2をどれぐらい対戦させた方が良いかのスコア
  # 上から優先
  # 1. item1とitem2が対戦すればするほどスコアが下がる
  # 2. item1とitem2のスコアが離れているほどスコアが下がる
  def score_between(item1, item2)
    -10000 * item1[:match_times][item2[:id]] + \
      -1 * (item1[:monster].score - item2[:monster].score).abs
  end
end
