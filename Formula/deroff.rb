class Deroff < Formula
	desc "Remove Roff constructs from a document"
	homepage "http://www.moria.de/~michael/deroff/"
	url "http://www.moria.de/~michael/deroff/deroff-2.0.tar.gz"
	sha256 "e04a91b8311f269683ae881ebb14fe824b3e01c875ef9f469882b5be3de36970"
	license "GPL-2.0-or-later"
	version "2.0"
	depends_on "gettext"
	
	livecheck do
		skip "Not actively developed or maintained"
	end
	
	def install
		ENV.deparallelize
		system "./configure"
		system "make"
		bin.install "deroff"
		man1.install "deroff.1.en" => "deroff.1"
		mkdir_p man/"de/man1"
		(man/"de/man1").install "deroff.1.de" => "deroff.1"
		(share/"locale/de/LC_MESSAGES").install "de.mo" => "deroff.mo"
	end
	
	test do
		lines = %w[NAME deroff remove roff tbl eqn refer and pic constructs from documents]
		assert_match lines     .join("\n"), shell_output("#{bin}/deroff -w  '#{man1}/deroff.1'").strip
		assert_match lines[1..].join("\n"), shell_output("#{bin}/deroff -sw '#{man1}/deroff.1'").strip
	end
end
