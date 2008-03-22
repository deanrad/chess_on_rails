namespace :test do

desc "Display tests in human readable format"
task :doc => :environment do
  tests = FileList['test/**/*_test.rb']
  tests.each do |file|
    m = %r".*/([^/].*)_test.rb".match(file)
    puts m[1]+" should:\n" 
    test_definitions = File::readlines(file).select {|line| line =~ /.*def test.*/}
    test_definitions.each do |definition|
      m = %r"test_(should_)?(.*)".match(definition)
      if m[2]!="truth" && !m[2].include?("nodoc_")
              puts " - "+m[2].gsub(/_/," ")
      end
    end
    puts "\n" 
  end
end

end
