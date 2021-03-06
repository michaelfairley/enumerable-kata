require 'spec_helper'
require 'fixtures/classes'

ruby_version_is '1.9' do
  describe "Enumerable#each_entry" do
    before :each do
      ScratchPad.record []
      @enum = EnumerableSpecs::YieldsMixed.new
      @entries = [1, [2], [3,4], [5,6,7], [8,9], nil, []]
    end

    it "yields multiple arguments as an array" do
      acc = []
      @enum.each_entry {|g| acc << g}.should equal(@enum)
      acc.should == @entries
    end

    it "returns an enumerator if no block" do
      e = @enum.each_entry
      e.should be_an_instance_of(ENUMERATOR_CLASS)
      e.to_a.should == @entries
    end

    it "passes through the values yielded by #each_with_index" do
      [:a, :b].each_with_index.each_entry { |x, i| ScratchPad << [x, i] }
      ScratchPad.recorded.should == [[:a, 0], [:b, 1]]
    end

    it "raises an Argument error when extra arguments" do
      lambda { @enum.each_entry("one").to_a   }.should raise_error(ArgumentError)
      lambda { @enum.each_entry("one"){}.to_a }.should raise_error(ArgumentError)
    end

    it "passes extra arguments to #each" do
      enum = EnumerableSpecs::EachCounter.new(1, 2)
      enum.each_entry(:foo, "bar").to_a.should == [1,2]
      enum.arguments_passed.should == [:foo, "bar"]
    end
  end
end
