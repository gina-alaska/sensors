module AmaruRunner
  def system_log(name, keep, delete)
    puts "Writing system messages to file #{name}."
    sys_messages = Statu.where(:start_time.lte => (DateTime.now - keep.days))

    outfile = File.open(name, "a")

    unless outfile
      raise "Error, I can't open the file #{name}!"
    end

    sys_messages.each do |message|
      outfile.syswrite("#{message.system.upcase}: #{message.status}, #{message.message} START: #{message.start_time} END: #{message.end_time}\n")
      message.destroy if delete
    end

    puts "Finished."
  end
end
