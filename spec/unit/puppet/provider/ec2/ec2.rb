Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

provider_class = Puppet::Type.type(:ec2).provider(:ec2)

describe provider_class do
  before do
    @resource = stub("resource")
    @provider = provider_class.new(@resource)
  end

#  it "should not be suitable if the 'aws' libraries are missing" do
#    Puppet.features.expects(:aws?).returns false
#    provider_class.should_not be_suitable
#  end

#  it "should be suitable if the 'aws' libraries are present" do
#    Puppet.features.expects(:aws?).returns true
#    provider_class.should be_suitable
#  end

#  it "should be present if provided an 'ensure' value of 'present'" do
#    provider_class.new(:ensure => :present).should be_exists
#  end
#
#  it "should be absent if provided an 'ensure' value of 'absent'" do
#    provider_class.new(:ensure => :absent).should_not be_exists
#  end
#
#  it "should be absent if not provided an 'ensure' value" do
#    provider_class.new({}).should_not be_exists
#  end
#
#  it "should be absent if provided with a resource rather than an 'ensure' value" do
#    provider_class.new(@resource).should_not be_exists
#  end

#  it "should accept an instance_id at initialization" do
#    provider_class.new(:instance_id => 50).instance_id.should == 50
#  end
end
