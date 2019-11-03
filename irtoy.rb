require 'rubyserial'
require 'io/console'

NO_ACTIVITY = [255, 255] # 0xffff

@serialport = Serial.new '/dev/tty.usbmodem00000001'

puts "Sending reset bytes..."
@serialport.write 0.chr
@serialport.write 0.chr
@serialport.write 0.chr
@serialport.write 0.chr
@serialport.write 0.chr
resp = @serialport.read 1000
sleep 0.5

puts "Connecting to IRToy..."
@serialport.write "I"
sleep 0.5
@serialport.write "R"
sleep 0.5
resp = @serialport.read 1000
puts "Status: #{resp}"

@serialport.write "v"
sleep 0.5
resp = @serialport.read 1000
puts "Version: #{resp}"

Thread.new do
  while char = STDIN.getch
    break if char == 'q'
  end
  exit
end

def read_input
  bytes = []
  last_read_empty = false

  loop do
    resp = @serialport.getbyte
    if resp.nil?
      if last_read_empty
        break
      else
        last_read_empty = true
      end
    else
      bytes << resp
    end
  end

  bytes
end

puts "Beginning sampling..."
@serialport.write "s"
@serialport.read 1000

loop do
  ir_input = read_input

  unless ir_input.empty?
    puts "New IR input - Length: #{ir_input.count} bytes"
    puts "-------------"
    puts ir_input.to_s
    puts "-------------"
  end

  sleep 0.5
end

