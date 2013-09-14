require_relative "./rankable"

class Monster
  include Rankable
  attr_reader :name, :images

  def initialize(attributes: {})
    @id = attributes[:id] || attributes["id"]
    @name = attributes[:name] || attributes["name"]
    @images = attributes[:images] || attributes["images"]
    initialize_score # XXX
  end

  def status(option_keys = [])
    output = [@name]
    option_keys.each do |key|
      if self.class.instance_methods.member?(key)
        output << self.__send__(key)
      end
    end
    return output
  end
end
