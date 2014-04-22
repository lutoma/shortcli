#!/usr/bin/env ruby

require 'shortdiary'
require 'date'
require 'tempfile'

def post_editor(template)
	puts "Opening $EDITOR…"
	tempfile = Tempfile.new('shortdiary-post')
	tempfile.write(template)
	tempfile.rewind
	system("$EDITOR \"#{tempfile.path}\"")
	tempfile.read
end

def main()
	begin
		username = File.read('.shortdiary-user').lines.first.chomp
		password = File.read('.shortdiary-pass').lines.first.chomp
	rescue Errno::ENOENT
		abort "Couldn't find username / password file. Please create" \
		".shortdiary-user and .shortdiary-pass files."
	end

	begin
		api = Shortdiary::API.new(username, password)
	rescue Shortdiary::AuthenticationError
		abort "Server returned: Invalid username / password"
	end

	post_today = api.get_post_for(Date.today)

	if post_today
		puts "Found existing post for #{post_today.date}, switching to edit mode."
		post_today.text = post_editor(post_today.text)
	else
		post_today = api.new_post
		post_today.text = post_editor('')
	end

	print "Please enter a mood from 1 to 10: "
	post_today.mood = gets.chomp
	post_today.date = Date.today.to_s

	puts "Storing post…"
	post_today.save
	puts "Done: https://shortdiary.me/posts/#{post_today.id}/"
end

if __FILE__ == $0
	main
end
