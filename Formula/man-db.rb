class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.9.0.tar.xz"
	sha256 "5d4aacd9e8876d6a3203a889860c3524c293c38f04111a3350deab8a6cd3e261"

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
