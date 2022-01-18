class HeirloomDoctools < Formula
	desc "Portable, heavily-enhanced versions of troff and related tools"
	homepage "https://n-t-roff.github.io/heirloom/doctools.html"
	url "https://github.com/n-t-roff/heirloom-doctools/releases/download/191015/heirloom-doctools-191015.tar.bz2"
	sha256 "a169912358874ecb396c6ce02d08144db00f0e65b9de528216d5a9addea8a34a"
	head "https://github.com/n-t-roff/heirloom-doctools.git"
	license all_of: %W[
		BSD-4-Clause
		Caldera
		CDDL-1.0
		CDDL-1.1
		ISC
		LGPL-2.1-only
		LPPL-1.0
	]

	def install
		args = %W[
			--print-directory
			PREFIX=#{prefix}
			BINDIR=#{libexec}/bin
			MANDIR=#{libexec}/man
			LIBDIR=#{pkgshare}
			PUBDIR=#{pkgshare}/pub
			MACDIR=#{pkgshare}/tmac
			FNTDIR=#{pkgshare}/font
			TABDIR=#{pkgshare}/nterm
			HYPDIR=#{pkgshare}/hyphen
		]
		system "./configure"
		system "make", *args
		system "make", "install", *args
		(libexec/"bin").children.each do |cmd|
			bin.install_symlink cmd => "heirloom-#{File.basename cmd}"
		end
		(libexec/"man").glob("man*/*").each do |page|
			dir = File.basename(File.dirname page)
			(man/dir).install_symlink page => "heirloom-#{File.basename page}"
		end
		doc.install Dir["doc/*"]
		mkdir_p doc/"examples", verbose: true
		(doc/"examples").install Dir["stuff/{footnotes.tr,demo/*}"]
		(share/"xml").install buildpath/"stuff/odt2tr.xsl"
	end

	test do
		# Assert both nroff(1) and troff(1) report their version correctly
		for exec in ["heirloom-troff", "heirloom-nroff"]
			output = shell_output("#{bin}/#{exec}", "-V")
			assert_match "Heirloom doctools #{exec}", output
		end
	end

	def caveats
		<<~EOF
			Commands and man pages have been installed with an `heirloom-` prefix.
			If you want the unprefixed versions, add the following to your shell's
			startup file:
			
				export PATH="#{Formatter.url opt_prefix/"libexec/bin"}:$PATH"
				export MANPATH="#{Formatter.url opt_prefix/"libexec/man"}:$MANPATH"
			
			Additional documentation and examples can be found in
			#{Formatter.url pkgshare}.
		EOF
	end
end
