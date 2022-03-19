class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	head "https://gitlab.com/cjwatson/man-db.git"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.10.2.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-2.10.2.tar.xz"
	sha256 "ee97954d492a13731903c9d0727b9b01e5089edbd695f0cdb58d405a5af5514d"
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
		ENV.append_to_cflags "-std=c99"
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
