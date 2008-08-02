desc "Task for CruiseControl.rb"
task :cruise => [:prepare, "db:migrate", "spec"] do
end