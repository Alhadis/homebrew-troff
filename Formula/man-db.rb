class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	head "https://git.savannah.gnu.org/git/man-db.git"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.9.2.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-2.9.2.tar.xz"
	sha256 "7b383f26c67525205f96a4a3bfb27993396992794adda6fe05ad565f369f047c"

	depends_on "libpipeline"
	depends_on "gettext"
	depends_on "zstd" => :optional

	def install
		args = %W[
			--prefix=#{prefix}
			--with-systemdtmpfilesdir=no
			--with-systemdsystemunitdir=no
			--disable-dependency-tracking
			--disable-silent-rules
			--disable-cache-owner
			--disable-setuid
			--disable-shared
			--enable-static
		]
		system "./configure", *args
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
