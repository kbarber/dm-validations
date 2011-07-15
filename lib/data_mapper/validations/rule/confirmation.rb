# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Rule

      class Confirmation < Rule

        EQUALIZE_ON = superclass::EQUALIZE_ON.dup << :confirmation_attribute

        attr_reader :confirmation_attribute


        def initialize(attribute_name, options = {})
          super

          allow_nil!   unless defined?(@allow_nil)
          allow_blank! unless defined?(@allow_blank)

          @confirm_attribute_name = options.fetch(:confirm) do
            :"#{attribute_name}_confirmation"
          end
        end

        def valid?(resource)
          value = resource.validation_property_value(attribute_name)
          return true if optional?(value)

          if resource.model.properties.named?(attribute_name)
            return true unless resource.attribute_dirty?(attribute_name)
          end

          confirm_value = resource.instance_variable_get("@#{@confirm_attribute_name}")
          value == confirm_value
        end

        def violation_type(resource)
          :confirmation
        end

      end # class Confirmation

    end # class Rule
  end # module Validations
end # module DataMapper
