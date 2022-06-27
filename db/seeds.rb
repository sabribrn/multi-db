%w[UPS DHL FedEx].each do |name|
  company = Company.create(name: name)
  3.times { Shipment.create(tracking: SecureRandom.hex(8), company: company) }
end

