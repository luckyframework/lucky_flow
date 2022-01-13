class LuckyFlow::Registry
  @@registry = Hash(String, Proc(LuckyFlow::Driver)).new
  @@running_registry = Hash(String, LuckyFlow::Driver).new

  def self.register(name : String | Symbol, &block : -> LuckyFlow::Driver)
    @@registry[name.to_s] = block
  end

  def self.available : Array(String)
    @@registry.keys
  end

  def self.get_driver(name : String) : LuckyFlow::Driver
    @@running_registry[name] ||= @@registry[name].call
  end
end
