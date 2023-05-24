module Dhl::Bcs::V3
  module Buildable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      
      def build(**attributes)
        attr = attributes[underscore(name.split('::').last).to_sym]
        return attr if attr.is_a?(self)
        attr ? new(**attr) : new(**attributes.slice(*self::PROPERTIES).keep_if { |_, value| value })
      end

      def property?(name)
        self::PROPERTIES.include?(name)
      end
      
      private

      # borrowed from rails without acronyms
      def underscore(camel_cased_word)
        return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
        word = camel_cased_word.to_s.gsub('::'.freeze, '/'.freeze)
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
        word.tr!('-'.freeze, '_'.freeze)
        word.downcase!
        word
      end

    end

    def initialize(attributes = {})
      attributes.each do |property, value|
        send("#{property}=", value) if self.class.property?(property)
      end
    end

  end
end
