# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule'

module DataMapper
  module Validations
    class Rule

      class PrimitiveType < Rule

        def valid?(resource)
          property = get_resource_property(resource, attribute_name)
          value    = resource.validation_property_value(attribute_name)

          value.nil? || property.primitive?(value)
        end

        def violation_type(resource)
          :primitive
        end

        def violation_data(resource)
          property = get_resource_property(resource, attribute_name)

          [ property.primitive ]
        end

      end # class PrimitiveType

    end # class Rule
  end # module Validations
end # module DataMapper
