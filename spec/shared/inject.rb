shared_examples_for :enumerable_inject do |method_name|
  it "with argument takes a block with an accumulator (with argument as initial value) and the current element. Value of block becomes new accumulator" do
    a = []
    EnumerableSpecs::Numerous.new.send(method_name, 0) { |memo, i| a << [memo, i]; i }
    a.should == [[0, 2], [2, 5], [5, 3], [3, 6], [6, 1], [1, 4]]
    EnumerableSpecs::EachDefiner.new(true, true, true).send(method_name, nil) {|result, i| i && result}.should == nil
  end

  it "produces an array of the accumulator and the argument when given a block with a *arg" do
    a = []
    [1,2].send(method_name, 0) {|*args| a << args; args[0] + args[1]}
    a.should == [[0, 1], [1, 2]]
  end

  ruby_version_is ''...'1.8.7' do
    it "takes only one argument" do
      lambda { EnumerableSpecs::Numerous.new.send(method_name, 0, 1) { |memo, i| i } }.should raise_error(ArgumentError)
    end
  end

  ruby_version_is '1.8.7' do
    it "can take two argument" do
      EnumerableSpecs::Numerous.new(1, 2, 3).send(method_name, 10, :-).should == 4
    end

    it "ignores the block if two arguments" do
      EnumerableSpecs::Numerous.new(1, 2, 3).send(method_name, 10, :-){ raise "we never get here"}.should == 4
    end

    it "can take a symbol argument" do
      EnumerableSpecs::Numerous.new(10, 1, 2, 3).send(method_name, :-).should == 4
    end
  end

  it "without argument takes a block with an accumulator (with first element as initial value) and the current element. Value of block becomes new accumulator" do
    a = []
    EnumerableSpecs::Numerous.new.send(method_name) { |memo, i| a << [memo, i]; i }
    a.should == [[2, 5], [5, 3], [3, 6], [6, 1], [1, 4]]
  end

   it "gathers whole arrays as elements when each yields multiple" do
     multi = EnumerableSpecs::YieldsMulti.new
     multi.send(method_name, []) {|acc, e| acc << e }.should == [[1, 2], [3, 4, 5], [6, 7, 8, 9]]
   end

  it "with inject arguments(legacy rubycon)" do
    # with inject argument
    EnumerableSpecs::EachDefiner.new().send(method_name, 1) {|acc,x| 999 }.should == 1
    EnumerableSpecs::EachDefiner.new(2).send(method_name, 1) {|acc,x| 999 }.should ==  999
    EnumerableSpecs::EachDefiner.new(2).send(method_name, 1) {|acc,x| acc }.should == 1
    EnumerableSpecs::EachDefiner.new(2).send(method_name, 1) {|acc,x| x }.should == 2

    EnumerableSpecs::EachDefiner.new(1,2,3,4).send(method_name, 100) {|acc,x| acc + x }.should == 110
    EnumerableSpecs::EachDefiner.new(1,2,3,4).send(method_name, 100) {|acc,x| acc * x }.should == 2400

    EnumerableSpecs::EachDefiner.new('a','b','c').send(method_name, "z") {|result, i| i+result}.should == "cbaz"
  end

  it "without inject arguments(legacy rubycon)" do
    # no inject argument
    EnumerableSpecs::EachDefiner.new(2).send(method_name) {|acc,x| 999 } .should == 2
    EnumerableSpecs::EachDefiner.new(2).send(method_name) {|acc,x| acc }.should == 2
    EnumerableSpecs::EachDefiner.new(2).send(method_name) {|acc,x| x }.should == 2

    EnumerableSpecs::EachDefiner.new(1,2,3,4).send(method_name) {|acc,x| acc + x }.should == 10
    EnumerableSpecs::EachDefiner.new(1,2,3,4).send(method_name) {|acc,x| acc * x }.should == 24

    EnumerableSpecs::EachDefiner.new('a','b','c').send(method_name) {|result, i| i+result}.should == "cba"
    EnumerableSpecs::EachDefiner.new(3, 4, 5).send(method_name) {|result, i| result*i}.should == 60
    EnumerableSpecs::EachDefiner.new([1], 2, 'a','b').send(method_name){|r,i| r<<i}.should == [1, 2, 'a', 'b']

  end

  it "returns nil when fails(legacy rubycon)" do
    EnumerableSpecs::EachDefiner.new().send(method_name) {|acc,x| 999 }.should == nil
  end
end
