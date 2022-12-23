class AddPolymorphicAssociationToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :addressable_id, :integer, index: true unless Address.column_names.include?('addressable_id')
    add_column :addresses, :addressable_type, :string, index: true unless Address.column_names.include?('addressable_type')

    Customer.find_each do |c|
      next unless c.address_id
      address = Address.find(c.address_id)
      next if address.blank?
      address.update(addressable_id: c.id, addressable_type: 'Customer')
    end

    Site.find_each do |s|
      next unless s.address_id
      address = Address.find(s.address_id)
      next if address.blank?
      address.update(addressable_id: s.id, addressable_type: 'Site')
    end
  end

  def self.down
    remove_column :addresses, :addressable_id, :integer, index: true
    remove_column :addresses, :addressable_type, :string, index: true
  end
end
