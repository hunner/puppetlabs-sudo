module Helpers

  TEST_DIR = Pathname.new(__FILE__).parent + '..'
    
  TYPES = {
      :ec2 => :ec2
  }

  def self.included(obj)
    obj.instance_eval { attr_reader :valid_params }
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
  def stub_default_provider!
    unless defined?(@type)
      raise ArgumentError, "@type must be set"
    end
    provider = @type.provider(:ec2)
    @type.stubs(:defaultprovider => provider)
  end

  def fixture(name, ext = '.txt')
    (TEST_DIR + 'fixtures' + "#{name}#{ext}").read
  end
    
end
