require 'pathname'; Pathname.new(__FILE__).realpath.ascend { |x| begin; require (x + 'spec_helper.rb'); break; rescue LoadError; end }

#describe_provider :sudoers, :parsed, :resource => {:path => '/tmp/vcsrepo'} do
describe Puppet::Type.type(:sudoers).provider(:parsed) do 
  before(:each) do
    @provider = Puppet::Type.type(:sudoers).provider(:parsed)
  end
  it 'should not be null' do
    @provider.should_not be_nil
  end

  describe 'setup' do
    it 'should fail if visudo is not in path' do
      ENV['PATH']=''
      @provider = Puppet::Type.type(:sudoers).provider(:parsed)
    end
    it 'should work if visudo is in path' do
    end
  end

#  context "parsing lines" do
#    context "should ignore empty lines" do
#
#    end
#    context "should ignore comment lines" do
#
#    end
#    context "parsing invalid lines" do
#
#    end
#    context "parsing alias lines" do
#
#    end
#    context "parsing user spec lines" do
#      context "prefetch comment NAMEVAR lines for user spec"
#      end
#    end
#    context "parsing defaults lines" do
#
#    end
#  end
#
#  context "dissallow type changes" do
#  # not sure if this requires a type
#  end 
#
#
#  context "Writing lines" do
#    context "write comment lines" do 
#
#    end
#    context "write blank lines" do
#
#    end
#    context "write user alias lines" do
#   
#    end
#    context "write user spec lines" do
#
#    end
#    context "write defaults lines" do
#
#    end
#    context "fail for invalid types" do
#
#    end
#    context "fail for invalid lines" do
#
#    end
#  end
end

