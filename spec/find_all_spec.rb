require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/find_all', __FILE__)

describe "Enumerable#find_all" do
  it_behaves_like(:enumerable_find_all , :find_all)
end
