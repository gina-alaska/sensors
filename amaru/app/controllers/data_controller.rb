class DataController < ApplicationController
  def raw
    platform = Platform.where(slug: params["slug"]).first
    sensor = params["sensor"]
    date = params["date"].nil? ? nil : Time.parse(params["date"])
    range = params["range"].nil? ? nil : eval(params["range"])

    if date.nil?
      ends = Time.now
    else
      ends = date
    end
    if range.nil?
      starts = ends - 24.hours
    else
      starts = ends - range
    end

    if sensor == "all" or sensor.nil?
      raw = platform.raw_data.captured_between(starts, ends)
    else
      raw = platform.raw_data.captured_between(starts, ends).only(:capture_date, sensor.to_sym)
    end

    respond_to do |format|
      format.csv do
        send_data generate_csv(raw),
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{platform.name}-#{Time.now.strftime('%d-%m-%y--%H-%M')}.csv"
      end

#      format.graph
#      format.zip
    end
  end

  def processed
    group = Group.where(name: params["group"]).first
    platform = Platform.where(slug: params["slug"]).first
    sensor = params["sensor"]
    date = params["date"].nil? ? nil : Time.parse(params["date"])
    range = params["range"].nil? ? nil : eval(params["range"])

    if date.nil?
      ends = Time.now
    else
      ends = date
    end
    if range.nil?
      starts = ends - 24.hours
    else
      starts = ends - range
    end

    if sensor == "all" or sensor.nil?
      proc = group.processed_data.where(platform: platform).captured_between(starts, ends).asc(:capture_date)
    else
      raw = group.processed_data.where(platform: platform).captured_between(starts, ends).only(:capture_date, sensor.to_sym).asc(:capture_date)
    end

    respond_to do |format|
      format.csv do
        send_data generate_csv(raw),
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{group.name}-#{Time.now.strftime('%d-%m-%y--%H-%M')}.csv"
      end

#      format.graph
#      format.zip
    end
  end

  def graph
  end

  def alert
  end

protected

  def generate_csv data
#    data = [data].flatten
    headers = data.first.attributes.keys - ["_type","_id","parent_id","platform_id"]
    ::CSV.generate({:headers => true}) do |csv|
      csv << headers
      data.each do |d|
        row = []
        headers.each do |header|
          row.push("#{d[header.to_sym]}")
        end
        csv << row
      end
    end
  end    
end
