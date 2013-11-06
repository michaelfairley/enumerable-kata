require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/entries', __FILE__)

describe "Enumerable#entries" do
  it_behaves_like(:enumerable_entries , :entries)
end
