module Helpers

  TEST_DIR = Pathname.new(__FILE__).parent + '..'
    
  TYPES = {
      :ec2 => :ec2
  }

  def self.included(obj)
    obj.instance_eval { attr_accessor :valid_params }
  end
  # self is available at the describe level
  def restricted_params(key, params, opts={}, invalid='invalid')
    params.each do |param|
      #let(:param) {param}
      #let(:key) {key}
      with(valid_params_with({key => param}))[key].should == param
    end
    lambda {with(valid_params_with({key => invalid}))}.should raise_error
  end

  # test that a list of attributes are required 
  def should_require(*keys)
    keys.each do |k|
    lambda { with(valid_params_without(k)) }.should raise_error Puppet::Error
    end
  end
  # tests that an attribute should accept a value
  def should_accept(attr, value)
    k=attr.to_sym
    with(valid_params_with({k => value}))[k].should == value
  end
  # tests that an attribute should not accept a value
  def should_not_accept(attr, value)
    k=attr.to_sym
    lambda {with(valid_params_with({k => value}))}.should raise_error Puppet::Error
  end


  # tests that an attribute accepts an array
  #  - single element array, multiple element array
  #  - string is converted into an array
  def should_accept_array(attr, value=['one', 'two'])
    should_accept(attr, value)
    should_accept(attr, value.first.to_a )
    with(valid_params_with({attr => value.first}))[attr].should == value.first.to_a
  end

  # test that an attribute defaults to a value
  def should_default_to(attr, defaultto)
    with(valid_params_without(attr.to_sym))[:comment].should == defaultto
  end

  # Creates a new resource of +type+
  def with(opts = {}, &block)
    resource = @type.new(opts)
    block ? (yield resource) : resource
  end 

  # what is the difference?
    # Returns a lambda creating a resource (ready for use with +should+)
  def specifying(opts = {}, &block)
    specification = lambda { with(opts) }
    block ? (yield specification) : specification
  end 

    # Sets up an expection that a resource for +type+ is not created    
  def should_not_create(type)
    raise "Invalid type #{type}" unless TYPES[type]
     Puppet::Type.type(TYPES[type]).expects(:new).never
  end

  # Sets up an expection that a resource for +type+ is created
  def should_create(type)
    raise "Invalid type #{type}" unless TYPES[type]
      Puppet::Type.type(TYPES[type]).expects(:new).with { |args| yield(args) }
  end

  # Return the +@valid_params+ without one or more keys
  # Note: Useful since resource types don't like it when +nil+ is
  # passed as a parameter value
  def valid_params_without(*keys)
    valid_params.reject { |k, v| keys.include?(k) }
  end

  # yeah! I added this one!
  def valid_params_with(opts = {})
    opts.each { |k, v| valid_params[k] = v}
    valid_params
  end

  # Stub the default provider to get around confines for testing
  def stub_default_provider!(name)
    unless defined?(@type)
      raise ArgumentError, "@type must be set"
    end
    provider = @type.provider(name.to_sym)
    @type.stubs(:defaultprovider => provider)
  end

  def fixture(name, ext = '.txt')
    (TEST_DIR + 'fixtures' + "#{name}#{ext}").read
  end
    
end
#Spec::Example::ExampleGroupFactory.register(:provider, ProviderExampleGroup)
#
# Outside wrapper to lookup a provider and start the spec using ProviderExampleGroup
#def describe_provider(type_name, provider_name, options = {}, &block)
#    provider_class = Puppet::Type.type(type_name).provider(provider_name)
#      describe(provider_class, options.merge(:type => :provider), &block)
#end
