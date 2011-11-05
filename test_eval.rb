require 'minitest/spec'
require 'minitest/autorun'
require "#{File.dirname(__FILE__)}/circuits"

describe 'Circuits::Segment.evaluate' do

  [['AND Segment', 'SegmentA', 1, 0, 0, 0],
   ['OR Segment',  'SegmentO', 1, 1, 1, 0],
   ['XOR Segment', 'SegmentX', 0, 1, 1, 0],
   ['NOT Segment', 'SegmentN', 0, 0, 1, 1]
  ].each do |desc, fixture, *expected|
    
    describe desc do

      before do
        @subject = Circuits::Segment.new(Fixtures.const_get(fixture), 0, 0)
      end

      it 'should evaluate 1, 1 correctly' do
        assert_equal expected[0], @subject.evaluate('1','1')
      end
      
      it 'should evaluate 1, 0 correctly' do
        assert_equal expected[1], @subject.evaluate('1','0')
      end
      
      it 'should evaluate 0, 1 correctly' do
        assert_equal expected[2], @subject.evaluate('0','1')
      end
      
      it 'should evaluate 0, 0 correctly' do
        assert_equal expected[3], @subject.evaluate('0','0')
      end
      
    end
  end
  
end

describe 'Circuits::Board.evaluate' do

  def board(fixture,x,y)
    Circuits::Board.new([
      Circuits::Segment.new(Fixtures.const_get("Segment#{x}"), 0, 0),
      Circuits::Segment.new(Fixtures.const_get(fixture), 1, 10),
      Circuits::Segment.new(Fixtures.const_get("Segment#{y}"), 2, 0)
    ])
  end
  
  [['Simple AND circuit', 'SegmentA', 1, 0, 0, 0],
   ['Simple OR circuit',  'SegmentO', 1, 1, 1, 0],
   ['Simple XOR circuit', 'SegmentX', 0, 1, 1, 0],
   ['Simple NOT circuit', 'SegmentN', 0, 0, 1, 1]
  ].each do |desc, fixture, *expected|
      
    describe desc do
    
      it 'should evaluate 1, 1 correctly' do
        assert_equal expected[0], board(fixture, '1','1').evaluate
      end
      
      it 'should evaluate 1, 0 correctly' do
        assert_equal expected[1], board(fixture, '1','0').evaluate
      end
      
      it 'should evaluate 0, 1 correctly' do
        assert_equal expected[2], board(fixture, '0','1').evaluate
      end
      
      it 'should evaluate 0, 0 correctly' do
        assert_equal expected[3], board(fixture, '0','0').evaluate
      end
    
    end
  end

  describe 'NOT circuit, lower branch' do
  
    before do
      @subject = Circuits::Board.new([
        Circuits::Segment.new(Fixtures::SegmentN, 0, 10),
        Circuits::Segment.new(Fixtures::Segment1, 1, 0)
      ])
    end
    
    it 'should evaluate 1 -> 0' do
      assert_equal 0, @subject.evaluate
    end
    
  end
  
  describe "Two-level board evaluate" do
  
    def board(circuit1, circuit2, final)
      final_segment = Circuits::Segment.new(Fixtures.const_get(final), 4, 20)
      i = -1
      Circuits::Board.new(
        (
         circuit1.segments + 
         [final_segment] + 
         circuit2.segments
        ).map do |seg|
          seg.row = (i+=1)
          seg
        end
      )
    end
    
    def circuit(fixture,x,y)
      Circuits::Board.new([
        Circuits::Segment.new(Fixtures.const_get("Segment#{x}"), 0, 0),
        Circuits::Segment.new(Fixtures.const_get(fixture), 1, 10),
        Circuits::Segment.new(Fixtures.const_get("Segment#{y}"), 2, 0)
      ])
    end

    [[[1,1,1,1],0],
     [[1,1,1,0],0],
     [[1,1,0,1],0],
     [[1,0,1,1],1],
     [[0,1,1,1],1],
     [[1,1,0,0],1],
     [[1,0,1,0],1],
     [[0,1,0,1],1],
     [[0,0,1,1],1],
     [[1,0,0,0],0],
     [[0,1,0,0],0],
     [[0,0,1,0],1],
     [[0,0,0,1],1]
    ].each do |input, expected|
      describe "(AND OR) XOR circuit: #{input.join}" do
      
        before do
          @subject = board( circuit('SegmentA_mid',input[0],input[1]), 
                            circuit('SegmentO_mid',input[2],input[3]), 
                            'SegmentX'
                          )
        end
        
        it "should evaluate correctly" do
          assert_equal expected, @subject.evaluate, "Board:\n#{@subject.to_s}"
          #@subject.debug
        end
        
      end
    end
  
  end
  
end


module Fixtures

SegmentA = 'A---------@'
SegmentO = 'O---------@'
SegmentX = 'X---------@'
SegmentN = 'N---------@'

SegmentA_mid = 'A---------|'
SegmentO_mid = 'O---------|'
SegmentX_mid = 'X---------|'
SegmentN_mid = 'N---------|'

Segment1 = '1---------|'
Segment0 = '0---------|'
  

end
