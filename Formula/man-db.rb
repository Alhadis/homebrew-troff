class ManDb < Formula
	desc "Modern, featureful implementation of the Unix man page system"
	homepage "https://nongnu.org/man-db/"
	head "https://gitlab.com/cjwatson/man-db.git"
	url "https://download.savannah.nongnu.org/releases/man-db/man-db-2.10.0.tar.xz"
	mirror "https://download-mirror.savannah.gnu.org/releases/man-db/man-db-2.10.0.tar.xz"
	sha256 "0a8629022f7117dc7fc6473c6fdb14913b24b106059bb056abee87dbd6070c79"
	license "GPL-2.0-or-later"
	patch :DATA # TODO: Remove once 2.10.1 is released

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

__END__
diff --git a/src/man.c b/src/man.c
index c91abf15..5d5caaf1 100644
--- a/src/man.c
+++ b/src/man.c
@@ -383,15 +383,18 @@ static error_t parse_opt (int key, char *arg, struct argp_state *state)
 
 		case OPT_WARNINGS:
 #ifdef NROFF_WARNINGS
-			char *s = xstrdup (arg ? arg : default_roff_warnings);
-			const char *warning;
+			{
+				char *s = xstrdup
+					(arg ? arg : default_roff_warnings);
+				const char *warning;
 
-			for (warning = strtok (s, ","); warning;
-			     warning = strtok (NULL, ","))
-				gl_list_add_last (roff_warnings,
-						  xstrdup (warning));
+				for (warning = strtok (s, ","); warning;
+				     warning = strtok (NULL, ","))
+					gl_list_add_last (roff_warnings,
+							  xstrdup (warning));
 
-			free (s);
+				free (s);
+			}
 #endif /* NROFF_WARNINGS */
 			return 0;
