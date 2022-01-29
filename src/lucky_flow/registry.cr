class LuckyFlow::Registry
  class_property default_driver : String = "headless_chrome"
  class_property current_driver : LuckyFlow::Driver?

  @@registry = Hash(String, Proc(LuckyFlow::Driver)).new
  @@running_registry = Hash(String, LuckyFlow::Driver).new

  def self.register(name : String | Symbol, &block : -> LuckyFlow::Driver)
    @@registry[name.to_s] = block
  end

  def self.available : Set(String)
    Set.new(@@registry.keys)
  end

  def self.get_driver(name : String = default_driver) : LuckyFlow::Driver
    @@running_registry[name] ||= @@registry[name].call
  end

  def self.shutdown_all
    @@running_registry.values.each(&.shutdown)
    @@running_registry.clear
  end
end
