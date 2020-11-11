class Libpipeline < Formula
	desc "C library for manipulating pipelines of subprocesses"
	homepage "http://libpipeline.nongnu.org/"
	url "https://download.savannah.nongnu.org/releases/libpipeline/libpipeline-1.5.3.tar.gz"
	mirror "https://download-mirror.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.3.tar.gz"
	sha256 "5dbf08faf50fad853754293e57fd4e6c69bb8e486f176596d682c67e02a0adb0"

	depends_on "pkg-config"

	livecheck do
		url "https://download.savannah.nongnu.org/releases/libpipeline/"
		regex /\bhref\s*=.*?libpipeline[-_.](\d+(?:\.\d+)+)\.tar\b/i
	end

	head do
		url "git://git.savannah.nongnu.org/libpipeline.git"
		depends_on "autoconf" => :build
		depends_on "automake" => :build
	end

	def install
		system "./configure", "--prefix=#{prefix}"
		system "make"
		system "make", "install"
	end

	test do
		(testpath/"test.c").write <<~EOS
			#include <stdio.h>
			#include <stdint.h>
			#include <pipeline.h>
			int main(void)
			{
				pipeline *p = pipeline_new_command_args("true", NULL);
				int status = pipeline_run(p);
				return status;
			}
		EOS
		system ENV.cc, "test.c", "-L#{lib}", "-lpipeline", "-I#{include}", "-o", "test"
		system "./test"
	end
end
