class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.9.1.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-2.9.1.tar.xz"
	sha256 "ba3d8afc5c09a7265a8dabfa0e7c1f4b3ab97df9abf1f6810faa8f301056c74f"

	depends_on "libpipeline"

	def install
		system "./configure",
			"--prefix=#{prefix}",
			"--with-systemdtmpfilesdir=no",
			"--with-systemdsystemunitdir=no",
			"--disable-cache-owner",
			"--disable-setuid"

		system "make"
		system "make", "install"
	end

	test do
		ENV["PAGER"] = "cat"
		output = shell_output("#{bin}/man true")
		assert_match "BSD General Commands Manual", output
		assert_match "The true utility always returns with exit code zero", output
	end
end
