#!/usr/bin/ruby

require 'rubygems'
require 'zmq'
require 'pp'

@state = 0 # 0 = run, 5 = stop
@ring_size = 4
Thread.abort_on_exception = true

trap("INT") do
	@state = 4

	exit 0
end

# Command line driven version

@ctx = ZMQ::Context.new(1)

pull_port = ARGV[0]
push_port = ARGV[1]

pull_bind = "tcp://127.0.0.1:#{pull_port}"
push_bind = "tcp://127.0.0.1:#{push_port}"

pull_sock = @ctx.socket(ZMQ::PULL)
push_sock = @ctx.socket(ZMQ::PUSH)

pull_sock.bind(pull_bind)
push_sock.connect(push_bind)

puts "Started #{pull_bind} -> #{push_bind}"
id = pull_port

if ARGV.length > 2
	puts "sending first message from #{id}"
	push_sock.send("#{id}", ZMQ::NOBLOCK)
end

while(@state < 4)
	puts "#{id} Loop_Run"
	msg = ""
	msg = pull_sock.recv(0)
	puts "#{id} Received #{msg}" if msg
	new_message = "#{msg}#{id}"
	puts "Sending : #{new_message}"
	push_sock.send("#{msg}#{id}",ZMQ::NOBLOCK) if msg
	puts "#{id} Sent message"

	sleep 1
end

# Broken auto building version

# @network = []

# puts "Building Network : #{@ring_size} nodes"
# @ring_size.times do |id| 
# 	@network << Thread.new do
# 		sleep id
# 		pull_sock = @ctx.socket(ZMQ::PULL)
# 		push_sock = @ctx.socket(ZMQ::PUSH)
		
# 		base_port = 6000
# 		pull_port = base_port + id
# 		push_port = id < @ring_size - 1 ? base_port + 1 + id : base_port
		
# 		pull_bind = "tcp://127.0.0.1:#{pull_port}"
# 		push_bind = "tcp://127.0.0.1:#{push_port}"

# 		puts "#{id} pull = #{pull_bind}"
# 		puts "#{id} push = #{push_bind}"

# 		pull_sock.bind(pull_bind)
# 		push_sock.connect(push_bind)

# 		puts "Starting #{id}"

# 		# if id == 0
# 		# 	puts "sending first message from #{id}"
# 		# 	push_sock.send("from #{id}", ZMQ::NOBLOCK)
# 		# end

# 		while(@state < 4)
# 			puts "#{id} Loop_Run"
# 			msg = ""
# 			msg = pull_sock.recv(0)
# 			puts "#{id} Received #{msg}" if msg
# 			new_message = "#{msg}#{id}"
# 			puts "Sending : #{new_message}"
# 			push_sock.send("#{msg}#{id}",ZMQ::NOBLOCK) if msg
# 			puts "#{id} Sent message"

# 			sleep 1
# 		end

# 		pull_sock.close
# 		push_sock.close
# 	end
# end



# @network.each do |node|
# 	node.join
# end

@ctx.close