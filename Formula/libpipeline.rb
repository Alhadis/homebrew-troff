class Libpipeline < Formula
	desc "C library for manipulating pipelines of subprocesses"
	homepage "http://libpipeline.nongnu.org/"
	url "https://download.savannah.nongnu.org/releases/libpipeline/libpipeline-1.5.2.tar.gz"
	mirror "https://download-mirror.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.2.tar.gz"
	sha256 "fd59c649c1ae9d67604d1644f116ad4d297eaa66f838e3dfab96b41e85b059fb"

	depends_on "pkg-config"

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
