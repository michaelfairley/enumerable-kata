require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/inject', __FILE__)

describe "Enumerable#inject" do
  it_behaves_like :enumerable_inject, :inject
end
