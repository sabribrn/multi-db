Rails.application.routes.draw do
  get 'companies/master', to: 'companies#master'
  get 'companies/replica', to: 'companies#replica'

  get 'shipments/master', to: 'shipments#master'
  get 'shipments/replica', to: 'shipments#replica'
end
