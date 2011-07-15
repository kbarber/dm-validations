# -*- encoding: utf-8 -*-

require 'data_mapper/validations/rule/within/range'

module DataMapper
  module Validations
    class Rule
      module Within
        module Range

          class UnboundedBegin < Rule

            include Range

            def violation_type(resource)
              :less_than_or_equal_to
            end

            def violation_data(resource)
              [ range.end ]
            end

          end # class UnboundedBegin

        end # module Range
      end # module Within
    end # class Rule
  end # module Validations
end # module DataMapper
