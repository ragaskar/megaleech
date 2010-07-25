require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::Config do
  before(:each) do
    path = 'some_path'
    mock_parseconfig(path)
    @config = Megaleech::Config.new(path)

  end
  
  it "should return user data" do
    @config.user.should == 'username'
    @config.password.should == 'password'
  end

  it "#processor should return the class name for the source processor" do
    @config.processor_class_name("TVTorrents.com").should == "TvTorrents"
  end
end
