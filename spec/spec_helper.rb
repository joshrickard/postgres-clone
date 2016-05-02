$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'postgres-clone'

RSpec.configure do |config|
  config.before do
    allow($stdout).to receive(:puts)
  end
end
