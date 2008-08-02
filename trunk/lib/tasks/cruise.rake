desc "Task for CruiseControl.rb"
task :cruise => ["db:migrate", "spec"] do
end