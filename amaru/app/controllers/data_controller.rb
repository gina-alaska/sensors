class DataController < ApplicationController
  skip_before_filter :require_login
  
  require 'zip/zip'
  require 'zip/zipfilesystem'

  def raw
    platform = Platform.where(slug: params["slug"]).first
    sensor ||= params["sensor"]
    date = params["date"].nil? ? nil : Time.zone.parse(params["date"])
    range = params["range"].nil? ? nil : eval(params["range"])

    if date.nil?
      ends = Time.zone.now
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
        :disposition => "attachment; filename=#{platform.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
      end
      format.json {render :json => raw}

# do this later
#      format.jpg do
#      end

      format.zip do
        data_file = "/tmp/#{platform.name}_RAW_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        unless platform.platform_metadata.nil? or platform.platform_metadata == "No Metadata"
          meta_file = Rails.root.join("metadata/#{platform.platform_metadata}")
        end
        zip_file = "/tmp/#{platform.name}_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.zip"

        #create the csv file
        File.open(data_file, "w") {|f| f.write(generate_csv(raw))}

        #create zip file
        Zip::ZipFile::open(zip_file, "w") do |zip|
          zip.add(File.basename(data_file), data_file)
          unless meta_file.nil?
            zip.add(File.basename(meta_file), meta_file)
          end
        end

        # Send the zip file and clean up
        send_file( zip_file, :type => "application/zip")
        File.delete(data_file, zip_file)
      end
    end
  end

  def processed
    group = Group.where(name: params["group"]).first
    platform = Platform.where(slug: params["slug"]).first
    sensor = params["sensor"]
    date = params["date"].nil? ? nil : Time.zone.parse(params["date"])
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
      proc = group.processed_data.where(platform: platform).captured_between(starts, ends).only(:capture_date, sensor.to_sym).asc(:capture_date)
    end

    respond_to do |format|
      format.csv do
        send_data generate_csv(proc),
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=#{group.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
      end
      format.json {render :json => proc}

#      format.graph

      format.zip do
        data_file = "/tmp/#{platform.name}_PROC_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        unless platform.platform_metadata.nil? or platform.platform_metadata == "No Metadata"
          meta_file = Rails.root.join("metadata/#{platform.platform_metadata}")
        end
        zip_file = "/tmp/#{platform.name}_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.zip"

        #create the csv file
        File.open(data_file, "w") {|f| f.write(generate_csv(proc))}

        #create zip file
        Zip::ZipFile::open(zip_file, "w") do |zip|
          zip.add(File.basename(data_file), data_file)
          unless meta_file.nil?
            zip.add(File.basename(meta_file), meta_file)
          end
        end

        # Send the zip file and clean up
        send_file( zip_file, :type => "application/zip", :disposition => "inline")
        File.delete(data_file, zip_file)
      end
    end
  end

  def graph
    group = Group.where(name: params["group"]).first
    graph = group.graphs.where(name: params["graph"]).first

    path = File.join('graphs', params["slug"])
    file = File.join(path, "#{graph.id}.jpg")

    respond_to do |format|
      format.jpg do
        send_file(file, type: "image/jpeg", :disposition => "inline")
      end
    end
  end

  def alert
  end

protected

  def generate_csv data
#    data = [data].flatten
    headers = data.first.attributes.keys - ["_type","_id","parent_id","platform_id", "group_id"]
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
