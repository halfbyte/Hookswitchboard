require 'test_helper'

class IncomingTest < ActiveSupport::TestCase
  
  def setup
    @json = "{\"name\":\"Test\",\"url\":\"job/Test/\",\"build\":{\"number\":454,\"phase\":\"FINISHED\",\"status\":\"SUCCESS\",\"url\":\"job/Test/454/\"}}"
    @json_parsed = JSON.parse(@json)
    @hash = {'data' => @json}
    @i = Incoming.new(:params => @hash)
  end
  
  
  test "hash_access should return base element" do
    assert_equal @hash, @i.hash_access('params')
  end
  
  test "hash_access should return foo element" do
    assert_equal @hash['data'], @i.hash_access('params.data')    
  end
  
  test "process should parse vars from json" do
    @i.process
    assert_equal(@json_parsed, @i.variables)
  end
  
  
  
  
end
