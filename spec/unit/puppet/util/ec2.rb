Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

require 'puppet/util/ec2'

class Ec2Helper
  include Puppet::Util::Ec2
end

# LAK: This way the constants exist, but I expect we'll regret this
unless Puppet.features.aws?
  class AWS
      class EC2
          class Base
          end
      end
  end
end

describe Puppet::Util::Ec2 do
  before do
    @helper = Ec2Helper.new
  end

  it "should use AWS::Base to create an EC2 connection" do
    AWS::EC2::Base.expects(:new).with(:access_key_id => "myuser", :secret_access_key => "mypass")
    @helper.ec2_connection("myuser", "mypass")
  end

  it "should call foo and bar when calling baz" do
    @helper.stubs(:foo).returns "yay"
    @helper.expects(:bar).with("yay").returns "yip"
    @helper.baz.should == "yip"
  end
end
