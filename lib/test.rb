require_relative 'data_binge'

class Car < DataBinge
  belongs_to(
    :driver,
    foreign_key: :owner_id
  )

  finalize!
end

class Driver < DataBinge
  belongs_to :garage

  has_many(
    :cars,
    foreign_key: :owner_id
  )

  finalize!
end

class Garage < DataBinge
  has_many :drivers

  has_many_through(
    :cars,
    :drivers,
    :cars
  )

  finalize!
end
