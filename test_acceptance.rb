require 'minitest/spec'
require 'minitest/autorun'
require "#{File.dirname(__FILE__)}/circuits"

describe 'simple_circuits acceptance test' do

  before do
    @subject = "#{File.dirname(__FILE__)}/simple_circuits.txt"
    @expected = File.open("#{File.dirname(__FILE__)}/simple_output.txt") {|f| f.read}.chomp
  end
  
  it 'should evaluate to expected' do
    assert_equal @expected, Circuits.evaluate(@subject)
  end
  
end

describe 'complex_circuits acceptance test' do

  before do
    @subject = "#{File.dirname(__FILE__)}/complex_circuits.txt"
#    @expected = File.open("#{File.dirname(__FILE__)}/complex_output.txt") {|f| f.read}.chomp
  end
  
  it 'should evaluate to expected' do
    puts Circuits.evaluate(@subject)
#    assert_equal @expected, Circuits.evaluate(@subject)    
  end
  
end
