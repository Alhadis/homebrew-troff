class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	version "2.11.2"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-#{version}.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-#{version}.tar.xz"
	sha256 "cffa1ee4e974be78646c46508e6dd2f37e7c589aaab2938cc1064f058fef9f8d"
	license "GPL-2.0-or-later"

	depends_on "libpipeline"
	depends_on "zstd" => :optional
	depends_on "groff"
	depends_on "gdbm" if OS.linux?
	uses_from_macos "zlib"

	head do
		url "https://gitlab.com/cjwatson/man-db.git", branch: "main"
		depends_on "autoconf" => :build
		depends_on "automake" => :build
		depends_on "libtool"  => :build
	end

	livecheck do
		url "https://download.savannah.gnu.org/releases/man-db/"
		regex /\bhref\s*=.*?man[-_]db[._-]v?(\d+(?:\.\d+)+)\.tar\b/i
	end

	def install
		conf = etc/"man_db.conf"
		args = %W[
			--localstatedir=#{var}
			--with-config-file=#{conf}
			--disable-silent-rules
			--disable-cache-owner
			--disable-setuid
			--disable-nls
		]
		if OS.linux?
			args << "--with-systemdsystemunitdir=#{etc}/systemd/system"
			args << "--with-systemdtmpfilesdir=#{etc}/tmpfiles.d"
		end
		ENV.append_to_cflags "-std=c99"
		system "./bootstrap" if build.head?
		system "./configure", *args, *std_configure_args
		system "make"
		system "make", "install"
		inreplace conf, "/var", var
	end

	test do
		ENV["PAGER"] = "cat"
		(input = testpath/"brew-test.1").write <<~EOF
			.TH BREW-TEST 1
			.SH NAME
			.ad l
			.ds w3 test
			.ds w1 Just
			.ds w4 fixture
			.ds w2 another
			\\*(w1 \\*(w2 \\*[w3] \\*[w4].
			.SH RETURN VALUE
			.nr $? (5/3)-1
			Hopefully \\n($?.
		EOF
		output = shell_output("#{bin}/man #{input}")
		assert_match /^[ \t]+Just another test fixture\.$/, output
		assert_match /^[ \t]+Hopefully 0\.$/, output
	end
end
