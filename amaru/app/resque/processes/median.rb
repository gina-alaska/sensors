module Processes
  # Using R, calculate the median filter on the data.
  def median(opts)
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

    # Do R median filter processing
    myr.data = rdata.compact
    puts myr.data.inspect
    myr.eval <<-EOF
      mdata <- median(data)
    EOF

    output = myr.mdata
    myr.quit

    return output
  end
end