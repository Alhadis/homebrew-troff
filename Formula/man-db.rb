class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	head "https://git.savannah.gnu.org/git/man-db.git"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.9.4.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-2.9.4.tar.xz"
	sha256 "b66c99edfad16ad928c889f87cf76380263c1609323c280b3a9e6963fdb16756"
	license "GPL-2.0-or-later"

	depends_on "libpipeline"
	depends_on "gettext"
	depends_on "zstd" => :optional
	depends_on "groff"
	uses_from_macos "zlib"

	livecheck do
		url "https://download.savannah.gnu.org/releases/man-db/"
		regex /\bhref\s*=.*?man[-_]db[._-]v?(\d+(?:\.\d+)+)\.tar\b/i
	end

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
