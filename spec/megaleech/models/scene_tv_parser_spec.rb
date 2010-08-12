require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))

describe Megaleech::Rtorrent do

  describe "for title.s[0-9]e[0-9] style names" do
    before(:each) do
      @parser = SceneTvParser.new("In.Jail.S03E07.PDTV.XviD-YesTV")
    end

    it "returns the correct title" do
      @parser.title.should == "In Jail"
    end

    it "returns the correct episode" do
      @parser.episode.should == 7

    end

    it "returns the correct season" do
      @parser.season.should == 3
    end
  end

  describe "for title.[0-9]x[0-9] style names" do
    before(:each) do
      @parser = SceneTvParser.new("In.Jail.3x7.PDTV.XviD-YesTV")
    end

    it "returns the correct title" do
      @parser.title.should == "In Jail"
    end

    it "returns the correct episode" do
      @parser.episode.should == 7

    end

    it "returns the correct season" do
      @parser.season.should == 3
    end
  end

  describe "should provide reasonable defaults" do
    describe "for a completely unparsable title" do
      before(:each) do
        @parser = SceneTvParser.new("Not A Scene Title")
      end

      it "returns a reasonable default title" do
        @parser.title.should == "Not A Scene Title"
      end

      it "returns a reasonable default season" do
        @parser.season.should == 0
      end

      it "returns a reasonable default episode" do
        @parser.episode.should == 0
      end
      end
  end
end