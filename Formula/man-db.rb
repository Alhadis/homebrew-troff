class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.8.7.tar.xz"
	sha256 "b9cd5bb996305d08bfe9e1114edc30b4c97be807093b88af8033ed1cf9beb326"

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
