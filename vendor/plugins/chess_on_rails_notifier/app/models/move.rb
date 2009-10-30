# Adds extensions to the move controller
Move.class_eval do
  after_save :notify_via_email

  def notify_via_email
    # $stderr.puts "Notifying of move #{self.inspect}"
  end
end
