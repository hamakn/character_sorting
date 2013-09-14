require "spec_helper"
require "./lib/helpers"

describe Helpers do
  before do
    class A
      include Helpers
    end
    @a = A.new
  end
  it do
    @a.decode_input("0123", 4).should eq([0, 1, 2, 3])
    @a.decode_input("00123", 5).should eq([0, 0, 1, 2, 3])
  end
end
