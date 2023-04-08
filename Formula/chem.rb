require_relative "../lib/shell-archive"

class Chem < Formula
	desc "The original AT&T version of the chem(1) preprocessor"
	homepage "https://netlib.org/typesetting/"
	url "https://netlib.org/typesetting/chem", :using => ShellArchive::Downloader
	mirror "https://web.archive.org/web/20210702173030if_/http://netlib.org/typesetting/chem"
	sha256 "32d3c15b89eb84c7d0bd07c5ac1150a64ec6a7252259f569a284cebba7a68749"
	license "Caldera"
	version "v1.0.0"
	patch :DATA

	livecheck do
		skip "Not actively developed or maintained"
	end

	def install
		chmod 0755, "chem"
		inreplace "chem",     "@@HOMEBREW_LIBEXEC_PATH@@",  libexec
		inreplace "chem.awk", "@@HOMEBREW_PKGSHARE_PATH@@", pkgshare
		libexec.install "chem.awk", "chem"
		pkgshare.install "chem.macros", "PS-PEmacros"
		(pkgshare/"examples").install Dir["*.p"]
		bin.install_symlink libexec/"chem" => "ochem"
		restore_readme
		prefix.install "README"
		inreplace "chem.1" do |file|
			file.gsub! "@@HOMEBREW_LIBEXEC_PATH@@",  libexec
			file.gsub! "@@HOMEBREW_PKGSHARE_PATH@@", pkgshare
		end
		man1.install "chem.1" => "ochem.1"
	end
	
	def caveats
		<<~EOF
			To avoid conflicts with newer implementations, this version of chem(1) has
			been installed as "ochem" (short for "old chem"). An unprefixed version of
			the script can be found at #{Formatter.url opt_prefix/"libexec/chem"}.
		EOF
	end
	
	test do
		output = pipe_output("#{bin}/ochem", ".cstart\nbond\n.cend")
		assert_match output, <<~EOS
			.PS
			copy "#{pkgshare}/chem.macros"
				textht = 0.16; textwid = .1; cwid = 0.12
				lineht = 0.2; linewid = 0.2
			Last: 0,0
			
			# bond
			Last: bond(0.2, 90, from Last.e )
			.PE
		EOS
	end

	def restore_readme
		if File.exists? "README"
			header = "\n" + File.read("README", 512)
			return unless header.include? "\n.TH "
			mv "README", "chem.1"
		end
		chunks = Hash.new
		@active_spec.patches[0].contents.split(/^(?=diff )/).each do |chunk|
			lines = chunk.lines
			files = lines[0].sub(/^diff(?:\s+--git)?\s+/, "").strip
			chunks[files.to_sym] = lines
		end
		diff = chunks[:"a/README b/chem.1"]
		return if diff.nil?
		diff = diff.join ""
		cp "chem.1", "chem.1.orig"
		args = %W[patch --no-backup-if-mismatch --unified -Rfsg0 -p1 -i- chem.1]
		Utils.safe_popen_write(*args) { |pipe| pipe.write(diff) }
		touch "chem.1", mtime: @active_spec.downloader.mtime
		mv "chem.1", "README", force: true
		mv "chem.1.orig", "chem.1"
	end
end

__END__
diff --git a/chem b/chem
index 88c6b0c..c36d819
--- a/chem
+++ b/chem
@@ -1,9 +1,10 @@
-for i in $*
+#!/bin/sh
+for i in "$@"
 do
-	if test ! -r $i
+	if test ! -r "$i"
 	then
 		echo "chem: can't open file $i" 1>&2
 		exit 1
 	fi
 done
