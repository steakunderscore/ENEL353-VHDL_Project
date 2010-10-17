#!/usr/bin/env ruby

# Author:
#      Wim Looman
# Copyright:
#      Copyright (c) 2010 Wim Looman
# License:
#      GNU General Public License (see http://www.gnu.org/licenses/gpl-3.0.txt)

def assert(error=nil)
  raise (error || "Assertion Failed!") unless yield
end

# For 8-bit twos complement
def twos_complement(num)
  return 256 + num
end


def logical_operands(chunks)
      y = chunks[1][1..1].to_i
      assert(chunks[1] + " is not a valid register") {y >= 0 && y < 8}
      x = chunks[2][1..1].to_i
      assert(chunks[2] + " is not a valid register") {x >= 0 && x < 8}
      return (y << 5) + x
end


def immediate(chunk, symbols=nil, move_from=nil)
  v = chunk.to_i
  if v == 0 && chunk != "0" && symbols != nil
    assert(chunk + " is not a valid symbol") {symbols.include?(chunk)}
    move_to = symbols[chunk]
    diff = move_to - move_from
    if diff < 1
      diff = twos_complement(diff)
    end
    return diff
  else
    assert(chunk + " is not a valid immediate") {v >= -127 && v < 128}
    if v < 0
      v = twos_complement(v)
    end
    return v
  end
end


def register(chunk, num_registers)
  x = chunk[1..1].to_i
  assert(chunk + " is not a valid register") {x >=0 && x < num_registers}
  return x
end


def auto(chunk)
  if chunk[-1..-1] == "+"
    return 0x08
  elsif chunk[-1..-1] == "-"
    return 0x10
  else
    return 0x00
  end
end


def convert(lines)
  table = first_pass(lines)
  return second_pass(lines, table)
end


def first_pass(lines)
  instruction = 0
  symbols = {}
  lines.each do |line|
    chunks = line.sub(",", " ").split
    case chunks[0]
      when "LDI", "LD", "STI", "ST", "MV", "AND", "OR", "NOT", "XOR", "ADD", "ADC", "SUB", "SBB", "NEG", "CMP", "BEQ", "BNE", "BLT", "BGT", "BC", "BNC", "RJMP", "JMP"
        instruction += 1

      when "label:"
        symbols[chunks[1]] = instruction
    end
  end
  return symbols
end


def second_pass(lines, symbols)
  line_no = 0
  output = []
  lines.each do |line|
    label = line.sub(",", " ").split[0]
    case label
      when "LDI", "LD", "STI", "ST", "MV", "AND", "OR", "NOT", "XOR", "ADD", "ADC", "SUB", "SBB", "NEG", "CMP", "BEQ", "BNE", "BLT", "BGT", "BC", "BNC", "RJMP", "JMP"
        line_no += 1
        output.push(convert_line(line, symbols, line_no))
    end
  end
  return output.flatten
end


def convert_line(line, symbols, line_no)
  chunks = line.sub(",", " ").split#.partition(";")[0].split
  
  case chunks[0]
    when "LDI"
      instruction = 0x21
      x = register(chunks[1], 4)
      v = immediate(chunks[2])
      operands = (v << 2) + x

    when "LD"
      instruction = 0x01 + auto(chunks[2])
      x = register(chunks[1], 8)
      y = register(chunks[2], 3)
      operands = (y << 5) + x

    when "STI"
      instruction = 0x25
      y = register(chunks[1], 3)
      v = immediate(chunks[2])
      operands = (v << 2) + y

    when "ST"
      instruction = 0x05 + auto(chunks[1])
      y = register(chunks[1], 3)
      x = register(chunks[2], 8)
      operands = (y << 5) + x

    when "MV"
      instruction = 0x04
      if chunks[1][0] == 'r'[0] && chunks[2][0] == 'r'[0]
        y = register(chunks[1], 8)
        x = register(chunks[2], 8)
        operands = (y << 5) + x
      elsif chunks[1][0] == 'a'[0]
        y = register(chunks[1], 3)
        x = register(chunks[2], 8)
        n = chunks[1][-1] == 'H' ? 1 : 0
        operands = (1 << 9) + (n << 8) + (y << 5) + x
      elsif chunks[2][0] == 'a'[0]
        y = register(chunks[1], 8)
        x = register(chunks[2], 3)
        n = chunks[2][-1] == 'H' ? 1 : 0
        operands = (1 << 4) + (n << 3) + (y << 5) + x
      else
        # explode
      end

    when "AND"
      instruction = 0x02
      operands = logical_operands(chunks)

    when "OR"
      instruction = 0x06
      operands = logical_operands(chunks)

    when "NOT"
      instruction = 0x0A
      operands = logical_operands(chunks)

    when "XOR"
      instruction = 0x0E
      operands = logical_operands(chunks)

    when "ADD"
      instruction = 0x12
      operands = logical_operands(chunks)

    when "ADC"
      instruction = 0x16
      operands = logical_operands(chunks)

    when "SUB"
      instruction = 0x1A
      operands = logical_operands(chunks)

    when "SBB"
      instruction = 0x1E
      operands = logical_operands(chunks)

    when "NEG"
      instruction = 0x08
      operands = logical_operands(chunks)

    when "CMP"
      instruction = 0x0C
      operands = logical_operands(chunks)

    when "BEQ"
      instruction = 0x23
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "BNE"
      instruction = 0x27
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "BLT"
      instruction = 0x2B
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "BGT"
      instruction = 0x2F
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "BC"
      instruction = 0x33
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "BNC"
      instruction = 0x37
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "RJMP"
      instruction = 0x3B
      v = immediate(chunks[1], symbols, line_no)
      operands = (v << 2)

    when "JMP"
      instruction = 0x2F
      y = register(chunks[1], 3)
      operands = (y << 5)
  end
  opcode = (instruction << 10) + operands
  return [(opcode >> 8), (opcode & 0xFF)]
end


if __FILE__ == $0
  if !(1..2).include?(ARGV.length) || !File.exist?(ARGV[0])
    p "Usage: ruby #{$0} <input_file> [<output_file>]"
   exit 
  end
  
  input = IO.readlines(ARGV[0])

  output = convert(input)
  if ARGV.length == 2:
    File.open(ARGV[1], "wb") do |file|
      output.each do |char|
        file.putc(char)
      end
    end
  else
    output.each do |char|
      $stdout.putc(char)
    end
  end
end
