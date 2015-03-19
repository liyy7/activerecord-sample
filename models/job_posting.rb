# encoding: UTF-8

class JobPosting
  has_many :locations
  has_many :nearest_stations

  scope :full_model, -> do
    eager_load(
      { locations: [:country, :administrative_area, :locality_group, :locality, :ward] },
      { nearest_stations: :station })
  end

  scope :find_by_station_titles, ->(titles) do
    joins(nearest_stations: :station).where(station: { title: titles })
  end

  scope :find_by_locality_ids, ->(ids) do
    joins(locations: :locality).where(locality: { id: ids })
  end

  def offer_types
    OfferType.from_bits(offer_type_bit).map do |o|
      o.job_posting_id = id
      o
    end
  end

  def features
    Feature.from_bits(feature_bit).map do |f|
      f.job_posting_id = id
      f
    end
  end
end

