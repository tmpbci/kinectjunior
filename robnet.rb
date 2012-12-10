#
# robnet.rb to access serial port through 13859 local tcp port.
#
# needs serialport for ruby in **ruby1.8**
# To install on OS X follow http://ruby-serialport.rubyforge.org/
# on bash : sudo gem install ruby-serialport
# ***** change the serial port name /dev/cu.PL2303-003012FD ****
# Launch with : ruby robnet.rb
# to test the serial link : 
# telnet localhost 13859
# cid 2
# go 500 100
require 'socket'
require 'rubygems'
require 'serialport'
serial = SerialPort.new "/dev/cu.PL2303-003012FD", 57600
server = TCPServer.new 13859
loop do 
	client = server.accept
	client.each_line do |line|
		puts line
		p serial.write(line + "\r\n")
	end
end
