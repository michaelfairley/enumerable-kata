require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/collect', __FILE__)

describe "Enumerable#collect" do
  it_behaves_like(:enumerable_collect , :collect)
end
