shared_examples_for :enumerable_find_all do |method_name|
  before :each do
    ScratchPad.record []
    @elements = (1..10).to_a
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns all elements for which the block is not false" do
    @numerous.send(method_name) {|i| i % 3 == 0 }.should == [3, 6, 9]
    @numerous.send(method_name) {|i| true }.should == @elements
    @numerous.send(method_name) {|i| false }.should == []
  end

  ruby_version_is ""..."1.8.7" do
    it "raises a LocalJumpError if no block given" do
      lambda { @numerous.send(method_name) }.should raise_error(LocalJumpError)
    end
  end

  ruby_version_is "1.8.7" do
    it "returns an enumerator when no block given" do
      @numerous.send(method_name).should be_an_instance_of(ENUMERATOR_CLASS)
    end

    it "passes through the values yielded by #each_with_index" do
      [:a, :b].each_with_index.send(method_name) { |x, i| ScratchPad << [x, i] }
      ScratchPad.recorded.should == [[:a, 0], [:b, 1]]
    end
  end

  it "gathers whole arrays as elements when each yields multiple" do
    multi = EnumerableSpecs::YieldsMulti.new
    multi.send(method_name) {|e| e == [3, 4, 5] }.should == [[3, 4, 5]]
  end
end
