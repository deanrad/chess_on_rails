namespace :metrics do
  TEST_PATHS_FOR_RCOV = ['spec/**/*_spec.rb']
end

desc "Task for CruiseControl.rb"
task :cruise => ["db:migrate", "spec:rcov", "metrics:all", "spec_doc", "todos_doc"] do
end

desc "The Spec Doc report"
task :spec_doc do
  sh "rake spec:doc > #{File.join(base_directory, 'spec_doc.log')}"
end

desc "The list of todos, hacks, etc.."
task :todos_doc do
  sh "rake notes > #{File.join(base_directory, 'todos.log')}"
end

