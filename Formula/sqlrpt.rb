class Sqlrpt < Formula
	desc "Render an SQLite query as tbl(1) markup"
	homepage "https://github.com/jklowden/sqlrpt"
	head "https://github.com/jklowden/sqlrpt.git"
	url "https://github.com/jklowden/sqlrpt/archive/47652d09edfd478d342928eada4fbacdb19830ee.tar.gz"
	sha256 "5fdafefeebb5d9342465bdfab863666ecba07e7ba8f2beef53daab9ca2c80969"
	license "BSD-2-Clause"
	version "2017-05-23"
	
	livecheck do
		url "https://api.github.com/repos/jklowden/sqlrpt"
		strategy :page_match do |json|
			json = JSON.parse(json)
			Date.parse(json["pushed_at"]).strftime("%Y-%m-%d")
		end
	end
	
	depends_on "sqlite3" => :build
	
	def install
		system "make", "sqlrpt"
		bin.install "sqlrpt"
		man1.install "sqlrpt.1"
	end
	
	test do
		# Usage message
		assert_equal shell_output("#{bin}/sqlrpt 2>&1 --help", 1), <<~END
			#{bin}/sqlrpt: illegal option -- -
			sqlrpt: sqlrpt [-f format] [-w width] -d dbname -q query
		END
		
		# Input/output
		db = testpath/"movies.db"
		pipe_output "sqlite3 #{db}", <<~SQL
			CREATE TABLE IF NOT EXISTS movies(
				"id"       INTEGER PRIMARY KEY AUTOINCREMENT,
				"title"    TEXT,
				"year"     INTEGER,
				"rating"   REAL     default NULL,
				"rated_on" TEXT(10) default NULL
			);
			INSERT INTO movies("title", "year", "rating", "rated_on") VALUES
				("Nope",       2022, 7,  "2022-08-17"),
				("Apocalypto", 2006, 9,  "2022-08-07"),
				("Nobody",     2021, 10, "2022-05-15"),
				("Prey",       2022, 8,  "2022-08-07");
		SQL
		query = <<~SQL.split.join " "
			SELECT   title, rating
			FROM     movies
			ORDER BY rated_on ASC
			LIMIT    1
		SQL
		table = <<~EOF.strip
			.ll +6.5i
			.TS
			box;
			LBLB
			L N .
			T{
			title
			T}\tT{
			rating
			T}
			_
			T{
			%s
			T}\t%s
			.TE
			.if (\\n(.l < \\n(TW) .tm line length \\n(.l less than table width \\n(TW
		EOF
		result = shell_output("#{bin}/sqlrpt -d #{db} -q '#{query}'")
		assert_equal result.strip, table % %w[Nobody 10.000000]
		
		# Configurable table width
		cmd = "#{bin}/sqlrpt -d #{db} -q 'SELECT * from movies'"
		assert_match /^\.ll \+11\.3i\R/, shell_output("#{cmd} -w 11.3")
		assert_match /^\.ll \+42i\R/,    shell_output("#{cmd} -w 42")
		
		# tbl(1) formatting options
		assert_match /^\.TS\R;\R/,          shell_output("#{cmd} -f ''")
		assert_match /^\.TS\Rdoublebox;\R/, shell_output("#{cmd} -f doublebox")
		
		# printf(3)-formatted columns
		query.sub!(/ ASC /, " DESC ")
		result = shell_output("#{bin}/sqlrpt -d #{db} -q '#{query}' -p 'rating,%02.0f'")
		assert_equal result.strip, table % %w[Nope 07]
	end
end
