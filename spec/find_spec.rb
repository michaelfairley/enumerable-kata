require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/find', __FILE__)

describe "Enumerable#find" do
  it_behaves_like(:enumerable_find , :find)
end
