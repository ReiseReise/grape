module Grape
  module Util
    require 'pp'
    class StackableValues
      attr_accessor :inherited_values
      attr_reader :new_values
      attr_reader :froozen_values

      def initialize(inherited_values = {})
        @inherited_values = inherited_values
        @new_values = LoggingValue.new
        @froozen_values = {}
      end

      def [](name)
        return @froozen_values[name] if @froozen_values.key? name
        [@inherited_values[name], @new_values[name]].compact.flatten(1)
      end

      def []=(name, value)
        raise if @froozen_values.key? name
        @new_values[name] ||= []
        @new_values[name].push value
      end

      def delete(key)
        new_values.delete key
      end

      attr_writer :new_values

      def keys
        (@new_values.keys + @inherited_values.keys).sort.uniq
      end

      def to_hash
        keys.each_with_object({}) do |(key), result|
          result[key] = self[key].dup
        end
      end

      def freeze_value(key)
        @froozen_values[key] = self[key].freeze
      end

      def initialize_copy(other)
        super
        self.inherited_values = other.inherited_values
        self.new_values = other.new_values.deep_dup
      end
    end
  end
end
