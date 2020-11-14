class Dformat < Formula
	desc "A program for typesetting data formats"
	homepage "https://github.com/sathlan/dformat"
	url "https://github.com/sathlan/dformat/archive/e74ea9a9bf2bdb151be35791d7c58aa842ef284b.zip"
	sha256 "a5f429d8054dc72edc3146955ede37e300182d1df289fd7e46e4661115233109"
	version "v1.0.0"

	livecheck do
		skip "Not actively developed or maintained"
	end

	def install
		inreplace "src/dformat.awk" do |s|
			s.sub! /^gawk /m, "exec awk "
			s.sub! /\A/, "#!/bin/sh\n"
		end
		bin.install "src/dformat.awk" => "dformat"
	end

	test do
		assert_match "Page-Zero Bit", pipe_output("#{bin}/dformat", <<~EOS)
			.begin dformat
			style bitwid .3
			PDP-8 Instr
				0-2 Op code
				3 Indirect Bit
				4 Page-Zero Bit
				5-11 Page Address
			.end
		EOS
	end
end
