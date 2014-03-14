module Processes
  # Using R, calculate the mean from the data inputed
  def mean(opts)
    data = opts[:input]
    data_field = opts[:data_field]

    myr = RinRuby.new(false)
    rdata = []
    output = 0.0

    # Build array to send to R, convert all no data values to nil.
    data.each do |row|
      value = row[data_field.to_sym] == @platform.no_data_value ? nil : row[data_field.to_sym].to_f
      rdata.push(value)
    end

    # Do R mean filter processing
    myr.data = rdata.compact
    File.open("/tmp/mean#{Time.now.to_s}", "w") do |f|
      f<< myr.data
    end

    myr.eval <<-EOF
      mdata <- mean(data)
    EOF

    output = myr.mdata
    myr.quit

    return output
  end
end