desc "This task is called by the Heroku scheduler add-on"
task :update_question_of_day => :environment do
  puts "Updating question of day..."
  Question.update_question_of_day
  puts "done."
end

############Send Push Notifications For Daily Question#############

task :send_daily_question_push => :environment do
  puts "Sending Push for today question"
  FcmPush.new.send_daily_push
  puts "done"
end