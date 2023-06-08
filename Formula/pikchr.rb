class Pikchr < Formula
	desc "Web-friendly PIC interpreter optimised for SVG output"
	homepage "https://pikchr.org/home"
	license "0BSD"
	option "with-tcl-tk", "Build Tcl bindings"
	depends_on "tcl-tk" => :optional
	
	stable do
		url "https://pikchr.org/home/tarball/6d40a5f041311bbe/pikchr.tgz"
		sha256 "ccf47a3d57a7e2ae8ce3d903385fab971b14d7498bdba7e5bc47a13c721738fb"
		version "2023-05-26"
	end
	
	# FIXME: Building --HEAD from a Fossil checkout is currently broken; use GitHub mirror
	head do
		url "https://github.com/drhsqlite/pikchr.git", :branch => "master"
		depends_on "lemon"
	end
	
	livecheck do
		url "https://pikchr.org/home/timeline.rss?y=ci&n=1"
		strategy :page_match do |rss|
			require "rexml/document"
			rss    = REXML::Document.new(rss)
			latest = rss.get_elements("//rss//channel//item").first
			Time.parse(latest.elements["pubDate"].text).strftime("%Y-%m-%d")
		end
	end
	
	def install
		# Running lemon(1) clobbers this header, so install it first
		include.install "pikchr.h"
		
		# Compile standalone executable
		if build.head?
			system Formula["lemon"].bin/"lemon", "pikchr.y"
		else
			system ENV.cc, "-o", "lemon", "lemon.c"
			system "./lemon", "pikchr.y"
		end
		system *%W`#{ENV.cc} pikchr.c -o pikchr -DPIKCHR_SHELL`
		bin.install "pikchr"
		
		# Compile shared library for integration with other projects
		dylib = shared_library("libpikchr")
		flags = %W[-shared -fPIC -lm -Wall]
		system ENV.cc, *flags, "-o", dylib, "pikchr.c"
		lib.install dylib
		
		# Compile Tcl bindings, if requested
		if build.with? "tcl-tk"
			tcl = Formula["tcl-tk"]
			version = tcl.version.major_minor
			flags += %W[
				-DPIKCHR_TCL
				-I#{tcl.opt_include}
				-L#{tcl.opt_lib}
				-ltcl#{version}
			]
			system ENV.cc, *flags, "-o", dylib, "pikchr.c"
			mkdir_p pkg = lib/"piktcl"
			pkg.install dylib
			(pkg/"pkgIndex.tcl").write <<~EOF
				if {![package vsatisfies [package provide Tcl] #{version}]} {return}
				package ifneeded pikchr 1.0 [list load [file join $dir #{dylib}]]
			EOF
		end
	end
	
	def caveats
		return unless build.with? "tcl-tk"
		<<~EOF
			Tcl/Tk bindings have been installed to:
			  #{Formatter.url opt_lib/"piktcl"}
		EOF
	end
	
	test do
		(input = testpath/"test.pikchr").write <<~EOF
			A: circle fill RebeccaPurple
			Z: circle color 0xBBFFDD at 5cm right of previous
			arrow ↔ from A.e to Z.c
		EOF
		html = shell_output("#{bin}/pikchr #{input}").strip
		svg  = shell_output("#{bin}/pikchr --svg-only - < #{input}").strip
		assert_match %r{\A<!DOCTYPE\s+html>\R}i, html
		assert_match %r{\A<svg\s[^>]+>.+</svg>\Z}ims, svg
		
		(testpath/"test.c").write <<~EOF
			#include <stdio.h>
			#include "pikchr.h"
			int main(int argc, char const *argv[]){
				int width    = -1;
				int height   = -1;
				char *input  = "box \\"Text\\"\\0";
				char *output = pikchr(input, "foo", PIKCHR_DARK_MODE, &width, &height);
				printf("%s\\n<!-- Size: %d x %d -->\\n", output, width, height);
				return !(width > 0 && height > 0);
			}
		EOF
		system *%W`#{ENV.cc} test.c -o #{testpath}/test -L#{lib} -lpikchr -I#{include}`
		output = shell_output("#{testpath}/test").strip
		assert_match %r{\A<svg\s[^>]*?class="foo"[^>]*>}i, output
		assert_match %r{<!-- Size: \d+ x \d+ -->\Z}, output
		
		if build.with? "tcl-tk"
			ENV["TCLLIBPATH"] = lib
			tclsh  = Dir[Formula["tcl-tk"].opt_bin/"tclsh*"].first
			output = pipe_output tclsh, <<~EOF
				package require pikchr
				set input "box \\"Text\\""
				set pic [pikchr $input]
				puts  Width:\\\t[lindex $pic 1]
				puts Height:\\\t[lindex $pic 2]
				puts Source:\\\t[lindex $pic 0]
			EOF
			assert_match %r{
				\A Width:  \t \d+
				\R Height: \t \d+
				\R Source: \t <svg\s[^>]*?\s class="pikchr"[^>]*>.+?</svg>
				\s* \Z
			}xm, output
		end
	end
end
