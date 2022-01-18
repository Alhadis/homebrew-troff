class Teqn < Formula
	desc "Convert TeX equations to Neateqn preprocessor markup"
	homepage "https://github.com/mahdiElliot/teqn"
	head "https://github.com/mahdiElliot/teqn.git"
	url "https://github.com/mahdiElliot/teqn/archive/a14a98d5f5b8978fbf0d86b475d513c5e1655666.tar.gz"
	sha256 "6359c3626e6aaf5e19f5aa9c531efb75e6d2d802e7b0c241c5a9075920908d16"
	version "2021-07-10"
	
	livecheck do
		url "https://api.github.com/repos/mahdiElliot/teqn"
		strategy :page_match do |json|
			json = JSON.parse(json)
			Date.parse(json["pushed_at"]).strftime("%Y-%m-%d")
		end
	end
	
	def install
		system ENV.cxx, *%w[-o teqn --std=c++11 project.cpp]
		bin.install "teqn"
		doc.install "README"
	end
	
	test do
		output = pipe_output "teqn", <<~EOS
			.BL
			a \\times \\sqrt{{b ^ 2} ^ 2 \\over {c_1 + d_2}}
			.EL
		EOS
		output.gsub!(/ +$/, "")
		assert_match output, <<~EOS
			.EQ
			a times sqrt { { { b sup 2 } sup 2 } over { { c sub 1 + d sub 2 } } }
			.EN
		EOS
		
		output = pipe_output "teqn", <<~EOS
			.BL
			\\delim <>
			.EL
			MATH: < a + \\alpha ^ \\beta >
		EOS
		output.gsub!(/ +$/, "")
		assert_match output, <<~EOS
			.EQ
			delim <>
			.EN
			MATH: < a + alpha sup beta >
		EOS
	end
end
