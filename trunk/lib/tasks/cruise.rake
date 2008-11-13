namespace :metrics do
  TEST_PATHS_FOR_RCOV = ['spec/**/*_spec.rb']
  RCOV_OPTIONS = {'--exclude' => 'spec/*,gems/*,lib/auth*',  '--rails' => '' }
  
end

desc "Task for CruiseControl.rb"
task :cruise => [ "db:migrate",
                  "spec:rcov",
                  "metrics:coverage", "metrics:cyclomatic_complexity", "metrics:stats",
                  "spec_doc", "todos_doc", "doc_app"] do
end

desc "The Spec Doc report"
task :spec_doc do
  sh "rake spec:doc > #{File.join(base_directory, 'spec_doc.log')}"
end

desc "The list of todos, hacks, etc.."
task :todos_doc do
  sh "rake notes > #{File.join(base_directory, 'todos.log')}"
end

desc "The Application Documentation"
task :doc_app do
  sh "rdoc -x -i app/* --op #{File.join(base_directory, 'doc')}"
end

namespace :perf do

  desc "Run Performance Profile Test"
  task :run => [ :environment ] do
    num = 10
    sh "Rails env #{RAILS_ENV}"
    m = Match.find( :first, :conditions => ['player1_id = ? ', Player.find_by_login('legal').id],
      :include => :moves )
    b = nil
    time = Benchmark.realtime do
        num.times { b = m.board; m.instance_variable_set(:@board, nil) }
    end
    p b
    sh "echo 'Benchmark 1: #{time} seconds to run legal mate #{num} times'"
    nil
  end
end