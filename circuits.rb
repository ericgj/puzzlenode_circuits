
module Circuits
  extend self
  
  RESULTS = %w(off on)
  
  def evaluate(filename)
    parse(filename).map {|board| RESULTS[board.evaluate]}.join("\n")
  end
  
  def parse(filename)
    File.open(filename) do |f| 
      parse_data(f.read)
    end
  end
  
  def parse_data(data)
    split_boards(data).inject([]) do |boards, raw_lines|
      boards << parse_board(raw_lines)
      boards
    end
  end
  
  private
  
  # split at \n\n
  def split_boards(contents)
    contents.split("\n\n").map {|raw_board| raw_board.split("\n")}
  end
  
  # parse segments from lines in board
  def parse_board(lines)
    i = -1
    Board.new(
      lines.inject([]) do |memo, raw_line|
        memo += segments_from_line(raw_line, i+=1)
        memo
      end
    )
  end
  
  # parse segments from single line
  def segments_from_line(line, row)
    segs = []
    line.gsub(/\s+$/,'').scan(/[AOXN10]-+[\|@]/) do |match|
      segs << Segment.new(match, row, $`.length)
    end
    segs
  end
  
end


module Circuits

  class Board
  
    attr_reader :segments
    
    def initialize(segments)
      @segments = segments
      @breadcrumb = []
    end
    
    def evaluate(root = final_segment)
      return nil unless root
      return root.value.to_i if root.value? 
      root.evaluate( *find_branches(root).map {|branch| evaluate branch} )
    end
    
    def final_segment
      segments.find {|seg| seg.final?}
    end
    
    def to_s
      segments.map {|seg| seg.to_s}.join("\n")
    end
    
    def debug
      i = -1
      @breadcrumb.each do |upper, lower|
        i+=1
        puts ('  ' * i) + (upper ? "#{upper.operator} [#{upper.row},#{upper.first}]: #{upper.value}" : "")
        puts ('  ' * i) + (lower ? "#{lower.operator} [#{lower.row},#{lower.first}]: #{lower.value}" : "")
      end
    end
    
    private
    
    def find_branches(root)
      finder = lambda {|seg| seg.last == root.first}

      upper = segments.select {|seg| seg.row < root.row}.
                       sort {|a,b| b.row <=> a.row}
      lower = segments.select {|seg| seg.row > root.row}.
                       sort {|a,b| a.row <=> b.row}
      
      ret = [ upper.find(&finder), lower.find(&finder) ]
      @breadcrumb.push ret
      return ret
    end
       
  end
  
end

module Circuits

  class Segment < Struct.new(:operator, :value, :row, :first, :last)
    
    def initialize(raw, row, col)
      @raw = raw
      self.row = row
      self.first = col
      self.last = col + raw.length - 1
      parse_segment_type(raw)
      extend_operator_behavior if operator?
    end
    
    def to_s
      (' ' * self.first) + @raw.to_s
    end
    
    def operator?
      !!(self.operator)
    end
    
    def value?
      !!(self.value)
    end
    
    def invalid?
      !operator? && !value?
    end
    
    def final?
      @raw[-1] == '@'
    end
    
    private 
    
    def parse_segment_type(raw)
      case item = raw[0]
      when '1', '0'
        self.value = item
      when 'A', 'O', 'X', 'N'
        self.operator = item
      end      
    end
    
    def extend_operator_behavior
      self.define_singleton_method(:evaluate, OperatorBehavior.const_get(operator))
    end
        
  end
  
  module OperatorBehavior
    A = lambda {|x,y| x.to_i & y.to_i}
    O = lambda {|x,y| x.to_i | y.to_i}
    X = lambda {|x,y| x.to_i ^ y.to_i}
    N = lambda {|x,y| (x || y).to_i ^ 1 }  
  end
  
end

if __FILE__ == $0
  
  $stdout.puts Circuits.evaluate(ARGV[0])
end