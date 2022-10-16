class AddPolymorphicAssociationToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :addressable_id, :integer, index: true
    add_column :addresses, :addressable_type, :string, index: true

    Customer.find_each do |c|
      next if c.address_id.blank?
      c.address.update(addressable_id: c.id, addressable_type: 'Customer')
    end

    Site.find_each do |s|
      next if s.address_id.blank?
      s.address.update(addressable_id: s.id, addressable_type: 'Site')
    end
  end

  def self.down
    remove_column :addresses, :addressable_id, :integer, index: true
    remove_column :addresses, :addressable_type, :string, index: true
  end
end
