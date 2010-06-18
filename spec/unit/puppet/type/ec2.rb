Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

describe Puppet::Type.type(:ec2) do
  before do
    @type = Puppet::Type.type(:ec2)
    stub_default_provider!
    @valid_types = [ 
      'm1.small', 'm1.large', 'm1.xlarge',
      'm2.xlarge', 'm2.2xlarge', 'm2.4xlarge', 
      'c1.medium', 'c1.xlarge'
    ]
    @valid_params = {
      :name => :name,
      :ensure => :present,
      :user => 'user',
      :password => 'password',
      :image => 'image',
      :desc => 'description'

    }
  end

  it "should exist" do
    @type.should_not be_nil
  end

  describe "the name parameter" do
    it "should exist" do
       @type.attrclass(:name).should_not be_nil
    end
    it 'values should be prefixed with PUPPET_' do
      with(valid_params)[:name].should == "PUPPET_#{valid_params[:name]}"
    end
    it 'should be required' do
      specifying(valid_params_without(:name)).should raise_error(Puppet::Error)
    end
  end

  describe "the user parameter" do
    it "should exist" do
       @type.attrclass(:user).should_not be_nil
    end
    it 'should support setting a value' do
      with(valid_params)[:user].should == valid_params[:user]
    end
    # I think isrequired is broken
    it 'should be required' do
      specifying(valid_params_without(:user)).should raise_error(Puppet::Error)
    end
  end

  describe "the password parameter" do
     it "should exist" do
       @type.attrclass(:password).should_not be_nil
    end
    it 'should support setting a value' do
      with(valid_params)[:password].should == valid_params[:password]
    end
    it 'should be required' do
      specifying(valid_params_without(:password)).should raise_error(Puppet::Error)
    end
  end
  
  describe "the image parameter" do
     it "should exist" do
       @type.attrclass(:image).should_not be_nil
    end
    it 'should be required' do
      specifying(valid_params_without(:image)).should raise_error(Puppet::Error)
    end
    it 'should support setting a value' do
      with(valid_params)[:image].should == valid_params[:image]
    end
  end

  describe "the desc parameter" do
     it "should exist" do
       @type.attrclass(:desc).should_not be_nil
    end
    it 'should not be required' do
      specifying(valid_params_without(:desc)).should_not raise_error(Puppet::Error)
    end
    it 'should accept a value' do
      with(valid_params)[:desc].should == 'description'
    end
  end

  describe 'the type parameter' do
    it 'should exist' do
      @type.attrclass(:type).should_not be_nil
    end
    it 'should accept valid ec2 types' do
      @valid_types.each do |t|
        with(valid_params_with({:type => t}))[:type].should == t
      end
    end
    it 'should not accept invalid types' do
      specifying(:type => 'm1.freakin-huge').should raise_error(Puppet::Error) 
    end
    it 'should default to m1.small' do
      with(valid_params_without(:type)) do |resource|
        resource[:type].should == 'm1.small'
      end
    end
  end
  describe "when specifying the 'ensure' parameter" do
    it "should exist" do
      @type.attrclass(:ensure).should_not be_nil
    end
    it "should support 'present' as a value" do
      with(valid_params_with({:ensure => :present}))[:ensure].should == :present
    end
    it "should support 'absent' as a value" do
      with(valid_params.merge(:ensure => :absent)) do |resource|
        resource[:ensure].should == :absent
      end
    end
    it "should not support other values" do
      specifying(valid_params.merge(:ensure => :foobar)).should raise_error(Puppet::Error)
    end
    it 'should not be required' do
      specifying(valid_params_without(:ensure)).should_not raise_error(Puppet::Error)
    end
  end
end
