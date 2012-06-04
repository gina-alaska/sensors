class ImportConfig
	def initialize( config_file )
    if File.exists?( config_file )
      @config = YAML.load_file(config_file)
    else
      raise "I can't find the configuration file \e[31m#{@config_file}\e[0m!"
    end
	end

	def [](section)
    if @config[section].nil?
      raise "There is no \e[31m#{section}\e[0m! in the configuration file!"
    else
      @config[section]
    end
  end
end