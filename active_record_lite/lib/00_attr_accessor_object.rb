class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      getter = "@" + name.to_s
      define_method(name.to_sym) do
        return instance_variable_get(getter.to_sym)
      end
      
      setter = name.to_s + "="
      define_method(setter.to_sym) do |value|
        return instance_variable_set(getter.to_sym, value)
      end
    end
  end
end
