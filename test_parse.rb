#require "#{File.dirname(__FILE__)}/test_helper"
require 'minitest/spec'
require 'minitest/autorun'
require "#{File.dirname(__FILE__)}/circuits"

describe 'Circuits.parse_data' do

  [['Single Board, Single Circuit', 'Board1Circuit1'],
   ['Single Board, Single Circuit (Long Branch)', 'Board1Circuit1LongBranch']
  ].each do |desc, fixture|
    describe desc do
      
      before do
        @subject = Circuits.parse_data(Fixtures.const_get(fixture))
      end
      
      it 'should parse as one board' do
        assert_equal 1, @subject.length
      end
      
      it 'board should parse as 3 segments' do
        assert_equal 3, @subject[0].segments.length
      end
      
      it 'first segment should be 1----------|' do
        assert_equal "1----------|", @subject[0].segments[0].to_s
      end
      
      it 'first segment should have operator = nil, value = 1, first = 0, last = 11' do
        assert_nil @subject[0].segments[0].operator
        assert_equal "1", @subject[0].segments[0].value
        assert_equal 0, @subject[0].segments[0].first
        assert_equal 11, @subject[0].segments[0].last        
      end
      
      it 'second segment should be A----------@' do
        assert_equal "A----------@", @subject[0].segments[1].to_s
      end
      
      it 'second segment should have operator = A value = nil, first = 11, last = 22' do
        assert_equal "A", @subject[0].segments[1].operator
        assert_nil @subject[0].segments[1].value
        assert_equal 11, @subject[0].segments[1].first
        assert_equal 22, @subject[0].segments[1].last        
      end
      
      it 'third segment should be 0----------|' do
        assert_equal "0----------|", @subject[0].segments[2].to_s
      end
      
      it 'third segment should have operator = nil, value = 0, first = 0, last = 11' do
        assert_nil @subject[0].segments[2].operator
        assert_equal "0", @subject[0].segments[2].value
        assert_equal 0, @subject[0].segments[2].first
        assert_equal 11, @subject[0].segments[2].last        
      end
      
      it 'board should have one final segment' do
        assert_equal 1, @subject[0].segments.select {|seg| seg.final?}.length
      end

      if fixture == 'Board1Circuit1'      
        it 'first segment should have row = 0' do
          assert_equal 0, @subject[0].segments[0].row
        end
        
        it 'second segment should have row = 1' do
          assert_equal 1, @subject[0].segments[1].row
        end

        it 'third segment should have row = 2' do
          assert_equal 2, @subject[0].segments[2].row
        end
      end
            
      if fixture == 'Board1Circuit1LongBranch'      
        it 'first segment should have row = 0' do
          assert_equal 0, @subject[0].segments[0].row
        end
        
        it 'second segment should have row = 1' do
          assert_equal 1, @subject[0].segments[1].row
        end

        it 'third segment should have row = 4' do
          assert_equal 4, @subject[0].segments[2].row
        end
      end
      
    end
  end
  
  
  %w(Board1Circuit2 
     Board1Circuit2Overlap
     Board1Circuit2TrailingSpace
  ).each do |fixture|
    describe fixture do
  
      before do
        @subject = Circuits.parse_data(Fixtures.const_get(fixture))
      end
      
      it 'board should parse as 7 segments' do
        assert_equal 7, @subject[0].segments.length
      end      
      
      it 'segments should be in order from left to right, up to down' do
        #puts @subject[0].segments.join("\n")
        assert_equal '1-------|', @subject[0].segments[0].to_s
        assert_equal 'A---------|', @subject[0].segments[1].to_s
        assert_equal '1-------|', @subject[0].segments[2].to_s
        assert_equal 'O---------@', @subject[0].segments[3].to_s
        assert_equal '0-------|', @subject[0].segments[4].to_s
        assert_equal 'X---------|', @subject[0].segments[5].to_s
        assert_equal '0-------|', @subject[0].segments[6].to_s
      end
      
      it 'the final segment should have first = 18, last = 28' do
        assert_equal 18, @subject[0].segments[3].first
        assert_equal 28, @subject[0].segments[3].last
      end
      
      if fixture == 'Board1Circuit1LongBranch'        
        it 'the third segment should have operator = nil, value = 1, first = 0, last = 8, row = 2' do
          assert_nil @subject[0].segments[2].operator
          assert_equal "1", @subject[0].segments[2].value
          assert_equal 0, @subject[0].segments[2].first
          assert_equal 8, @subject[0].segments[2].last
          assert_equal 2, @subject[0].segments[2].row
        end
      end
      
    end
  end
  
  
  describe 'Multiple boards' do
  
    before do
     @subject = Circuits.parse_data(Fixtures.const_get('Board3Circuit1'))
    end

    it 'should parse as three boards' do
      assert_equal 3, @subject.length
    end
    
    it 'each board should parse as 3 segments' do
      @subject.each do |board|
        assert_equal 3, board.segments.length
      end
    end
    
  end
  
  
end


module Fixtures

Board1Circuit1 = <<_____
1----------|
           A----------@
0----------|

_____


Board1Circuit1LongBranch = <<_____
1----------|
           A----------@
           |
           |
0----------|

_____


Board1Circuit2 = <<_____
1-------|
        A---------|
1-------|         |
                  O---------@
0-------|         |
        X---------|
0-------|

_____


Board1Circuit2Overlap = <<_____
1-------|
        A---------|
1-------|         O---------@
                  |
0-------|         |
        X---------|
0-------|

_____
     

Board1Circuit2TrailingSpace = <<_____
1-------|          
        A---------|            
1-------|         O---------@          
                  |                  
0-------|         |
        X---------|             
0-------|           

_____
     
     
Board3Circuit1 = <<_____
0----------------|
                 A----------@
0----------------|

0----------------|
                 A----------@
1----------------|

1----------------|
                 A----------@
1----------------|
_____

     
end
