Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

describe Puppet::Type.type(:sudoers) do
  before do
    @type = Puppet::Type.type(:sudoers)
    stub_default_provider!
    @init_params = {
      :ensure => :present,
      :name => :name,
      :comment => :mycomment
      # :target => '/etc/sudoers'
    }
    # user spec setup
    @spec_params = default_params.merge({
      :type => 'user_spec',
      :users => 'danbode',
      :hosts => 'coolmachine@awesomeocorp.org', 
      :commands => '/bin/true',
    })
    # sudo alias setup
    @vaild_aliases = [
      :Cmnd_Alias, :Host_Alias, :User_Alias, :Runas_Alias
    ]
    @valid_aliases_short = [
      :Cmnd, :Host, :User, :Runas
    ]
    @alias_params = default_params.merge({
      :type => 'alias',
      :sudo_alias => 'Cmnd_Alias',
      :items => 'item1'
    })
    # defaults setup
    @default_params = default_params.merge({
      :type => 'defaults',
      :parameters => 'params'
    })
  end

  it "should exist" do
    puts @type
    putes @init_params
    @type.should_not be_nil
  end

  describe "the name parameter" do
    puts @type
    puts @init_params
    @valid_params = @init_params.merge(@alias_params)
    it "should exist" do
       @type.attrclass(:name).should_not be_nil
    end
    it 'should be required' do
      specifying(valid_params_without(:name)).should raise_error(Puppet::Error)
    end
    # valid values depend on type.
  end

#  describe "the user parameter" do
#    it "should exist" do
#       @type.attrclass(:user).should_not be_nil
#    end
#    it 'should support setting a value' do
#      with(valid_params)[:user].should == valid_params[:user]
#    end
#    # I think isrequired is broken
#    it 'should be required' do
#      specifying(valid_params_without(:user)).should raise_error(Puppet::Error)
#    end
#  end
#
#  describe "the password parameter" do
#     it "should exist" do
#       @type.attrclass(:password).should_not be_nil
#    end
#    it 'should support setting a value' do
#      with(valid_params)[:password].should == valid_params[:password]
#    end
#    it 'should be required' do
#      specifying(valid_params_without(:password)).should raise_error(Puppet::Error)
#    end
#  end
#  
#  describe "the image parameter" do
#     it "should exist" do
#       @type.attrclass(:image).should_not be_nil
#    end
#    it 'should be required' do
#      specifying(valid_params_without(:image)).should raise_error(Puppet::Error)
#    end
#    it 'should support setting a value' do
#      with(valid_params)[:image].should == valid_params[:image]
#    end
#  end
#
#  describe "the desc parameter" do
#     it "should exist" do
#       @type.attrclass(:desc).should_not be_nil
#    end
#    it 'should not be required' do
#      specifying(valid_params_without(:desc)).should_not raise_error(Puppet::Error)
#    end
#    it 'should accept a value' do
#      with(valid_params)[:desc].should == 'description'
#    end
#  end
#
#  describe 'the type parameter' do
#    it 'should exist' do
#      @type.attrclass(:type).should_not be_nil
#    end
#    it 'should accept valid ec2 types' do
#      @valid_types.each do |t|
#        with(valid_params_with({:type => t}))[:type].should == t
#      end
#    end
#    it 'should not accept invalid types' do
#      specifying(:type => 'm1.freakin-huge').should raise_error(Puppet::Error) 
#    end
#    it 'should default to m1.small' do
#      with(valid_params_without(:type)) do |resource|
#        resource[:type].should == 'm1.small'
#      end
#    end
#  end
#  describe "when specifying the 'ensure' parameter" do
#    it "should exist" do
#      @type.attrclass(:ensure).should_not be_nil
#    end
#    it "should support 'present' as a value" do
#      with(valid_params_with({:ensure => :present}))[:ensure].should == :present
#    end
#    it "should support 'absent' as a value" do
#      with(valid_params.merge(:ensure => :absent)) do |resource|
#        resource[:ensure].should == :absent
#      end
#    end
#    it "should not support other values" do
#      specifying(valid_params.merge(:ensure => :foobar)).should raise_error(Puppet::Error)
#    end
#    it 'should not be required' do
#      specifying(valid_params_without(:ensure)).should_not raise_error(Puppet::Error)
#    end
#  end
end
