class Awf < Formula
	desc "The Amazingly Workable Formatter: partial nroff(1) clone written in AWK"
	homepage "http://doc.cat-v.org/henry_spencer/awf/"
	url "http://doc.cat-v.org/henry_spencer/awf/awf.tar.gz"
	mirror "ftp://ftp.freefriends.org/arnold/Awkstuff/awf.tgz"
	mirror "https://web.archive.org/web/20181215070845if_/http://doc.cat-v.org/henry_spencer/awf/awf.tar.gz"
	sha256 "75e8638c1fb8bdb7d70c7564aab4e0de910eea945d6f0ce0285f8645428d243e"
	license "Spencer-94"
	version "2000-10"
	uses_from_macos "awk"
	
	livecheck do
		skip "Not actively developed or maintained"
	end
	
	def install
		# Fix CRLF line-endings
		Dir["*"].each do |path|
			path = Pathname.new(path)
			next unless File.file?(path)
			next if %w[.tar.gz .tgz .tar].include?(path.extname)
			inreplace(path) {|str| str.gsub! /\r\n/, "\n"}
		end
		
		inreplace "awf" do |s|
			s.sub! %r{^PATH=/bin:/usr/bin ; export PATH\R}, ""
			s.gsub! "/usr/lib/awf", libexec
		end
		
		# Unmangle the manual page
		inreplace "awf.1" do |s|
			s.sub! /\A.+?(?=\R\.TH )/m, '.\" t'
			s.sub! /imitation of\R\K/, ".ds Nr \\fInroff\\fR\n"
			s.sub! /^\.LP\R\K/, ".nf\n"
			s.sub! /(?=^\.ES$)/, <<~EOF
				.nr ES 5n
				.de ES
				.PP
				.in +\\\\n(ESu
				.nf
				..
				.de EE
				.in -\\\\n(ESu
				.fi
				.PP
				..
				.de PT
				.ie \\\\n(.$>1 .TP "\\\\$2"
				.el .TP
				.ie !'\\\\$1'' \\\\$1
				.el \\(bu
				..
			EOF
			
			# Update AWFLIB path documented in "FILES" section
			path = libexec.to_s
			path.gsub! /(?<!\\)-/, '\-'
			path.gsub! "'", '/\(aq'
			s.gsub! "/usr/lib/awf", path
		end
		
		prefix.install "README", "COPYRIGHT"
		bin.install "awf"
		man1.install "awf.1"
		libexec.install *%w[
			common
			dev.dumb
			mac.man
			mac.ms
			pass1
			pass2.base
			pass2.man
			pass2.ms
			pass3
		]
	end
	
	test do
		output = pipe_output("#{bin}/awf -man", ".TH FOO 1\n")
		assert_match /^FOO\(1\) +Unix Programmer's Manual +FOO\(1\)$/, output
		
		output = pipe_output("#{bin}/awf -man", ".BI X Y\n")
		assert_match /^X(?:[\b]X){2}_[\b]Y$/, output
	end
end
