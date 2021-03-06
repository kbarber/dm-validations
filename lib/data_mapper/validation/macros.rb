# -*- encoding: utf-8 -*-

require 'data_mapper/validation/rule'

require 'data_mapper/validation/rule/absence'
require 'data_mapper/validation/rule/acceptance'
require 'data_mapper/validation/rule/block'
require 'data_mapper/validation/rule/confirmation'
require 'data_mapper/validation/rule/format'
require 'data_mapper/validation/rule/length'
require 'data_mapper/validation/rule/method'
require 'data_mapper/validation/rule/numericalness'
require 'data_mapper/validation/rule/presence'
require 'data_mapper/validation/rule/primitive_type'
require 'data_mapper/validation/rule/uniqueness'
require 'data_mapper/validation/rule/within'

module DataMapper
  module Validation
    module Macros
      def self.extract_options(arguments)
        arguments.last.kind_of?(Hash) ? arguments.pop : {}
      end

      # Validates that the specified attribute is "blank" via the
      # attribute's #blank? method.
      #
      # @note
      #   dm-core's support lib adds the #blank? method to many classes,
      # @see lib/dm-core/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :unwanted_attribute, String
      #     property :another_unwanted, String
      #     property :yet_again, String
      #
      #     validates_absence_of :unwanted_attribute
      #     validates_absence_of :another_unwanted, :yet_again
      #
      #     # a call to #validate will return false unless
      #     # all three attributes are blank
      #   end
      #
      def validates_absence_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Absence, attribute_names, options)
      end

      # Validates that the attributes's value is in the set of accepted
      # values.
      #
      # @option [Boolean] :allow_nil (true)
      #   true if nil is allowed, false if not allowed.
      #
      # @option [Array] :accept (["1", 1, "true", true, "t"])
      #   A list of accepted values.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :license_agreement_accepted, String
      #     property :terms_accepted, String
      #     validates_acceptance_of :license_agreement, :accept => "1"
      #     validates_acceptance_of :terms_accepted, :allow_nil => false
      #
      #     # a call to valid? will return false unless:
      #     # license_agreement is nil or "1"
      #     # and
      #     # terms_accepted is one of ["1", 1, "true", true, "t"]
      #
      def validates_acceptance_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Acceptance, attribute_names, options)
      end

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
      def validates_with_block(*attribute_names, &block)
        unless block_given?
          raise ArgumentError, 'You need to pass a block to validates_with_block'
        end

        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Block, attribute_names, options, &block)
      end

      # Validates that the given attribute is confirmed by another
      # attribute. A common use case scenario is when you require a user to
      # confirm their password, for which you use both password and
      # password_confirmation attributes.
      #
      # @option [Boolean] :allow_nil (true)
      #   true or false.
      #
      # @option [Boolean] :allow_blank (true)
      #   true or false.
      #
      # @option [Symbol] :confirm (firstattr_confirmation)
      #   The attribute that you want to validate against.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :password, String
      #     property :email, String
      #     attr_accessor :password_confirmation
      #     attr_accessor :email_repeated
      #
      #     validates_confirmation_of :password
      #     validates_confirmation_of :email, :confirm => :email_repeated
      #
      #     # a call to valid? will return false unless:
      #     # password == password_confirmation
      #     # and
      #     # email == email_repeated
      #
      def validates_confirmation_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Confirmation, attribute_names, options)
      end

      # Validates that the attribute is in the specified format. You may
      # use the :as (or :with, it's an alias) option to specify the
      # pre-defined format that you want to validate against. You may also
      # specify your own format via a Proc or Regexp passed to the the :as
      # or :with options.
      #
      # @option [Boolean] :allow_nil (true)
      #   true or false.
      #
      # @option [Boolean] :allow_blank (true)
      #   true or false.
      #
      # @option [Format, Proc, Regexp] :as
      #   The pre-defined format, Proc or Regexp to validate against.
      #
      # @option [Format, Proc, Regexp] :with
      #   An alias for :as.
      #
      #   :email_address (format is specified in DataMapper::Validation::Format::Email - note that unicode emails will *not* be matched under MRI1.8.7)
      #   :url (format is specified in DataMapper::Validation::Format::Url)
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :email, String
      #     property :zip_code, String
      #
      #     validates_format_of :email, :as => :email_address
      #     validates_format_of :zip_code, :with => /^\d{5}$/
      #
      #     # a call to valid? will return false unless:
      #     # email is formatted like an email address
      #     # and
      #     # zip_code is a string of 5 digits
      #
      def validates_format_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Format, attribute_names, options)
      end

      # Validates that the length of the attribute is equal to, less than,
      # greater than or within a certain range (depending upon the options
      # you specify).
      #
      # @option [Boolean] :allow_nil (true)
      #   true or false.
      #
      # @option [Boolean] :allow_blank (true)
      #   true or false.
      #
      # @option [Boolean] :minimum
      #   Ensures that the attribute's length is greater than or equal to
      #   the supplied value.
      #
      # @option [Boolean] :min
      #   Alias for :minimum.
      #
      # @option [Boolean] :maximum
      #   Ensures the attribute's length is less than or equal to the
      #   supplied value.
      #
      # @option [Boolean] :max
      #   Alias for :maximum.
      #
      # @option [Boolean] :equals
      #   Ensures the attribute's length is equal to the supplied value.
      #
      # @option [Boolean] :is
      #   Alias for :equals.
      #
      # @option [Range] :in
      #   Given a Range, ensures that the attributes length is include?'ed
      #   in the Range.
      #
      # @option [Range] :within
      #   Alias for :in.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property high, Integer
      #     property low, Integer
      #     property just_right, Integer
      #
      #     validates_length_of :high, :min => 100000000000
      #     validates_length_of :low, :equals => 0
      #     validates_length_of :just_right, :within => 1..10
      #
      #     # a call to valid? will return false unless:
      #     # high is greater than or equal to 100000000000
      #     # low is equal to 0
      #     # just_right is between 1 and 10 (inclusive of both 1 and 10)
      #
      def validates_length_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Length, attribute_names, options)
      end

      # Validate using method called on validated object. The method must
      # to return either true, or a pair of [false, error message string],
      # and is specified as a symbol passed with :method option.
      #
      # This validator does support multiple attribute_names being specified at a
      # time, but we encourage you to use it with one property/method at a
      # time.
      #
      # Real world experience shows that method validation is often useful
      # when attribute needs to be virtual and not a property name.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #  class Page
      #    include DataMapper::Resource
      #
      #    property :zip_code, String
      #
      #    validates_with_method :zip_code,
      #                          :method => :in_the_right_location?
      #
      #    def in_the_right_location?
      #      if @zip_code == "94301"
      #        return true
      #      else
      #        return [false, "You're in the wrong zip code"]
      #      end
      #    end
      #
      #    # A call to valid? will return false and
      #    # populate the object's errors with "You're in the
      #    # wrong zip code" unless zip_code == "94301"
      #  end
      def validates_with_method(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Method, attribute_names, options)
      end

      # Validate whether a field is numeric.
      #
      # @option [Boolean] :allow_nil
      #   true if number can be nil, false if not.
      #
      # @option [Boolean] :allow_blank
      #   true if number can be blank, false if not.
      #
      # @option [String] :message
      #   Custom error message, also can be a callable object that takes
      #   an object (for pure Ruby objects) or object and property
      #   (for DM resources).
      #
      # @option [Numeric] :precision
      #   Required precision of a value.
      #
      # @option [Numeric] :scale
      #   Required scale of a value.
      #
      # @option [Numeric] :gte
      #   'Greater than or equal to' requirement.
      #
      # @option [Numeric] :lte
      #   'Less than or equal to' requirement.
      #
      # @option [Numeric] :lt
      #   'Less than' requirement.
      #
      # @option [Numeric] :gt
      #   'Greater than' requirement.
      #
      # @option [Numeric] :eq
      #   'Equal' requirement.
      #
      # @option [Numeric] :ne
      #   'Not equal' requirement.
      #
      # @option [Boolean] :integer_only
      #   Use to restrict allowed values to integers.
      #
      def validates_numericalness_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Numericalness, attribute_names, options)
      end

      # Validates that the specified attribute is present.
      #
      # For most property types "being present" is the same as being "not
      # blank" as determined by the attribute's #blank? method. However, in
      # the case of Boolean, "being present" means not nil; i.e. true or
      # false.
      #
      # @note
      #   dm-core's support lib adds the blank? method to many classes,
      #
      # @see lib/dm-core/support/blank.rb (dm-core) for more information.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :required_attribute, String
      #     property :another_required, String
      #     property :yet_again, String
      #
      #     validates_presence_of :required_attribute
      #     validates_presence_of :another_required, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are !blank?
      #   end
      def validates_presence_of(*attribute_names)
        options = attribute_names.last.kind_of?(Hash) ? attribute_names.pop : {}
        validation_rules.add(Rule::Presence, attribute_names, options)
      end

      # Validates that the specified attribute is of the correct primitive
      # type.
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Person
      #     include DataMapper::Resource
      #
      #     property :birth_date, Date
      #
      #     validates_primitive_type_of :birth_date
      #
      #     # a call to valid? will return false unless
      #     # the birth_date is something that can be properly
      #     # casted into a Date object.
      #   end
      def validates_primitive_type_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::PrimitiveType, attribute_names, options)
      end

      # Validate the uniqueness of a field
      #
      # TODO: YARDoc for this method
      def validates_uniqueness_of(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Uniqueness, attribute_names, options)
      end

      # Validates that the value of a field is within a range/set.
      #
      # This validation is defined by passing a field along with a :set
      # parameter. The :set can be a Range or any object which responds
      # to the #include? method (an array, for example).
      #
      # @example Usage
      #   require 'dm-validations'
      #
      #   class Review
      #     include DataMapper::Resource
      #
      #     STATES = ['new', 'in_progress', 'published', 'archived']
      #
      #     property :title, String
      #     property :body, String
      #     property :review_state, String
      #     property :rating, Integer
      #
      #     validates_within :review_state, :set => STATES
      #     validates_within :rating,       :set => 1..5
      #
      #     # a call to valid? will return false unless
      #     # the two properties conform to their sets
      #   end
      def validates_within(*attribute_names)
        options = Macros.extract_options(attribute_names)
        validation_rules.add(Rule::Within, attribute_names, options)
      end

    end # module Macros
  end # module Validation
end # module DataMapper
