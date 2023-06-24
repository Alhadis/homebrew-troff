class Neatroff < Formula
	desc "Modern reimplementation of Troff with Unicode and bidirectional text support"
	homepage "http://litcave.rudi.ir/"
	license "ISC"
	patch :DATA
	
	depends_on "ghostscript"
	depends_on "fontforge"
	depends_on "wget" => :build
	
	def install
		resource("neatroff")  .stage { (buildpath/"neatroff") .install Pathname(Dir.pwd).children }
		resource("neatpost")  .stage { (buildpath/"neatpost") .install Pathname(Dir.pwd).children }
		resource("neateqn")   .stage { (buildpath/"neateqn")  .install Pathname(Dir.pwd).children }
		resource("neatmkfn")  .stage { (buildpath/"neatmkfn") .install Pathname(Dir.pwd).children }
		resource("neatrefer") .stage { (buildpath/"neatrefer").install Pathname(Dir.pwd).children }
		resource("troff")     .stage { (buildpath/"troff")    .install Pathname(Dir.pwd).children }
		resource("irfonts")   .stage { (buildpath/"fonts")    .install "irfonts.tar.gz" }
		resource("bfonts")    .stage { (buildpath/"fonts")    .install "bfonts.tar.gz" }
		resource("amsfonts")  .stage { (buildpath/"fonts")    .install "amsfonts.zip" }
		resource("urw-base35").stage do
			file = Dir["*.tar.gz"].first
			(buildpath/"fonts").install file => "urw-base35.tar.gz"
		end
		
		system "make", "BASE=#{opt_pkgshare}", "init_fa"
		system "make", "BASE=#{opt_pkgshare}", "neat"
		system "make", "BASE=#{pkgshare}", "install"
		
		# Reorganise the installed files
		cd pkgshare do
			bin.mkdir unless bin.exist?
			
			# Hoist executables into a single directory
			mv "neateqn/eqn",     bin/"neateqn"
			mv "neatmkfn/mkfn",   bin/"neatmkfn"
			mv "neatpost/pdf",    bin/"neatpdf"
			mv "neatpost/post",   bin/"neatpost"
			mv "neatrefer/refer", bin/"neatrefer"
			mv "neatroff/roff",   bin/"neatroff"
			mv "troff/pic/pic",   bin/"neatpic"
			mv "troff/tbl/tbl",   bin/"neattbl"
			mv "shape/shape",     bin/"shape"
			mv "soin/soin",       bin/"soin"
			mv "share/man",       man
			
			# Remove empty directories and unnecessary junk
			rmdir Dir["{share,shape,soin,neat*,troff{/*,}}"]
			rm_f  Dir["fonts/*.{zip,tar{,.gz},tgz,bz2}"]
			rm_f  Dir["fonts/fonts{,_fa}.sh"]
		end
		
		# Fix advertised install paths
		man1.children.each do |file|
			inreplace file do |s|
				s.gsub! "/usr/share/neatroff/font/devutf", opt_pkgshare/"devutf", false
				s.gsub! "/usr/share/neatroff/font",        opt_pkgshare/"fonts",  false
				s.gsub! "/usr/share/neatroff/",            opt_pkgshare,          false
				s.gsub! "/usr/share/neatroff",             opt_prefix,            false
			end
		end
		
		# Generate PDFs for ancillary documentation
		args = *%W[
			--print-directory
			BASE=#{pkgshare}
			ROFF=#{bin}/neatroff
			POST=#{bin}/neatpost
			PPDF=#{bin}/neatpdf
			EQN=#{bin}/neateqn
			REFR=#{bin}/neatrefer
			PIC=#{bin}/neatpic
			TBL=#{bin}/neattbl
			SOIN=#{bin}/soin
			SHAPE=#{bin}/shape
		]
		system "make", *args, "-C", "demo"
		system "make", *args, "-C", "demo_fa"
		doc.install *Dir["demo{,_fa}/*.*"]
		doc.install doc/"fa.ms"  => "neatroff_fa.ms"
		doc.install doc/"fa.pdf" => "neatroff_fa.pdf"
	end
	
	resource "amsfonts" do
		url "http://www.ams.org/arc/tex/amsfonts.zip", using: :nounzip
		mirror "https://web.archive.org/web/20210925193351/http://www.ams.org/arc/tex/amsfonts.zip"
		mirror "https://www.dropbox.com/s/8tdl91sda23e09c/amsfonts.zip?dl=1"
		sha256 "b09bf2ae2256bda9878e067ee0b740ce20a6dcf3d1637e481fa418e6e0b4156b"
		version "v3.0"
	end
	
	resource "bfonts" do
		url "http://fs.rudi.ir/bfonts.tar.gz", using: :nounzip
		mirror "https://archive.org/download/farsi-fonts/bfonts.tar.gz"
		mirror "https://www.dropbox.com/s/c1wibzc8s9y1hp3/bfonts.tar.gz?dl=1"
		sha256 "af01f4c4a1c29ff0002b9673f3287157c26f478778a47d18a13e766e148980e0"
		version "2016-11-18"
	end
	
	resource "irfonts" do
		url "http://fs.rudi.ir/irfonts.tar.gz", using: :nounzip
		mirror "https://archive.org/download/farsi-fonts/irfonts.tar.gz"
		mirror "https://www.dropbox.com/s/8twqhegkngevn3q/irfonts.tar.gz?dl=1"
		sha256 "907d4866e4d0ebd854d5a855676216b135532dbf6c7acd60f238c912c2790cf5"
		version "2016-11-18"
	end
	
	resource "urw-base35" do
		url "https://github.com/ArtifexSoftware/urw-base35-fonts/archive/20170801.1.tar.gz", using: :nounzip
		mirror "https://web.archive.org/web/20200910150112/https://codeload.github.com/ArtifexSoftware/urw-base35-fonts/tar.gz/20170801.1"
		mirror "https://www.dropbox.com/s/u3t1kvmv7rq72sz/urw-base35.tar.gz?dl=1"
		sha256 "874da009413a9a69175e3a42eb707352e7a1a66ed77868139761f6face220c41"
		version "20170801.1"
	end
	
	stable do
		url "https://github.com/aligrudi/neatroff_make.git", revision: "7cf23e411527a8e85c6fda689523f90b5f03a235"
		version "2023-06-19"
		
		resource "neatroff" do
			url "https://github.com/aligrudi/neatroff.git", revision: "10e1020f58b8210db515113faec8c284f7e8e14e"
			version "2023-06-19"
		end
		
		resource "neatpost" do
			url "https://github.com/aligrudi/neatpost.git", revision: "d95ce8a3ae061634ae77b959b5dc08af78ca066d"
			version "2023-06-17"
		end

		resource "neateqn" do
			url "https://github.com/aligrudi/neateqn.git", revision: "220519bf4a56bf269f842d4f08e4596474fbea38"
			version "2022-10-12"
		end

		resource "neatmkfn" do
			url "https://github.com/aligrudi/neatmkfn.git", revision: "e477744371b17cb5cebe277a94a1b3c599173ffe"
			version "2022-07-26"
		end

		resource "neatrefer" do
			url "https://github.com/aligrudi/neatrefer.git", revision: "0cc4ee1f7206ea0b9218d2ce798ea50344b537f4"
			version "2022-05-27"
		end

		resource "troff" do
			url "https://github.com/aligrudi/troffp9.git", revision: "a0e83966bc6e85197151c51b2c99f2950cce8446"
			version "2022-06-04"
		end
	end
	
	def caveats
		<<~EOF
			Commands have been installed with a "neat" prefix.
			
			Additional documentation and examples can be found in
			#{Formatter.url doc}.
		EOF
	end
	
	test do
		# Help output
		output = shell_output("#{bin}/neatroff --help 2>&1", 1).strip
		assert_match "Usage: neatroff [options] input", output
		assert_match fdir = /\R[ \t]+-Fdir[ \t]+set font directory \((.+)\)$/, output
		assert_match mdir = /\R[ \t]+-Mdir[ \t]+set macro directory \((.+)\)$/, output
		[fdir, mdir].each { |dir| assert_path_exists output.match(dir).captures.last }
		
		output = shell_output("#{bin}/neatpost --help 2>&1", 1).strip
		assert_match "Usage: neatpost [options] <input >output", output
		assert_match fdir = /\R[ \t]+-F[ \t]*dir[ \t]+set font directory \((.+)\)$/, output
		assert_path_exists output.match(fdir).captures.last
		
		output = shell_output("#{bin}/neateqn --help 2>&1", 1).strip
		assert_match "Usage: neateqn [options] <input >output", output
		assert_match /\R[ \t]+-c[ \t]*chars[ \t]+characters that chop equations\Z/, output
		
		output = shell_output("#{bin}/neatrefer --help 2>&1", 1).strip
		assert_match "Usage neatrefer [options] <input >output", output
		assert_match "\tmerge multiple references in a single .[/.] block", output
		assert_match "\tinitials for authors' first and middle names", output
		
		
		# Formatting
		output = pipe_output "#{bin}/neatroff", <<~EOF
			.fp - FR IRNazanin
			.ft FR
			\\(co آ
		EOF
		assert_match /\Ax T utf\nx res \d+ \d+ \d+\nx init\n/, output
		assert_match /\nx trailer\nx stop\Z/, output
		assert_match "©", output
		assert_match "آ", output
		
		ps = pipe_output "#{bin}/neatpost", output
		assert_match /\A%!PS-Adobe/, ps
		assert_match "[/copyright]", ps
		assert_match "[/afii52400]", ps
		assert_match /\A%PDF/, pipe_output("#{bin}/neatpdf", output)
		
		# Preprocessors
		output = pipe_output "#{bin}/neattbl", <<~EOF
			Before
			.br
			.TS
			tab(;);
			l l .
			A;Z
			.TE
			.br
			After
		EOF
		assert_match /^Before\n\.br\n/, output
		assert_match /^\.br\nAfter$/,   output
		assert_match "Table at line 7 file Input is too wide", output
		
		output = pipe_output "#{bin}/neateqn", ".EQ\nsup n\n.EN"
		assert_match '.nr .eqnsz \n(.s', output
		assert_match '.nr .eqnfn \n(.f', output
		
		(testpath/"refs.bib").write <<~EOF
			%L label
			%A Author
			%T Title
			%D 1987
		EOF
		output = pipe_output "#{bin}/neatrefer -me -oXY -p refs.bib", <<~EOF
			Text \\*[XY label]
			.[
			$LIST$
			.]
		EOF
		assert_match 'Text \*[XY 1]',    output
		assert_match /\.ds \[A Author$/, output
		assert_match /\.ds \[D 1987$/,   output
		assert_match /\.ds \[L label$/,  output
		assert_match /\.ds \[T Title$/,  output
	end


	# Synthesise --HEAD version from stable spec (to avoid repeating ourselves)
	main = stable.instance_variable_get :@resource
	rsrc = stable.resources
	head do
		url main.url, main.specs.reject {|key| key == :revision}
		rsrc.each do |name, rsrc|
			strategy = rsrc.instance_variable_get :@download_strategy
			next unless [GitDownloadStrategy, GitHubGitDownloadStrategy].include? strategy
			resources.delete name unless resources[name].is_a? HeadSoftwareSpec
			resource name do
				url rsrc.url, rsrc.specs.reject {|key| key == :revision}
			end
		end
	end

	livecheck do
		url "file:///dev/null"
		strategy :page_match do
			outdated = fetch_outdated_resources
			if outdated.empty?
				[main.version]
			else
				outdated.values.collect {|hash| hash[:version]}.map do |date|
					date = date.strftime("%Y-%m-%d") if date.is_a? Date
					date.to_s
				end.sort[-1..]
			end
		end
		
		# Retrieve a list of resources that have newer versions upstream
		def self.fetch_outdated_resources
			varname = self.instance_variables & %w[@package_or_resource @formula_or_cask].map(&:to_sym)
			formula = self.instance_variable_get varname.first
			
			# List resources that have versioned, GitHub-hosted URLs
			sources = formula.head.resources.map do |name, head|
				url = URI(head.url)
				res = formula.stable.resources[name]
				next unless res && res.specs[:revision] && "github.com" == url.host
				[name, {url: url, rev: res.specs[:revision], version: res.version.to_s}]
			end.compact.to_h
			sources["neatroff_make"] = {
				url: formula.head.url,
				rev: formula.stable.specs[:revision],
				version: formula.stable.version.to_s,
			}
			
			# Prepare the GraphQL query to interrogate GitHub's database
			queries = sources.map do |name, src|
				user, repo = URI(src[:url]).path.split("/")[1..2]
				repo.sub! /\.git$/, ""
				%'#{name}: repository(name: "#{repo}", owner: "#{user}"){ ...head }'
			end.sort
			query = <<~GRAPHQL
				query getLatestCommits{
					#{queries.join("\n\t")}
				}
				fragment head on Repository {
					object(expression: "HEAD"){
						... on Commit {
							authoredDate
							committedDate
							oid
						}
					}
				}
			GRAPHQL
			odebug "Submitting GraphQL query:", query
			
			# Submit query and plough through the results
			response = GitHub::API.open_graphql(query)
			odebug "Received results:", response
			response.map do |name, info|
				next if sources[name][:rev] == oid = info["object"]["oid"]
				local = Date.parse sources[name][:version]
				remote = info["object"].slice("authoredDate", "committedDate")
					.values.map(&Date.method(:parse)).sort.last
				version = remote
				
				# Same date, different commit
				if local == remote
					version = "#{local}.1"
					if sources[name][:version] =~ /^\d{4}-\d{2}-\d{2}\.\K(\d+)$/
						version = "#{local}.#{$1.to_i.succ}"
					end
				
				# This shouldn't happen
				elsif local > remote
					raise RangeError "Resource '#{name}' is newer than its upstream"
				end
				
				[name, {revision: oid, version: version.to_s}]
			end.compact.to_h
		end
	end
end

__END__
diff --git a/fonts/fonts.sh b/fonts/fonts.sh
index c698300..7a0415f 100644
--- a/fonts/fonts.sh
+++ b/fonts/fonts.sh
@@ -13,2 +12,0 @@ HGET="wget -c --no-check-certificate -O"
-echo "Retrieving $URWURL"
-$HGET urw-base35.tar.gz $URWURL
@@ -21,2 +18,0 @@ rm -r urw-base35*/
-echo "Retrieving $AMSURL"
-$HGET amsfonts.zip $AMSURL
diff --git a/fonts/fonts_fa.sh b/fonts/fonts_fa.sh
index 21dbf33..22409b2 100644
--- a/fonts/fonts_fa.sh
+++ b/fonts/fonts_fa.sh
@@ -10,2 +9,0 @@
-echo "Retrieving $FONTURL_IR"
-$HGET irfonts.tar.gz $FONTURL_IR || exit 1
@@ -16,2 +13,0 @@
-echo "Retrieving $FONTURL_B"
-$HGET bfonts.tar.gz $FONTURL_B || exit 1
