require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/take', __FILE__)

ruby_version_is "1.8.7" do
  describe "Enumerable#take" do
    it "requires an argument" do
      lambda{ EnumerableSpecs::Numerous.new.take}.should raise_error(ArgumentError)
    end

    describe "when passed an argument" do
      it_behaves_like :enumerable_take, :take
    end
  end
end