-awk -f chem.awk $*
+exec awk -f "@@HOMEBREW_LIBEXEC_PATH@@/chem.awk" "$@"
diff --git a/chem.awk b/chem.awk
index dc73000..7477913 100644
--- a/chem.awk
+++ b/chem.awk
@@ -1,5 +1,5 @@
 BEGIN {
-	macros = "/usr/bwk/chem/chem.macros"	# CHANGE ME!!!!!
+	macros = "@@HOMEBREW_PKGSHARE_PATH@@/chem.macros"
 
 	pi = 3.141592654
 	deg = 57.29578
@@ -62,7 +62,7 @@ $1 ~ /^[A-Z].*:$/ {	# label;  falls thru after shifting left
 	shiftfields(1)
 }
 
-$1 ~ /^\"/	{ print "Last: ", $0; last = OTHER; next }
+$1 ~ /^\\"/	{ print "Last: ", $0; last = OTHER; next }
 
 $1 ~ /bond/	{ bond($1); next }
 $1 ~ /^(double|triple|front|back)$/ && $2 == "bond" {
diff --git a/README b/chem.1
--- a/README
+++ b/chem.1
@@ -1,28 +1,11 @@
-INSTALLATION
-
-The file chem invokes chem.awk, which is where the dirty
-work gets done.  chem.awk tells pic to include a copy
-of chem.macros;  you will need to change a pathname on
-the 2nd line of chem.awk.
-
-You need current versions of awk and pic.  In particular,
-your awk has to support functions and your pic has to know
-about the copy statement.  So if you get weird messages
-from either of those, it's time to update.
-
-this version of awk is available from the AT&T Toolchest,
-for a fee of $300.  For more
-information, call 201-522-6900 and log in as "guest".
-The current version of pic is part of the documentor's
-workbench version 2.0, or the typesetter-independent
-troff package;  both of these are available from AT&T
-Software Sales at POBox 25000, Greensboro, NC 27420, 800-828-unix.
-You don't want to know why there are different places and
-different sources.
-
-There are several test files called *.p.
-
-
-INTRODUCTION
-
-"chem" is yet another preprocessor like eqn, pic, etc., 
+.TH CHEM 1 "March 31, 1987"
+.SH NAME
+chem \- troff preprocessor for chemical structure diagrams
+.SH SYNOPSIS
+.br
+.B chem
+files
+.SH DESCRIPTION
+.I
+Chem
+is yet another preprocessor like eqn, pic, etc., 
@@ -34 +17,5 @@
-In a style reminiscent of eqn and pic, diagrams are
+In a style reminiscent of
+.I eqn
+and
+.I pic,
+diagrams are
@@ -36,0 +24 @@
+
@@ -37,0 +26 @@
+
@@ -38,0 +28 @@
+
@@ -39,0 +30 @@
+
@@ -42 +33 @@
-.cstart and .cend is converted into pic commands to
+\&.cstart and .cend is converted into pic commands to
@@ -46,0 +38 @@
+.nf
@@ -51,0 +44 @@
+.fi
@@ -60,8 +52,0 @@
-(By the way, chem needs the current version of awk;
-you will get some mysterious error messages from awk
-if your version is too old.  You will also profit from
-having sensible and consistent definitions for the PS
-and PE macros.)
-
-
-THE LANGUAGE
@@ -68,0 +54 @@
+.SH THE LANGUAGE
@@ -75,0 +62 @@
+.B
@@ -92,0 +80 @@
+.nf
@@ -99,0 +88 @@
+.fi
@@ -105 +94 @@
-
+.B
@@ -119,0 +109 @@
+.nf
@@ -121,0 +112 @@
+.fi
@@ -124,0 +116 @@
+.nf
@@ -126,0 +119 @@
+.fi
@@ -128 +121 @@
-
+.B
@@ -147 +140 @@
-
+.B
@@ -154,0 +148 @@
+.nf
@@ -157,0 +152 @@
+.fi
@@ -164,0 +160 @@
+.nf
@@ -166,0 +163 @@
+.fi
@@ -174,0 +172 @@
+.nf
@@ -176,0 +175 @@
+.fi
@@ -200 +199 @@
-
+.B
@@ -208,0 +208 @@
+.nf
@@ -210,0 +211 @@
+.fi
@@ -232,2 +233,19 @@
-WISH LIST
-
+.SH FILES
+.nf
+@@HOMEBREW_LIBEXEC_PATH@@/chem.awk	awkscript for chem
+@@HOMEBREW_PKGSHARE_PATH@@/chem.macros	pic(1) marcros
+.fi
+.SH SEE ALSO
+ditroff(1), dieqn(1), pic(1)
+.br
+.I
+John L. Bentley, Lynn W. Jelinsky, Brian W Kernighan,
+CHEM\-A Program for Typesetting Chemical Diagrams: User Manual, 17 April 1986
+.SH BUGS
+.I Chem
+needs the current version of awk;
+you will get some mysterious error messages from awk
+if your version is too old.  You will also profit from
+having sensible and consistent definitions for the PS
+and PE macros.
+.SH WISH LIST
@@ -261,10 +278,0 @@
-
-
-COMPLAINTS
-
-If something doesn't work, or if you can see a way to
-make something better, let us know.
-
-	jon bentley
-	lynn jelinski
-	brian kernighan
