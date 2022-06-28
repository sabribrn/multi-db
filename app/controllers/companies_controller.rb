class CompaniesController < ApplicationController
  def master
    render json: { companies: companies_from_master_db }
  end

  def replica
    render json: { companies: companies_from_replica_db }
  end

  private

  def companies_from_master_db
    ActiveRecord::Base.connected_to(role: :writing) do
      Company.all
    end
  end

  def companies_from_replica_db
    ActiveRecord::Base.connected_to(role: :reading) do
      Company.all
    end
  end
end
