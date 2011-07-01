# -*- encoding: utf-8 -*-

require 'data_mapper/validations/validator'
require 'data_mapper/validations/validators/method'

module DataMapper
  module Validations
    module Validators

      # TODO: re-implement this in a way that doesn't pollute the validated
      # class. It shouldn't be that hard. Maybe start with this?
      # class Block < Method
      #   def initialize(attribute_name, options = {})
      #     
      #   end
      # end


      # Validate using the given block. The block given needs to return:
      # [result::<Boolean>, Error Message::<String>]
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :zip_code, String
      #
      #     validates_with_block do
      #       if @zip_code == "94301"
      #         true
      #       else
      #         [false, "You're in the wrong zip code"]
      #       end
      #     end
      #
      #     # A call to valid? will return false and
      #     # populate the object's errors with "You're in the
      #     # wrong zip code" unless zip_code == "94301"
      #
      #     # You can also specify field:
      #
      #     validates_with_block :zip_code do
      #       if @zip_code == "94301"
      #         true
      #       else
      #         [false, "You're in the wrong zip code"]
      #       end
      #     end
      #
      #     # it will add returned error message to :zip_code field
      #
      def validates_with_block(*attributes, &block)
        @__validates_with_block_count ||= 0
        @__validates_with_block_count += 1

        # create method and pass it to MethodValidator
        unless block_given?
          raise ArgumentError, 'You need to pass a block to validates_with_block method'
        end

        method_name = "__validates_with_block_#{@__validates_with_block_count}".to_sym
        define_method(method_name, &block)

        options = attributes.last.is_a?(Hash) ? attributes.last.pop.dup : {}
        options[:method] = method_name
        attributes = [method_name] if attributes.empty?

        validators.add(Validators::Method, *attributes + [options])
      end

    end # module Validators
  end # module Validations
end # module DataMapper