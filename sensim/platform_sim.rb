module PlatformSim
  require 'csv'

  def self.run_sim(platform)
    
  end

  def getchar
    system("stty raw -echo")
    char = STDIN.getc
    system("stty raw -echo")
    char
  end
end