class ShipmentsController < ApplicationController
  def master
    render json: { shipments: shipments_from_master_db }
  end

  def replica
    render json: { shipments: shipments_from_replica_db }
  end

  private

  def shipments_from_master_db
    ActiveRecord::Base.connected_to(role: :writing) do
      Shipment.all
    end
  end

  def shipments_from_replica_db
    ActiveRecord::Base.connected_to(role: :reading) do
      Shipment.all
    end
  end
end
