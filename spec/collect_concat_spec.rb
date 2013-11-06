require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/collect_concat', __FILE__)

ruby_version_is "1.9" do
  describe "Enumerable#collect_concat" do
    it_behaves_like(:enumerable_collect_concat , :collect_concat)
  end
end
