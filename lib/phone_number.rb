require 'colored'

class PhoneNumber

  include Comparable
  attr_accessor :number, :index, :type
  def initialize(type, number)
    @index = nil
    @type = type
    @number = number
  end

  def formatted_number(number)
    n = number.gsub(/[^\d]/, "")
    chars = n.chars
    if chars.count == 10
      chars.insert(3, '-')
      chars.insert(7, '-')
    elsif chars.count == 11
      chars.insert(0, '+')
      chars.insert(2, ' ')
      chars.insert(6, '-')
      chars.insert(10, '-')
    elsif chars.count == 7
      chars.insert(3, '-')
    else
      return n
    end
    return chars.join
  end

  def <=>(another_number)
    case
    when self.type > another_number.type
      return 1
    when self.type < another_number.type
      return -1
    else
      return 0
    end
  end

  def to_hash
    {index: index, type: type, number: formatted_number(number)}
  end

  def self.from_hash(hash)
    number = self.new(hash["type"], hash["number"])
    number.index = hash["index"]
    return number
  end

  def to_s
    "[#{index}]" + " #{type.yellow}: #{formatted_number(number).bold}"
  end

end