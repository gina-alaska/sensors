module DataSave
	def raw_save( datahash )
  	newdata = RawDatum.create(datahash)

    if newdata.valid?
      platform.raw_data << newdata
    else
      raise "Raw data insert failed mongoid validation:\n #{datahash}"
    end
  end

  def processed_save( datahash )
  	newdata = ProcessedDatum.create(datahash)

    if newdata.valid?
      platform.processed_data << newdata
    else
      raise "Processed data insert failed mongoid validation:\n #{datahash}"
    end
  end
end