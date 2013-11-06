require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/entries', __FILE__)

describe "Enumerable#to_a" do
  it_behaves_like(:enumerable_entries , :to_a)
end
