# encoding: UTF-8
class String
  def heb_url_encode
    u = ""
    # Do it the very ugly way - but it works
    self.each_byte do |i|
      if not i == 215
        u = u + "%" + (i+80).to_s(16)
      end
    end
    u
  end

  def trim
    return self.gsub(/[\s\t\302\240]+/, ' ').strip
  end
end
