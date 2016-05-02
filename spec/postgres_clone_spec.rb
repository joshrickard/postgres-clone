require 'spec_helper'

describe Postgres::Clone do
  it 'has a version number' do
    expect(Postgres::Clone::VERSION).not_to be_nil
  end
end
