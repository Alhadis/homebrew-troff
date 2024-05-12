class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://man-db.gitlab.io/man-db/"
	version "2.12.1"
	url "https://download.savannah.gnu.org/releases/man-db/man-db-#{version}.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-#{version}.tar.xz"
	sha256 "ddee249daeb78cf92bab794ccd069cc8b575992265ea20e239e887156e880265"
	license "GPL-2.0-or-later"

	depends_on "libpipeline"
	depends_on "zstd" => :optional
	depends_on "groff"
	depends_on "gdbm" if OS.linux?
	uses_from_macos "zlib"

	head do
		url "https://gitlab.com/man-db/man-db.git", branch: "main"
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
		should_update_config = !conf.exist?
		system "./bootstrap" if build.head?
		system "./configure", *args, *std_configure_args
		system "make"
		system "make", "install"
		inreplace conf, %r{
			(?<=\s|^)
			/var
			(?=$|\s|/)
		}x, var if should_update_config
	end

	# Repair botched remappings from earlier installs
	def post_install
		return unless (conf = etc/"man_db.conf").exist?
		return if File.exist?(var.parent.to_s + var)
		search = %r{
			(?<=\s|^)
			(?:#{Regexp.quote var.parent}){2,}
			/#{Regexp.quote var.basename}
			(/\S*)?
			(?=$|\s|/)
		}x
		if (src = conf.binread).match? search
			oh1 "Repairing prefix duplication in #{conf}"
			conf.binwrite (src.gsub!(search) do |match|
				result = var.to_s + $1
				ohai "#{match} -> #{result}"
				result
			end)
		end
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
