# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

# class Factory < Struct
# end

class Factory
  class << self
    attr_accessor :myhash

    def new(*params, &block)
      @myhash = {}
      if params[0].is_a? String
        const_name = params[0]
        params.shift
        const_set(const_name, create_new_struct(*params, &block))
      else
        create_new_struct(*params, &block)
      end
    end

    def create_new_struct(*params, &methods)
      Class.new do
        define_method :initialize do |*values|
          raise ArgumentError, 'Invalid number of parameters' unless values.size == params.size

          @myhash = {}
          params.each_with_index do |param, index|
            @myhash[param] = values[index]
          end
        end

        params.each do |param|
          define_method param do
            myhash = instance_variable_get :@myhash
            myhash[param]
          end
        end

        define_method :[] do |param|
          myhash = instance_variable_get :@myhash
          if param.is_a?(Integer)
            myhash.to_a[param][1]
          elsif param.is_a?(String)
            myhash[param.to_sym]
          else
            myhash[param]
          end
        end

        define_method :[]= do |param, value|
          myhash = instance_variable_get :@myhash
          if param.is_a?(Integer)
            myhash.to_a[param][1] = value
          elsif param.is_a?(String)
            myhash[param.to_sym] = value
          else
            myhash[param] = value
          end
        end

        def to_a
          myhash = instance_variable_get :@myhash
          myhash.values
        end

        def ==(other)
          self.class == other.class && to_a == other.to_a
        end

        def size
          myhash = instance_variable_get :@myhash
          myhash.size
        end

        def each(&methods)
          to_a.each(&methods)
        end

        define_method :members do
          params
        end

        def each_pair(&methods)
          members.zip(to_a).each(&methods)
        end

        def values_at(*indexes)
          to_a.values_at(*indexes)
        end

        def dig(*keys)
          keys.inject(self) { |values, key| values[key] if values }
        end

        def select(&methods)
          to_a.select(&methods)
        end

        alias_method :length, :size

        alias_method :eql?, :==

        class_eval &methods if block_given?
      end
    end
  end
end
