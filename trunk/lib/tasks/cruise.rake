namespace :metrics do
  TEST_PATHS_FOR_RCOV = ['spec/**/*_spec.rb']
end

desc "Task for CruiseControl.rb"
task :cruise => ["db:migrate", "spec:rcov", "metrics:all"] do
end