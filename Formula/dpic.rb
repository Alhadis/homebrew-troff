class Dpic < Formula
	desc "Modern PIC implementation with support for LaTeX, PDF, SVG, PostScript, and Xfig 3.2"
	homepage "https://gitlab.com/aplevich/dpic"
	head "#{homepage}.git"
	url "https://gitlab.com/aplevich/dpic/-/archive/a1214483a5a2377542e0e9cee136abae0b46c683/dpic.bz2"
	sha256 "3728f52a0dbbe4c19bc49a0e847ed9590a1eb959cc1ebb08dd3133e120fa12c2"
	license all_of: %W[BSD-2-Clause CC-BY-3.0 LPPL-1.3c]
	version "2023-06-01"
	
	livecheck do
		url "https://gitlab.com/aplevich/dpic/-/raw/HEAD/VERSIONDATE.h"
		strategy :page_match do |src|
			src.scan(/^#define[ \t]+VERSIONDATE[ \t]+"([^"]+)"$/m).map {|v| v.first.tr ".", "-"}
		end
	end
	
	def install
		system *%W[
			make
			DESTDIR=""
			CC=#{ENV.cc}
			CFLAGS=#{ENV.cflags}
			LDFLAGS=#{ENV.ldflags}
			PREFIX=#{prefix}
			install
		]
	end
	
	def caveats
		<<~EOF
			Additional documentation has been installed to:
			  #{Formatter.url doc}
		EOF
	end
	
	test do
		# Usage message
		output = shell_output("#{bin}/dpic -h 2>&1 || :").strip
		assert_match /\A\*{3} dpic version \d{4}(?:\.\d{2}){2}\s/, output
		assert_match /^\s+-v SVG output$/, output
		
		# Input/output
		(testpath/"test.pic").write input = <<~EOF
			.PS
			box "A"
			line <->
			box "Z"
			.PE
		EOF
		output1 = pipe_output "#{bin}/dpic -v", input
		output2 = shell_output "#{bin}/dpic -v #{testpath}/test.pic"
		[output1, output2].each {|x| assert_match %r{
			<svg (?=\s|>)[^>]*> .*?
				<text (?=\s|>)[^>]*> A </text> .*?
				<text (?=\s|>)[^>]*> Z </text> .*?
			</svg> \s*$
		}xm, x}
		
		# Output formats
		Hash[
			d: /\A%PDF-\d+\.\d+/,
			e: '\begin{picture}',
			g: '\begin{tikzpicture}',
			m: '\begin{mfpic}',
			p: '\begin{pspicture}',
			f: /\A%!PS-Adobe-\d+/,
			s: /^beginfig\(.*\)/,
			t: '\begin{picture}',
			v: /<svg\s[^>]*>.+<\/svg>/m,
			x: /^#FIG\s+\d/,
		].each do |flag, pattern|
			output = shell_output("#{bin}/dpic -#{flag} #{testpath}/test.pic")
			assert_match pattern, output
		end
	end
end
