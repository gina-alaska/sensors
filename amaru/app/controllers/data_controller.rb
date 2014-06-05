class DataController < ApplicationController
  skip_filter :require_login

  require 'zip/zip'
  require 'zip/zipfilesystem'

  def raw
    platform = Platform.where(slug: params["slug"]).first
    date = params["date"].nil? ? nil : Time.zone.parse(params["date"])
    range = params["range"].nil? ? nil : eval(params["range"])
    sensors = data_params[:sensors]

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

    raw = platform.raw_data.captured_between(starts, ends)

    if (sensors.nil? or sensors.first == "all") and !raw.first.nil?
      sensors = raw.first.attributes.keys - ["_type","_id","parent_id","platform_id", "group_id"]
    else
      sensors.insert(0,"capture_date") unless sensors.nil?
    end

    respond_to do |format|
      format.csv do
        if raw.first.nil?
          send_data "No data found between #{starts} and #{ends}",
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{platform.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        else
          send_data generate_csv(raw, sensors),
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{platform.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        end
      end
      format.json {render :json => raw}

      format.zip do
        data_file = "/tmp/#{platform.name}_RAW_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        unless platform.platform_metadata.nil? or platform.platform_metadata == "No Metadata"
          meta_file = Rails.root.join("metadata/#{platform.platform_metadata}")
        end
        zip_file = "/tmp/#{platform.name}_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.zip"

        #create the csv file
        File.open(data_file, "w") {|f| f.write(generate_csv(raw, sensors))}

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
    date = params["date"].nil? ? nil : Time.zone.parse(params["date"])
    range = params["range"].nil? ? nil : eval(params["range"])
    sensors = data_params[:sensors]

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

    proc = platform.groups.where(name: params["group"]).first.processed_data.captured_between(starts, ends).asc(:capture_date)

    if (sensors.nil? or sensors.first == "all") and !proc.first.nil?
      sensors = proc.first.attributes.keys - ["_type","_id","parent_id","platform_id", "group_id"]
    else
      sensors.insert(0,"capture_date") unless sensors.nil?
    end

    respond_to do |format|
      format.csv do
        if proc.first.nil?
          send_data "No data found between #{starts} and #{ends}",
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{group.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        else
          send_data generate_csv(proc, sensors),
          :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{group.name}-#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        end
      end
      format.json {render :json => proc}

      format.zip do
        data_file = "/tmp/#{platform.name}_PROC_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.csv"
        unless platform.platform_metadata.nil? or platform.platform_metadata == "No Metadata"
          meta_file = Rails.root.join("metadata/#{platform.platform_metadata}")
        end
        zip_file = "/tmp/#{platform.name}_#{Time.zone.now.strftime('%d-%m-%y_%H-%M')}.zip"

        #create the csv file
        File.open(data_file, "w") {|f| f.write(generate_csv(proc, sensors))}

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

  def data_params
    dparms = {
      sensors: params['sensors']
    }

    dparms[:sensors] = dparms[:sensors].split(' ') if dparms[:sensors].is_a? String

    dparms
  end

  def generate_csv( data, sensors )
#    data = [data].flatten
    headers = data.first.attributes.keys - ["_type","_id","parent_id","platform_id", "group_id"]
    headers = headers.reject{|v| !sensors.include?(v)} unless sensors.nil? or sensors.empty?
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
