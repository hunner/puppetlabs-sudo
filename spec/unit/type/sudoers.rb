Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

describe Puppet::Type.type(:sudoers) do
  before(:each) do
    @type = Puppet::Type.type(:sudoers)
    stub_default_provider!(:parsed)
    # these are the initial params used for testing
    @init_params = {
      :ensure => :present,
      :name => :name,
      :comment => :mycomment,
      :type => 'default',
      :parameters => ['1']
      # :target => '/etc/sudoers'
    }
    # these are all of the attributes that exist
    @attributes=[
      :ensure, :name, :comment, :target, :type, 
      :sudo_alias, :items,
      :parameters,
      :users, :hosts, :commands
    ]
    @valid_params = @init_params
  end

  it "should exist" do
    @type.should_not be_nil
  end
  it "should not have valid attributes that are nil" do
    @attributes.each do |attr|
      @type.attrclass(attr).should_not be_nil
    end
  end

  describe 'shared attributes' do
    describe 'ensure' do
      it 'should only accept absent/present' do
        restricted_params(:ensure, [:absent, :present], @valid_params)
      end
    end
    describe 'comment attribute' do
      it 'should accept a value' do
        should_accept(:comment, 'foo')
      end
      it 'should default to empty string' do
        should_default_to(:comment, '')
      end
    end
    describe 'name attribute' do
      it 'should accept a value' do
        should_accept(:name, 'foo')
      end
      it 'should be required' do
        should_require(:name)
      end
    end
  end

  describe "the user alias" do
    before(:each) do
      @alias_params = @init_params.merge({
        :name => 'NAME',
        :type => 'alias',
        :sudo_alias => 'Cmnd_Alias',
        :items => 'item1'
      })
      # set what your valid params are
      @valid_params = @alias_params
    end
    describe 'require attributes' do
      # isrequired in puppet is broken
      #self.should_require([:sudo_alias, :items])
    end
    describe "sudo_alias" do
      it "should only accept certain aliases" do 
        valid= [
          :Cmnd_Alias, :Host_Alias, :User_Alias, :Runas_Alias,
          :Cmnd, :Host, :User, :Runas
        ]
        restricted_params(:sudo_alias, valid, @valid_params)
      end
    end
    describe 'items' do
      it 'should be required' do
        should_require(:items)
      end
      it 'should take a single element' do
        with(valid_params_with({:items => 'one'}))[:items]    .should == ['one']
      end
      it 'should take a single element array' do
        should_accept(:items, ['one'])
      end
      it 'should take an array' do
        should_accept(:items, ['one', 'two'])
      end
    end
    describe 'type' do
      it 'should not accept other type' do
        lambda { with(valid_params_with({:type => 'bad_type'}))}.should raise_error
      end
      it 'should not accept other type' do
        lambda { with(valid_params_with({:type => 'user_spec'}))}.should raise_error
      end
    end
    describe 'name' do 
      it 'should only accept [A-Z]([A-Z][0-9]_)*' do
        lambda { with(valid_params_with({:name => 'name'}))}.should raise_error(Puppet::Error)
      end
    end
  end

  describe 'sudo defaults' do
    before do
      @default_params = @init_params.merge({
        :type => 'default',
        :parameters => 'params'
      })
      # set what your valid params are
      @valid_params = @default_params
    end
    describe 'parameters' do
      it 'should take a single element' do
        with(valid_params_with({:parameters => 'one'}))[:parameters].should == ['one']
      end
      it 'should take a single element array' do
        should_accept(:parameters, ['one'])
      end
      it 'should take an array' do
        should_accept(:parameters, ['one', 'two'])
      end
      it 'should require a parameter' do
        should_require(:parameters)
      end
    end
  end

  describe 'user specs' do
    before do
      # user spec setup
      @spec_params = @init_params.merge({
        :type => 'user_spec',
        :users => 'danbode',
        :hosts => 'coolmachine@awesomeocorp.org', 
        :commands => '/bin/true',
      })
      @valid_params = @spec_params
    end
    describe 'users' do
      it 'should accept an array' do
        should_accept_array(:users, ['alice', 'bob'])
      end
      it 'should not accept Defaults' do
        should_not_accept(:usrs, 'Defaults')
      end
      it 'should be required' do
        should_require(:users)
      end
    end
    describe 'hosts' do
      it 'should accept an array' do
        should_accept_array(:hosts, ['alice', 'bob'])
      end
      it 'should be required' do
        should_require(:hosts)
      end
    end
    describe 'commands' do
      it 'should accept an array' do
        should_accept_array(:commands, ['alice', 'bob'])
      end
      it 'should be required' do
        should_require(:commands)
      end
    end
  end
end
