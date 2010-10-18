#!/usr/bin/env ruby

# Author:
#      Wim Looman
# Copyright:
#      Copyright (c) 2010 Wim Looman
# License:
#      GNU General Public License (see http://www.gnu.org/licenses/gpl-3.0.txt)

require 'rubygems'
require 'serialport'

def serve(program, data_file, sp)
  while 1
    header = sp.getc
    diagnostic_mode = (header >> 2) & 0x03
    instruction = header & 0x01 == 0x01
    address = sp.getc + (sp.getc << 8)

    case (header >> 7) & 0x01 # read/write bit
      when 0x01               # read
        header = 0x82
        header += 0x01 if instruction
        sp.putc(header)
        instruction ? sp.write(program[address]) :
                      sp.write(data_file[address])
        p "Sending data for #{instruction ? "Instruction" : "Data"} bus, address:" +
          "#{address}, data: #{instruction ? program[address] : data_file[address]}"
      when 0x00               # write, doesn't support writing to instruction memory
        data = sp.getc
        data_file[address] = data
        p "Writing data, address: " + address + ", data: " + data_file[address]
    end
  end
end

if __FILE__ == $0
  
  if ARGV.size < 3
    STDERR.print "Usage: ruby #{$0} <device> <baud_rate> <program_file> [<data_file>]\n"
    exit
  end
  
  device = ARGV[0]
  baud_rate = ARGV[1].to_i

  program = Array.new(2**12, 0x00)
  i = 0
  File.open(ARGV[2], 'rb') do |input|
    input.each_byte do |byte|
      program[i] =  byte
      i += 1
    end
  end
  
  data = Array.new(2**15, 0x00)
  File.open(ARGV[3], 'rb') do |input|
    input.each_byte do |byte|
      data += byte
    end
  end if ARGV.size > 3

  sp = SerialPort.new(device, baud_rate, 8, 1, SerialPort::NONE)

  serve(program, data, sp)
end
