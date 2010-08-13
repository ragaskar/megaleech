require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech do

  describe "#processor_class_name" do
    before(:each) do
      #megaleech doesn't cleanup stubs correctly. :(
      @fake_config = Megaleech::Config.new("some_path")
      Megaleech.stub(:config).and_return(@fake_config)
    end

    it "should get constants from Kernel" do
      @fake_config.stub("processor_class_name").and_return("SomeClass")
      some_class_fake = mock("SomeClass")
      Megaleech.should_receive(:const_get).with("SomeClass").and_return(some_class_fake)
      Megaleech.processor_class_name("some string").should == some_class_fake
    end

    it "should handle namespaced constants" do
      @fake_config.stub("processor_class_name").and_return("SomeModule::SomeClass")
      fake_module = mock("Module")
      Megaleech.should_receive(:const_get).with("SomeModule").and_return(fake_module)
      some_class_fake = mock("SomeClass")
      fake_module.should_receive(:const_get).with("SomeClass").and_return(some_class_fake)
      Megaleech.processor_class_name("some other string").should == some_class_fake
    end
  end

end