require 'spec_helper'
require 'fixtures/classes'
require File.expand_path('../shared/inject', __FILE__)

describe "Enumerable#reduce" do
  ruby_version_is '1.8.7' do
    it_behaves_like :enumerable_inject, :reduce
  end
end
